import 'dart:io';

import 'package:hive/hive.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/database/hive_service.dart';
import 'package:liser/core/storage/services/music_storage_service.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/services/library_scanner.dart';
import 'package:liser/features/library/data/services/metadata_service.dart';
import 'package:liser/features/onboarding/data/services/import_service.dart';

class LibraryRepository {
  LibraryRepository({
    required LibraryScanner scanner,
    required MetadataService metadataService,
    required ImportService importService,
  }) : _scanner = scanner,
       _metadataService = metadataService,
       _importService = importService;

  final LibraryScanner _scanner;
  final MetadataService _metadataService;
  final ImportService _importService;

  final Box<Song> _box = sl<HiveService>().songsBox;

  Future<int> scanLibrary() async {
    final musicDirectory = await sl<MusicStorageService>().getMusicDirectory();

    final files = await _scanner.scan(musicDirectory.path);

    await _box.clear();

    final songs = <Song>[];

    for (final file in files) {
      try {
        final song = await _metadataService.read(file);
        songs.add(song);
      } catch (e) {
        // Skip files that fail metadata extraction
      }
    }

    await _box.addAll(songs);

    return songs.length;
  }

  Future<List<Song>> getSongs() async {
    return _box.values.toList();
  }

  Future<int> addSongs() async {
    final imported = await _importService.importMusic();
    if (imported > 0) {
      await scanLibrary();
    }
    return imported;
  }

  Future<void> removeSong(Song song) async {
    try {
      final audioFile = File(song.path);
      if (await audioFile.exists()) {
        await audioFile.delete();
      }

      if (song.artworkPath != null) {
        final artworkFile = File(song.artworkPath!);
        if (await artworkFile.exists()) {
          await artworkFile.delete();
        }
      }
    } catch (e) {
      // Ignore file deletion errors
    }

    await song.delete();
  }
}
