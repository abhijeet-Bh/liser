import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:liser/features/onboarding/data/services/sync_service.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({
    required LibraryRepository repository,
    required SyncService syncService,
  })  : _repository = repository,
        _syncService = syncService,
        super(const LibraryState()) {
    on<LoadLibrary>(_onLoadLibrary);
    on<AddSongs>(_onAddSongs);
    on<RemoveSong>(_onRemoveSong);
    on<SyncLibraryFolder>(_onSyncLibraryFolder);
    on<LibraryToggleFavorite>(_onToggleFavorite);
    on<CreatePlaylist>(_onCreatePlaylist);
    on<DeletePlaylist>(_onDeletePlaylist);
    on<AddSongToPlaylist>(_onAddSongToPlaylist);
    on<RemoveSongFromPlaylist>(_onRemoveSongFromPlaylist);
  }

  final LibraryRepository _repository;
  final SyncService _syncService;

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
    emit(state.copyWith(status: LibraryStatus.loading));

    try {
      await _repository.scanLibrary();

      final songs = await _repository.getSongs();
      final playlists = await _repository.getPlaylists();

      emit(state.copyWith(status: LibraryStatus.loaded, songs: songs, playlists: playlists));
    } catch (e) {
      emit(state.copyWith(status: LibraryStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onAddSongs(
    AddSongs event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.addSongs();
      final songs = await _repository.getSongs();
      emit(state.copyWith(status: LibraryStatus.loaded, songs: songs));
    } catch (e) {
      emit(state.copyWith(status: LibraryStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onRemoveSong(
    RemoveSong event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.removeSong(event.song);
      final songs = await _repository.getSongs();
      emit(state.copyWith(status: LibraryStatus.loaded, songs: songs));
    } catch (e) {
      emit(state.copyWith(status: LibraryStatus.failure, error: e.toString()));
    }
  }

  Future<void> _onSyncLibraryFolder(
    SyncLibraryFolder event,
    Emitter<LibraryState> emit,
  ) async {
    final folderPath = await _syncService.selectSyncFolder();
    if (folderPath != null) {
      emit(state.copyWith(status: LibraryStatus.loading));
      try {
        await _repository.scanLibrary();
        final songs = await _repository.getSongs();
        emit(state.copyWith(status: LibraryStatus.loaded, songs: songs));
      } catch (e) {
        emit(state.copyWith(status: LibraryStatus.failure, error: e.toString()));
      }
    }
  }

  Future<void> _onToggleFavorite(
    LibraryToggleFavorite event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.toggleFavorite(event.song);
      final songs = await _repository.getSongs();
      emit(state.copyWith(songs: songs));
    } catch (e) {
      // Handle error if needed
    }
  }

  Future<void> _onCreatePlaylist(
    CreatePlaylist event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.createPlaylist(event.name);
      final playlists = await _repository.getPlaylists();
      emit(state.copyWith(playlists: playlists));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onDeletePlaylist(
    DeletePlaylist event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.deletePlaylist(event.playlist);
      final playlists = await _repository.getPlaylists();
      emit(state.copyWith(playlists: playlists));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onAddSongToPlaylist(
    AddSongToPlaylist event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.addSongToPlaylist(event.playlist, event.song);
      final playlists = await _repository.getPlaylists();
      emit(state.copyWith(playlists: playlists));
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _onRemoveSongFromPlaylist(
    RemoveSongFromPlaylist event,
    Emitter<LibraryState> emit,
  ) async {
    try {
      await _repository.removeSongFromPlaylist(event.playlist, event.song);
      final playlists = await _repository.getPlaylists();
      emit(state.copyWith(playlists: playlists));
    } catch (e) {
      // Handle error
    }
  }
}
