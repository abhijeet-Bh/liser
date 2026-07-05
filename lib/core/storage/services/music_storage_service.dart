import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class MusicStorageService {
  static const _musicDirectory = 'Music';

  Future<Directory> getMusicDirectory() async {
    final documents = await getApplicationDocumentsDirectory();

    final musicDirectory = Directory(p.join(documents.path, _musicDirectory));

    if (!await musicDirectory.exists()) {
      await musicDirectory.create(recursive: true);
    }

    return musicDirectory;
  }
}
