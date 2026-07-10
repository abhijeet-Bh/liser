import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:liser/core/constants/supported_audio_extensions.dart';
import 'package:liser/core/storage/services/music_storage_service.dart';
import 'package:path/path.dart' as p;

class ImportService {
  ImportService({required MusicStorageService storageService})
    : _storageService = storageService;

  final MusicStorageService _storageService;

  Future<int> importMusic() async {
    if (Platform.isAndroid) {
      if (await Permission.audio.request().isGranted || await Permission.storage.request().isGranted) {
        // Permissions granted
      } else {
        return 0;
      }
    }

    final result = await FilePicker.pickFiles(
      allowMultiple: true,
      type: FileType.custom,
      allowedExtensions:
          SupportedAudioExtensions.values
              .map((e) => e.replaceFirst('.', ''))
              .toList(),
    );

    if (result == null || result.files.isEmpty) {
      return 0;
    }

    final musicDirectory = await _storageService.getMusicDirectory();

    int imported = 0;

    for (final pickedFile in result.files) {
      if (pickedFile.path == null) continue;

      final source = File(pickedFile.path!);

      if (!await source.exists()) continue;

      final destination = File(
        p.join(musicDirectory.path, p.basename(source.path)),
      );

      await source.copy(destination.path);

      imported++;
    }

    // Clear the cache to prevent duplicate file storage
    await FilePicker.clearTemporaryFiles();

    return imported;
  }
}
