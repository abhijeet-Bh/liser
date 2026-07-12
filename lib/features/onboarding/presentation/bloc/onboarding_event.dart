part of 'onboarding_bloc.dart';

sealed class OnboardingEvent {}

final class PickMusicFolderPressed extends OnboardingEvent {}

final class SyncFolderPressed extends OnboardingEvent {}

class SkipOnboarding extends OnboardingEvent {}
