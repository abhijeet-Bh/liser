part of 'onboarding_bloc.dart';

enum OnboardingStatus { initial, loading, folderSelected, error }

class OnboardingState extends Equatable {
  const OnboardingState({
    this.status = OnboardingStatus.initial,
    this.folderPath,
    this.error,
  });

  final OnboardingStatus status;
  final String? folderPath;
  final String? error;

  OnboardingState copyWith({
    OnboardingStatus? status,
    String? folderPath,
    String? error,
  }) {
    return OnboardingState(
      status: status ?? this.status,
      folderPath: folderPath ?? this.folderPath,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, folderPath, error];
}
