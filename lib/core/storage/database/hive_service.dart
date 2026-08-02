import 'package:hive_flutter/hive_flutter.dart';
import 'package:liser/core/storage/models/app_settings.dart';

class HiveService {
  static const String settingsBoxName = 'settings';

  Future<void> init() async {
    await Hive.initFlutter();

    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(AppSettingsAdapter());
    }

    await Hive.openBox<AppSettings>(settingsBoxName);
  }

  Box<AppSettings> get settingsBox => Hive.box<AppSettings>(settingsBoxName);
}

