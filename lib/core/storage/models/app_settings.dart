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

  @HiveField(5, defaultValue: 0)
  int themeMode; // 0=system, 1=light, 2=dark

  @HiveField(6, defaultValue: 0)
  int themeColorId; // 0=Purple, 1=Blue, 2=Emerald

  @HiveField(7)
  String? userName;

  @HiveField(8)
  String? userPhotoPath;

  AppSettings({
    this.musicFolder,
    this.autoSync = true,
    this.dynamicColors = true,
    this.darkMode = false,
    this.firstLaunch = true,
    this.themeMode = 0,
    this.themeColorId = 0,
    this.userName,
    this.userPhotoPath,
  });
}
