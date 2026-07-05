import 'dart:io';

import 'package:liser/core/constants/supported_audio_extensions.dart';

class LibraryScanner {
  Future<List<File>> scan(String folderPath) async {
    final root = Directory(folderPath);

    if (!await root.exists()) {
      return [];
    }

    final List<File> files = [];

    await for (final entity in root.list(recursive: true)) {
      if (entity is! File) continue;

      final path = entity.path.toLowerCase();

      final supported = SupportedAudioExtensions.values.any(path.endsWith);

      if (supported) {
        files.add(entity);
      }
    }

    return files;
  }
}
