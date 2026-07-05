import 'package:hive_flutter/hive_flutter.dart';
import 'package:liser/core/storage/models/app_settings.dart';
import 'package:liser/features/library/data/models/song.dart';

class HiveService {
  static const String settingsBoxName = 'settings';
  static const String songsBoxName = 'songs';

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(SongAdapter());

    await Hive.openBox<AppSettings>(settingsBoxName);
    await Hive.openBox<Song>(songsBoxName);
  }

  Box<AppSettings> get settingsBox => Hive.box<AppSettings>(settingsBoxName);

  Box<Song> get songsBox => Hive.box<Song>(songsBoxName);
}
