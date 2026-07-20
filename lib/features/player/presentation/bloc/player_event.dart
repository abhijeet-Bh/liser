part of 'player_bloc.dart';

sealed class PlayerEvent {
  const PlayerEvent();
}

/// Play a song from a queue.
final class PlaySong extends PlayerEvent {
  const PlaySong({required this.song, required this.queue});

  final Song song;
  final List<Song> queue;
}

/// Toggle play/pause.
final class TogglePlayPause extends PlayerEvent {
  const TogglePlayPause();
}

/// Play next song.
final class NextSong extends PlayerEvent {
  const NextSong();
}

/// Play previous song.
final class PreviousSong extends PlayerEvent {
  const PreviousSong();
}

/// Seek to a specific position.
final class SeekToPosition extends PlayerEvent {
  const SeekToPosition(this.position);

  final Duration position;
}

/// Replay current song.
final class ReplaySong extends PlayerEvent {
  const ReplaySong();
}

/// Toggle favourite.
final class ToggleFavorite extends PlayerEvent {
  const ToggleFavorite(this.song);

  final Song song;
}

/// Toggle shuffle.
final class ToggleShuffle extends PlayerEvent {
  const ToggleShuffle();
}

/// Toggle repeat mode.
final class ToggleRepeatMode extends PlayerEvent {
  const ToggleRepeatMode();
}

/// Open queue page.
final class OpenQueueRequested extends PlayerEvent {
  const OpenQueueRequested();
}

final class ReorderQueue extends PlayerEvent {
  const ReorderQueue(this.oldIndex, this.newIndex);
  final int oldIndex;
  final int newIndex;
}

final class ClearQueue extends PlayerEvent {
  const ClearQueue();
}

final class AddSongNext extends PlayerEvent {
  const AddSongNext(this.song);
  final Song song;
}

final class AddSongToEnd extends PlayerEvent {
  const AddSongToEnd(this.song);
  final Song song;
}

/// Set volume.
final class SetVolume extends PlayerEvent {
  const SetVolume(this.volume);
  final double volume;
}

/// Increase volume slightly.
final class IncreaseVolume extends PlayerEvent {
  const IncreaseVolume();
}

/// Decrease volume slightly.
final class DecreaseVolume extends PlayerEvent {
  const DecreaseVolume();
}

/// Internal events.

final class _PlayerStateChanged extends PlayerEvent {
  const _PlayerStateChanged(this.state);

  final PlayerState state;
}

final class _PositionChanged extends PlayerEvent {
  const _PositionChanged(this.position);

  final Duration position;
}

final class _DurationChanged extends PlayerEvent {
  const _DurationChanged(this.duration);

  final Duration? duration;
}

final class _CurrentSongChanged extends PlayerEvent {
  const _CurrentSongChanged(this.song);

  final Song? song;
}
