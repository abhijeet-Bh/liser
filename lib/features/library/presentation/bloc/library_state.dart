part of 'library_bloc.dart';

enum LibraryStatus { initial, loading, loaded, failure }

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LibraryStatus.initial,
    this.songs = const [],
    this.playlists = const [],
    this.error,
  });

  final LibraryStatus status;
  final List<Song> songs;
  final List<Playlist> playlists;
  final String? error;

  LibraryState copyWith({
    LibraryStatus? status,
    List<Song>? songs,
    List<Playlist>? playlists,
    String? error,
  }) {
    return LibraryState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      playlists: playlists ?? this.playlists,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, songs, playlists, error];
}
