part of 'library_bloc.dart';

sealed class LibraryEvent {}

final class LoadLibrary extends LibraryEvent {}

final class AddSongs extends LibraryEvent {}

final class RemoveSong extends LibraryEvent {
  RemoveSong(this.song);
  final Song song;
}
