import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:just_audio/just_audio.dart';

import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/player/data/services/audio_player_service.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/services/native_volume_service.dart';

part 'player_event.dart';
part 'player_state.dart';

final class _NativeVolumeChanged extends PlayerEvent {
  const _NativeVolumeChanged(this.volume);
  final double volume;
}

class PlayerBloc extends Bloc<PlayerEvent, PlayerUiState> {
  PlayerBloc({
    required AudioPlayerService playerService,
    required NativeVolumeService volumeService,
  })  : _playerService = playerService,
        _volumeService = volumeService,
        super(
        PlayerUiState(
          currentSong: playerService.currentSong,
          queue: playerService.queue,
          currentIndex: playerService.currentIndex,
          shuffleEnabled: playerService.shuffleEnabled,
          repeatMode: playerService.repeatMode,
          volume: 1.0, // Temporary before initialization
        ),
      ) {
    /// User events
    on<PlaySong>(_onPlaySong);
    on<TogglePlayPause>(_onTogglePlayPause);
    on<NextSong>(_onNextSong);
    on<PreviousSong>(_onPreviousSong);
    on<SeekToPosition>(_onSeekToPosition);
    on<ReplaySong>(_onReplaySong);
    on<ToggleFavorite>(_onToggleFavorite);
    on<ToggleShuffle>(_onToggleShuffle);
    on<ToggleRepeatMode>(_onToggleRepeatMode);
    on<OpenQueueRequested>(_onOpenQueueRequested);
    on<ReorderQueue>(_onReorderQueue);
    on<ClearQueue>(_onClearQueue);
    on<AddSongNext>(_onAddSongNext);
    on<AddSongToEnd>(_onAddSongToEnd);
    on<SetVolume>(_onSetVolume);
    on<IncreaseVolume>(_onIncreaseVolume);
    on<DecreaseVolume>(_onDecreaseVolume);

    /// Internal events
    on<_PlayerStateChanged>(_onPlayerStateChanged);
    on<_PositionChanged>(_onPositionChanged);
    on<_DurationChanged>(_onDurationChanged);
    on<_CurrentSongChanged>(_onCurrentSongChanged);
    on<_NativeVolumeChanged>(_onNativeVolumeChanged);

    _initVolume();

    _playerStateSubscription = _playerService.playerStateStream.listen(
      (value) => add(_PlayerStateChanged(value)),
    );

    _positionSubscription = _playerService.positionStream.listen(
      (value) => add(_PositionChanged(value)),
    );

    _durationSubscription = _playerService.durationStream.listen(
      (value) => add(_DurationChanged(value)),
    );

    _currentSongSubscription = _playerService.currentSongStream.listen(
      (value) => add(_CurrentSongChanged(value)),
    );

    _volumeSubscription = _volumeService.volumeStream.listen(
      (value) => add(_NativeVolumeChanged(value)),
    );
  }

  Future<void> _initVolume() async {
    final vol = await _volumeService.getVolume();
    add(_NativeVolumeChanged(vol));
  }

  final AudioPlayerService _playerService;
  final NativeVolumeService _volumeService;

  late final StreamSubscription<PlayerState> _playerStateSubscription;
  late final StreamSubscription<Duration> _positionSubscription;
  late final StreamSubscription<Duration?> _durationSubscription;
  late final StreamSubscription<Song?> _currentSongSubscription;
  late final StreamSubscription<double> _volumeSubscription;
  Future<void> _onPlaySong(PlaySong event, Emitter<PlayerUiState> emit) async {
    await _playerService.playSong(event.queue, event.song);

    emit(
      state.copyWith(
        currentSong: event.song,
        queue: event.queue,
        currentIndex: event.queue.indexWhere((e) => e.id == event.song.id),
      ),
    );
  }

  Future<void> _onTogglePlayPause(
    TogglePlayPause event,
    Emitter<PlayerUiState> emit,
  ) async {
    if (_playerService.isPlaying) {
      await _playerService.pause();
    } else {
      await _playerService.play();
    }
  }

  Future<void> _onNextSong(NextSong event, Emitter<PlayerUiState> emit) async {
    await _playerService.next();

    emit(state.copyWith(currentIndex: _playerService.currentIndex));
  }

  Future<void> _onPreviousSong(
    PreviousSong event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.previous();

    emit(state.copyWith(currentIndex: _playerService.currentIndex));
  }

  Future<void> _onSeekToPosition(
    SeekToPosition event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.seek(event.position);
  }

  Future<void> _onReplaySong(
    ReplaySong event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.seek(Duration.zero);

    if (!_playerService.isPlaying) {
      await _playerService.play();
    }
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<PlayerUiState> emit,
  ) async {
    event.song.favorite = !event.song.favorite;

    await event.song.save();

    if (state.currentSong?.id == event.song.id) {
      emit(state.copyWith(currentSong: event.song));
    }
  }

  Future<void> _onToggleShuffle(
    ToggleShuffle event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.toggleShuffle();
    emit(state.copyWith(shuffleEnabled: _playerService.shuffleEnabled));
  }

  Future<void> _onToggleRepeatMode(
    ToggleRepeatMode event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.cycleRepeatMode();
    emit(state.copyWith(repeatMode: _playerService.repeatMode));
  }

  Future<void> _onOpenQueueRequested(
    OpenQueueRequested event,
    Emitter<PlayerUiState> emit,
  ) async {
    // Handled by UI state directly in ExpandablePlayer now
  }

  Future<void> _onReorderQueue(
    ReorderQueue event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.reorderQueue(event.oldIndex, event.newIndex);
  }

  Future<void> _onClearQueue(
    ClearQueue event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.clearQueue();
  }

  Future<void> _onAddSongNext(
    AddSongNext event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.addNext(event.song);
  }

  Future<void> _onAddSongToEnd(
    AddSongToEnd event,
    Emitter<PlayerUiState> emit,
  ) async {
    await _playerService.addToEnd(event.song);
  }

  Future<void> _onSetVolume(
    SetVolume event,
    Emitter<PlayerUiState> emit,
  ) async {
    final newVolume = event.volume.clamp(0.0, 1.0);
    await _volumeService.setVolume(newVolume);
    emit(state.copyWith(volume: newVolume));
  }

  Future<void> _onIncreaseVolume(
    IncreaseVolume event,
    Emitter<PlayerUiState> emit,
  ) async {
    final currentVolume = state.volume;
    final newVolume = (currentVolume + 0.1).clamp(0.0, 1.0);
    await _volumeService.setVolume(newVolume);
    emit(state.copyWith(volume: newVolume));
  }

  Future<void> _onDecreaseVolume(
    DecreaseVolume event,
    Emitter<PlayerUiState> emit,
  ) async {
    final currentVolume = state.volume;
    final newVolume = (currentVolume - 0.1).clamp(0.0, 1.0);
    await _volumeService.setVolume(newVolume);
    emit(state.copyWith(volume: newVolume));
  }

  void _onNativeVolumeChanged(
    _NativeVolumeChanged event,
    Emitter<PlayerUiState> emit,
  ) {
    emit(state.copyWith(volume: event.volume));
  }

  void _onPlayerStateChanged(
    _PlayerStateChanged event,
    Emitter<PlayerUiState> emit,
  ) {
    PlayerStatus status;

    if (event.state.playing) {
      status = PlayerStatus.playing;
    } else if (event.state.processingState == ProcessingState.completed) {
      status = PlayerStatus.stopped;
    } else {
      status = PlayerStatus.paused;
    }

    emit(
      state.copyWith(
        status: status,
        shuffleEnabled: _playerService.shuffleEnabled,
        repeatMode: _playerService.repeatMode,
        currentIndex: _playerService.currentIndex,
      ),
    );
  }

  void _onPositionChanged(_PositionChanged event, Emitter<PlayerUiState> emit) {
    emit(state.copyWith(position: event.position));
  }

  void _onDurationChanged(_DurationChanged event, Emitter<PlayerUiState> emit) {
    emit(state.copyWith(duration: event.duration ?? Duration.zero));
  }

  Future<void> _onCurrentSongChanged(
    _CurrentSongChanged event,
    Emitter<PlayerUiState> emit,
  ) async {
    if (event.song != null && event.song?.id != state.currentSong?.id) {
      try {
        await sl<LibraryRepository>().incrementPlayCount(event.song!);
      } catch (e) {
        // Ignore error if it fails
      }
    }
    emit(
      state.copyWith(
        currentSong: event.song,
        queue: _playerService.queue,
        currentIndex: _playerService.currentIndex,
      ),
    );
  }

  @override
  Future<void> close() async {
    await _playerStateSubscription.cancel();
    await _positionSubscription.cancel();
    await _durationSubscription.cancel();
    await _currentSongSubscription.cancel();
    await _volumeSubscription.cancel();

    return super.close();
  }
}
