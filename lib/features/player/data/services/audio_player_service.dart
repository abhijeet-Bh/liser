import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:liser/core/storage/repositories/settings_repository.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'dart:convert';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  final StreamController<Song?> _currentSongController =
      StreamController.broadcast();

  AudioPlayerService() {
    _restoreQueueState();
  }
  
  Future<void> _saveQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songIds = _queue.map((s) => s.id).toList();
      await prefs.setStringList('saved_queue_ids', songIds);
      await prefs.setInt('saved_queue_index', currentIndex);
      await prefs.setInt('saved_queue_position', _player.position.inMilliseconds);
    } catch (e) {
      // ignore
    }
  }
  
  Future<void> _restoreQueueState() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final songIds = prefs.getStringList('saved_queue_ids');
      final index = prefs.getInt('saved_queue_index') ?? 0;
      final positionMs = prefs.getInt('saved_queue_position') ?? 0;
      
      if (songIds != null && songIds.isNotEmpty) {
        final libRepo = sl<LibraryRepository>();
        final allSongs = await libRepo.getSongs();
        
        List<Song> savedSongs = [];
        for (final id in songIds) {
          final s = allSongs.cast<Song?>().firstWhere((song) => song?.id == id, orElse: () => null);
          if (s != null) {
            savedSongs.add(s);
          }
        }
        
        if (savedSongs.isNotEmpty) {
          final safeIndex = index < savedSongs.length ? index : 0;
          await loadQueue(savedSongs, initialIndex: safeIndex);
          await _player.seek(Duration(milliseconds: positionMs));
        }
      }
    } catch (e) {
      // ignore
    }
  }

  Song? _currentSong;

  List<Song> _queue = [];

  StreamSubscription<int?>? _indexSubscription;
  StreamSubscription<PlayerState>? _playerStateInternalSubscription;

  /// Debounce timer used to ignore phantom index-0 events emitted by
  /// just_audio immediately after a pause or lock-screen seek.
  Timer? _phantomDebounceTimer;

  AudioPlayer get player => _player;

  Stream<PlayerState> get playerStateStream => _player.playerStateStream;

  Stream<Duration> get positionStream => _player.positionStream;

  Stream<Duration?> get durationStream => _player.durationStream;

  Stream<Song?> get currentSongStream => _currentSongController.stream;

  Song? get currentSong => _currentSong;

  List<Song> get queue => List.unmodifiable(_queue);

  int get currentIndex => _player.currentIndex ?? 0;

  bool get isPlaying => _player.playing;

  bool get hasNext => _player.hasNext;

  bool get hasPrevious => _player.hasPrevious;

  bool get shuffleEnabled => _player.shuffleModeEnabled;

  LoopMode get repeatMode => _player.loopMode;

  ConcatenatingAudioSource? _playlist;

  Future<void> loadQueue(List<Song> songs, {int initialIndex = 0}) async {
    _queue = List.from(songs);

    _playlist = ConcatenatingAudioSource(
      children: [
        for (final song in songs)
          AudioSource.file(
            song.path,
            tag: MediaItem(
              id: song.id,
              album: song.album,
              title: song.title,
              artist: song.artist,
              artUri: song.artworkPath != null ? Uri.file(song.artworkPath!) : null,
            ),
          ),
      ],
    );

    await _player.setAudioSource(_playlist!, initialIndex: initialIndex);

    _currentSong = songs[initialIndex];

    _currentSongController.add(_currentSong);

    await _indexSubscription?.cancel();
    // Cancel previous playerStateStream listener to prevent subscription leaks
    // (loadQueue can be called multiple times, e.g. on every PlaySong event).
    await _playerStateInternalSubscription?.cancel();

    _indexSubscription = _player.currentIndexStream.listen((index) {
      if (index == null) return;
      if (index < 0 || index >= _queue.length) return;

      // just_audio (and just_audio_background) sometimes emits a spurious
      // index == 0 immediately after a pause or a lock-screen prev/next
      // command, before the player state has fully settled. We debounce
      // any index-0 event that arrives while the player is not actively
      // playing: if no confirming event arrives within 200 ms we ignore it.
      if (index == 0 && _currentSong != null && _queue.indexOf(_currentSong!) > 0) {
        if (!_player.playing) {
          _phantomDebounceTimer?.cancel();
          _phantomDebounceTimer = Timer(const Duration(milliseconds: 200), () {
            // After the debounce window, only apply if still at index 0 and
            // still not playing, i.e. the OS genuinely seeked to the start.
            if (_player.currentIndex == 0 && !_player.playing) {
              _currentSong = _queue[0];
              _currentSongController.add(_currentSong);
              _saveQueueState();
            }
          });
          return; // Don't update immediately — wait for debounce.
        }
      }

      // For any other index change (including index-0 while playing) apply at once.
      _phantomDebounceTimer?.cancel();
      _currentSong = _queue[index];
      _currentSongController.add(_currentSong);
      _saveQueueState();
    });

    // Save state on pause. Store the subscription so it can be cancelled on
    // the next loadQueue call (prevents one listener per queue load).
    _playerStateInternalSubscription = _player.playerStateStream.listen((state) {
      if (!state.playing) {
        _saveQueueState();
      }
    });
  }

  Future<void> playSong(List<Song> songs, Song song) async {
    final index = songs.indexWhere((e) => e.id == song.id);

    await loadQueue(songs, initialIndex: index < 0 ? 0 : index);

    await play();
  }

  Future<void> play() async {
    await _player.play();
  }

  Future<void> pause() async {
    await _player.pause();
  }

  Future<void> stop() async {
    await _player.stop();
  }

  Future<void> next() async {
    if (_player.hasNext) {
      await _player.seekToNext();
    }
  }

  Future<void> previous() async {
    if (_player.hasPrevious) {
      await _player.seekToPrevious();
    } else {
      await seek(Duration.zero);
    }
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
  }

  Future<void> seekToIndex(int index) async {
    if (index < 0 || index >= _queue.length) return;

    await _player.seek(Duration.zero, index: index);
  }

  Future<void> setShuffle(bool enabled) async {
    await _player.setShuffleModeEnabled(enabled);

    if (enabled) {
      await _player.shuffle();
    }
  }

  Future<void> toggleShuffle() async {
    await setShuffle(!_player.shuffleModeEnabled);
  }

  Future<void> setRepeatMode(LoopMode mode) async {
    await _player.setLoopMode(mode);
  }

  Future<void> cycleRepeatMode() async {
    switch (_player.loopMode) {
      case LoopMode.off:
        await _player.setLoopMode(LoopMode.one);
        break;

      case LoopMode.one:
        await _player.setLoopMode(LoopMode.all);
        break;

      case LoopMode.all:
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> reorderQueue(int oldIndex, int newIndex) async {
    if (_playlist == null) return;
    if (oldIndex < newIndex) newIndex -= 1;
    final song = _queue.removeAt(oldIndex);
    _queue.insert(newIndex, song);
    await _playlist!.move(oldIndex, newIndex);
    _currentSongController.add(_currentSong);
    _saveQueueState();
  }

  Future<void> clearQueue() async {
    if (_playlist == null) return;
    await _player.stop();
    _queue.clear();
    await _playlist!.clear();
    _currentSongController.add(null);
    _saveQueueState();
  }

  Future<void> addNext(Song song) async {
    // If there's no active playlist or the queue is empty (e.g. after a clear
    // or on first launch), bootstrap a fresh queue so the player UI appears.
    if (_playlist == null || _queue.isEmpty) {
      await loadQueue([song], initialIndex: 0);
      // Do NOT auto-play — user didn't tap Play.
      return;
    }
    final insertIndex = currentIndex + 1;
    _queue.insert(insertIndex, song);
    final audioSource = AudioSource.file(
      song.path,
      tag: MediaItem(
        id: song.id,
        album: song.album,
        title: song.title,
        artist: song.artist,
        artUri: song.artworkPath != null ? Uri.file(song.artworkPath!) : null,
      ),
    );
    await _playlist!.insert(insertIndex, audioSource);
    _currentSongController.add(_currentSong);
    _saveQueueState();
  }

  Future<void> addToEnd(Song song) async {
    // If there's no active playlist or the queue is empty (e.g. after a clear
    // or on first launch), bootstrap a fresh queue so the player UI appears.
    if (_playlist == null || _queue.isEmpty) {
      await loadQueue([song], initialIndex: 0);
      // Do NOT auto-play — user didn't tap Play.
      return;
    }
    _queue.add(song);
    final audioSource = AudioSource.file(
      song.path,
      tag: MediaItem(
        id: song.id,
        album: song.album,
        title: song.title,
        artist: song.artist,
        artUri: song.artworkPath != null ? Uri.file(song.artworkPath!) : null,
      ),
    );
    await _playlist!.add(audioSource);
    _currentSongController.add(_currentSong);
    _saveQueueState();
  }

  Future<void> removeFromQueue(int index) async {
    if (_playlist == null) return;
    if (index < 0 || index >= _queue.length) return;
    // Don't allow removing the currently playing song.
    if (index == currentIndex) return;
    _queue.removeAt(index);
    await _playlist!.removeAt(index);
    _currentSongController.add(_currentSong);
    _saveQueueState();
  }

  /// Force-emit the current song state so that the UI can re-sync after the
  /// app returns from the background (where the OS media session may have
  /// changed the track without Flutter receiving a stream event).
  void syncState() {
    final index = _player.currentIndex;
    if (index != null && index >= 0 && index < _queue.length) {
      _phantomDebounceTimer?.cancel();
      _currentSong = _queue[index];
      _currentSongController.add(_currentSong);
    }
  }

  Future<void> dispose() async {
    _phantomDebounceTimer?.cancel();
    await _indexSubscription?.cancel();
    await _playerStateInternalSubscription?.cancel();

    await _player.dispose();

    await _currentSongController.close();
  }
}
