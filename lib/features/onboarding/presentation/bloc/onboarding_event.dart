part of 'onboarding_bloc.dart';

sealed class OnboardingEvent {}

final class PickMusicFolderPressed extends OnboardingEvent {}

class SkipOnboarding extends OnboardingEvent {}
