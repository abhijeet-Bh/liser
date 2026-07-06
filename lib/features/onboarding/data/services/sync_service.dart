import 'package:file_picker/file_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SyncService {
  SyncService({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  final SharedPreferences _sharedPreferences;
  static const String _syncFolderPathKey = 'sync_folder_path';

  Future<String?> selectSyncFolder() async {
    final String? directoryPath = await FilePicker.getDirectoryPath();

    if (directoryPath != null) {
      await _sharedPreferences.setString(_syncFolderPathKey, directoryPath);
      return directoryPath;
    }

    return null;
  }

  String? getSyncFolderPath() {
    return _sharedPreferences.getString(_syncFolderPathKey);
  }

  Future<void> clearSyncFolder() async {
    await _sharedPreferences.remove(_syncFolderPathKey);
  }
}
