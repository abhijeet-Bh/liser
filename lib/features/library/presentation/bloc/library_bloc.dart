import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';

part 'library_event.dart';
part 'library_state.dart';

class LibraryBloc extends Bloc<LibraryEvent, LibraryState> {
  LibraryBloc({required LibraryRepository repository})
    : _repository = repository,
      super(const LibraryState()) {
    on<LoadLibrary>(_onLoadLibrary);
  }

  final LibraryRepository _repository;

  Future<void> _onLoadLibrary(
    LoadLibrary event,
    Emitter<LibraryState> emit,
  ) async {
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
