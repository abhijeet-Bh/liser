part of 'app_bloc.dart';

sealed class AppEvent {
  const AppEvent();
}

final class AppStarted extends AppEvent {}

final class UpdateThemeMode extends AppEvent {
  const UpdateThemeMode(this.themeMode);
  final int themeMode;
}

final class UpdateThemeColor extends AppEvent {
  const UpdateThemeColor(this.themeColorId);
  final int themeColorId;
}

final class UpdateProfile extends AppEvent {
  const UpdateProfile({this.userName, this.userPhotoPath});
  final String? userName;
  final String? userPhotoPath;
}
