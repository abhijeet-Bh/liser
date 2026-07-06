import 'dart:async';

import 'package:just_audio/just_audio.dart';
import 'package:just_audio_background/just_audio_background.dart';
import 'package:liser/features/library/data/models/song.dart';

class AudioPlayerService {
  final AudioPlayer _player = AudioPlayer();

  final StreamController<Song?> _currentSongController =
      StreamController.broadcast();

  Song? _currentSong;

  List<Song> _queue = [];

  StreamSubscription<int?>? _indexSubscription;

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

  Future<void> loadQueue(List<Song> songs, {int initialIndex = 0}) async {
    _queue = List.from(songs);

    final playlist = ConcatenatingAudioSource(
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

    await _player.setAudioSource(playlist, initialIndex: initialIndex);

    _currentSong = songs[initialIndex];

    _currentSongController.add(_currentSong);

    await _indexSubscription?.cancel();

    _indexSubscription = _player.currentIndexStream.listen((index) {
      if (index == null) return;

      if (index < 0 || index >= _queue.length) return;

      _currentSong = _queue[index];

      _currentSongController.add(_currentSong);
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
        await _player.setLoopMode(LoopMode.all);
        break;

      case LoopMode.all:
        await _player.setLoopMode(LoopMode.one);
        break;

      case LoopMode.one:
        await _player.setLoopMode(LoopMode.off);
        break;
    }
  }

  Future<void> setSpeed(double speed) async {
    await _player.setSpeed(speed);
  }

  Future<void> dispose() async {
    await _indexSubscription?.cancel();

    await _player.dispose();

    await _currentSongController.close();
  }
}
