part of 'app_bloc.dart';

enum AppStatus { initial, loading, ready, failure }

class AppState extends Equatable {
  const AppState({this.status = AppStatus.initial, this.settings});

  final AppStatus status;
  final AppSettings? settings;

  AppState copyWith({AppStatus? status, AppSettings? settings}) {
    return AppState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
    );
  }

  @override
  List<Object?> get props => [status, settings];
}
