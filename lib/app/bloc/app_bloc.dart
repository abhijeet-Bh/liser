import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/models/app_settings.dart';
import 'package:liser/core/storage/repositories/settings_repository.dart';

part 'app_event.dart';
part 'app_state.dart';

class AppBloc extends Bloc<AppEvent, AppState> {
  AppBloc() : super(const AppState()) {
    on<AppStarted>(_onStarted);
    on<UpdateThemeMode>(_onUpdateThemeMode);
    on<UpdateThemeColor>(_onUpdateThemeColor);
    on<UpdateProfile>(_onUpdateProfile);
  }

  Future<void> _onStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));

    final settings = await sl<SettingsRepository>().getSettings();

    emit(state.copyWith(status: AppStatus.ready, settings: settings));
  }

  Future<void> _onUpdateThemeMode(UpdateThemeMode event, Emitter<AppState> emit) async {
    final settings = state.settings;
    if (settings != null) {
      settings.themeMode = event.themeMode;
      await settings.save();
      emit(state.copyWith(
        settings: settings, 
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      )); 
    }
  }

  Future<void> _onUpdateThemeColor(UpdateThemeColor event, Emitter<AppState> emit) async {
    final settings = state.settings;
    if (settings != null) {
      settings.themeColorId = event.themeColorId;
      await settings.save();
      emit(state.copyWith(
        settings: settings, 
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      )); 
    }
  }

  Future<void> _onUpdateProfile(UpdateProfile event, Emitter<AppState> emit) async {
    final settings = state.settings;
    if (settings != null) {
      if (event.userName != null) settings.userName = event.userName;
      if (event.userPhotoPath != null) settings.userPhotoPath = event.userPhotoPath;
      await settings.save();
      emit(state.copyWith(
        settings: settings, 
        lastUpdated: DateTime.now().millisecondsSinceEpoch
      )); 
    }
  }
}
