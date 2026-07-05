part of 'library_bloc.dart';

enum LibraryStatus { initial, loading, loaded, failure }

class LibraryState extends Equatable {
  const LibraryState({
    this.status = LibraryStatus.initial,
    this.songs = const [],
    this.error,
  });

  final LibraryStatus status;
  final List<Song> songs;
  final String? error;

  LibraryState copyWith({
    LibraryStatus? status,
    List<Song>? songs,
    String? error,
  }) {
    return LibraryState(
      status: status ?? this.status,
      songs: songs ?? this.songs,
      error: error,
    );
  }

  @override
  List<Object?> get props => [status, songs, error];
}
