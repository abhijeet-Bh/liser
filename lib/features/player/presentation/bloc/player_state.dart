part of 'player_bloc.dart';

enum PlayerStatus { stopped, playing, paused }

class PlayerUiState extends Equatable {
  const PlayerUiState({
    this.status = PlayerStatus.stopped,
    this.currentSong,
    this.queue = const [],
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.currentIndex = -1,
    this.shuffleEnabled = false,
    this.repeatMode = LoopMode.off,
    this.volume = 1.0,
  });

  final PlayerStatus status;

  /// Currently playing song.
  final Song? currentSong;

  /// Current playback queue.
  final List<Song> queue;

  /// Current playback position.
  final Duration position;

  /// Song duration.
  final Duration duration;

  /// Current index inside queue.
  final int currentIndex;

  /// Shuffle enabled.
  final bool shuffleEnabled;

  /// Repeat mode.
  final LoopMode repeatMode;

  /// Current Volume (0.0 to 1.0).
  final double volume;

  bool get hasSong => currentSong != null;

  bool get hasNext =>
      queue.isNotEmpty && currentIndex >= 0 && currentIndex < queue.length - 1;

  bool get hasPrevious => queue.isNotEmpty && currentIndex > 0;

  double get progress {
    if (duration.inMilliseconds == 0) return 0;

    return position.inMilliseconds / duration.inMilliseconds;
  }

  PlayerUiState copyWith({
    PlayerStatus? status,
    Song? currentSong,
    bool clearCurrentSong = false,
    List<Song>? queue,
    Duration? position,
    Duration? duration,
    int? currentIndex,
    bool? shuffleEnabled,
    LoopMode? repeatMode,
    double? volume,
  }) {
    return PlayerUiState(
      status: status ?? this.status,
      currentSong: clearCurrentSong ? null : (currentSong ?? this.currentSong),
      queue: queue ?? this.queue,
      position: position ?? this.position,
      duration: duration ?? this.duration,
      currentIndex: currentIndex ?? this.currentIndex,
      shuffleEnabled: shuffleEnabled ?? this.shuffleEnabled,
      repeatMode: repeatMode ?? this.repeatMode,
      volume: volume ?? this.volume,
    );
  }

  @override
  List<Object?> get props => [
    status,
    currentSong,
    queue,
    position,
    duration,
    currentIndex,
    shuffleEnabled,
    repeatMode,
    volume,
  ];
}
