import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/features/onboarding/data/repositories/onboarding_repository.dart';

part 'onboarding_event.dart';
part 'onboarding_state.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  OnboardingBloc({required OnboardingRepository repository})
    : _repository = repository,
      super(const OnboardingState()) {
    on<PickMusicFolderPressed>(_pickFolder);
    on<SkipOnboarding>(_skipOnboarding);
  }

  final OnboardingRepository _repository;

  Future<void> _pickFolder(
    PickMusicFolderPressed event,
    Emitter<OnboardingState> emit,
  ) async {
    emit(state.copyWith(status: OnboardingStatus.loading));

    try {
      final imported = await _repository.importMusic();

      if (imported == 0) {
        emit(const OnboardingState());
        return;
      }

      emit(state.copyWith(status: OnboardingStatus.folderSelected));
    } catch (e) {
      emit(state.copyWith(status: OnboardingStatus.error, error: e.toString()));
    }
  }

  Future<void> _skipOnboarding(
    SkipOnboarding event,
    Emitter<OnboardingState> emit,
  ) async {
    await _repository.skipOnboarding();
    emit(state.copyWith(status: OnboardingStatus.folderSelected));
  }
}
