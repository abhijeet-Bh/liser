part of 'app_bloc.dart';

enum AppStatus { initial, loading, ready, failure }

class AppState extends Equatable {
  const AppState({this.status = AppStatus.initial, this.settings, this.lastUpdated});

  final AppStatus status;
  final AppSettings? settings;
  final int? lastUpdated;

  AppState copyWith({AppStatus? status, AppSettings? settings, int? lastUpdated}) {
    return AppState(
      status: status ?? this.status,
      settings: settings ?? this.settings,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  List<Object?> get props => [status, settings, lastUpdated];
}
