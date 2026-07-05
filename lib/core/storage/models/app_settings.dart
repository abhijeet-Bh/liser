import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 0)
class AppSettings extends HiveObject {
  @HiveField(0)
  String? musicFolder; // Deprecated, keep for compatibility

  @HiveField(1)
  bool autoSync;

  @HiveField(2)
  bool dynamicColors;

  @HiveField(3)
  bool darkMode;

  @HiveField(4)
  bool firstLaunch;

  AppSettings({
    this.musicFolder,
    this.autoSync = true,
    this.dynamicColors = true,
    this.darkMode = false,
    this.firstLaunch = true,
  });
}
