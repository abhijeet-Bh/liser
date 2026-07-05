import 'package:hive/hive.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/database/hive_service.dart';
import 'package:liser/core/storage/models/app_settings.dart';

class SettingsRepository {
  final Box<AppSettings> _box = sl<HiveService>().settingsBox;

  Future<AppSettings> getSettings() async {
    if (_box.isEmpty) {
      final settings = AppSettings();

      await _box.put('settings', settings);

      return settings;
    }

    return _box.get('settings')!;
  }

  Future<void> save(AppSettings settings) async {
    await _box.put('settings', settings);
  }
}
