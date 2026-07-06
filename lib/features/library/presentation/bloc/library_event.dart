part of 'library_bloc.dart';

sealed class LibraryEvent {}

final class LoadLibrary extends LibraryEvent {}

final class AddSongs extends LibraryEvent {}

final class RemoveSong extends LibraryEvent {
  RemoveSong(this.song);
  final Song song;
}

final class SyncLibraryFolder extends LibraryEvent {}

final class LibraryToggleFavorite extends LibraryEvent {
  LibraryToggleFavorite(this.song);
  final Song song;
}

final class CreatePlaylist extends LibraryEvent {
  CreatePlaylist(this.name);
  final String name;
}

final class DeletePlaylist extends LibraryEvent {
  DeletePlaylist(this.playlist);
  final Playlist playlist;
}

final class AddSongToPlaylist extends LibraryEvent {
  AddSongToPlaylist(this.playlist, this.song);
  final Playlist playlist;
  final Song song;
}

final class RemoveSongFromPlaylist extends LibraryEvent {
  RemoveSongFromPlaylist(this.playlist, this.song);
  final Playlist playlist;
  final Song song;
}
