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
  }

  Future<void> _onStarted(AppStarted event, Emitter<AppState> emit) async {
    emit(state.copyWith(status: AppStatus.loading));

    final settings = await sl<SettingsRepository>().getSettings();

    emit(state.copyWith(status: AppStatus.ready, settings: settings));
  }
}
