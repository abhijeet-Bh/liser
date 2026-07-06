import 'dart:io';

import 'package:hive/hive.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/database/hive_service.dart';
import 'package:liser/core/storage/services/music_storage_service.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/features/library/data/services/library_scanner.dart';
import 'package:liser/features/library/data/services/metadata_service.dart';
import 'package:liser/features/onboarding/data/services/import_service.dart';
import 'package:liser/features/onboarding/data/services/sync_service.dart';

class LibraryRepository {
  LibraryRepository({
    required LibraryScanner scanner,
    required MetadataService metadataService,
    required ImportService importService,
    required SyncService syncService,
  }) : _scanner = scanner,
       _metadataService = metadataService,
       _importService = importService,
       _syncService = syncService;

  final LibraryScanner _scanner;
  final MetadataService _metadataService;
  final ImportService _importService;
  final SyncService _syncService;

  final Box<Song> _box = sl<HiveService>().songsBox;
  final Box<Playlist> _playlistsBox = sl<HiveService>().playlistsBox;

  Future<int> scanLibrary() async {
    final String? syncFolderPath = _syncService.getSyncFolderPath();
    String scanPath;

    if (syncFolderPath != null) {
      scanPath = syncFolderPath;
    } else {
      final musicDirectory = await sl<MusicStorageService>().getMusicDirectory();
      scanPath = musicDirectory.path;
    }

    final files = await _scanner.scan(scanPath);

    final existingSongs = _box.values.toList();
    final existingPaths = existingSongs.map((s) => s.path).toSet();

    final newSongs = <Song>[];
    final scannedPaths = <String>{};

    for (final file in files) {
      scannedPaths.add(file.path);
      try {
        if (!existingPaths.contains(file.path)) {
          final song = await _metadataService.read(file);
          newSongs.add(song);
        }
      } catch (e) {
        // Skip files that fail metadata extraction
      }
    }

    // Remove songs that no longer exist
    final toRemove = existingSongs.where((s) => !scannedPaths.contains(s.path)).toList();
    for (final s in toRemove) {
      await s.delete();
    }

    if (newSongs.isNotEmpty) {
      await _box.addAll(newSongs);
    }

    return newSongs.length;
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

  Future<void> toggleFavorite(Song song) async {
    song.favorite = !song.favorite;
    await song.save();
  }

  Future<void> incrementPlayCount(Song song) async {
    song.playCount = (song.playCount) + 1;
    song.lastPlayed = DateTime.now();
    await song.save();
  }

  Future<List<Playlist>> getPlaylists() async {
    return _playlistsBox.values.toList();
  }

  Future<void> createPlaylist(String name) async {
    final playlist = Playlist(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    await _playlistsBox.add(playlist);
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await playlist.delete();
  }

  Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    if (!playlist.songIds.contains(song.id)) {
      playlist.songIds.add(song.id);
      await playlist.save();
    }
  }

  Future<void> removeSongFromPlaylist(Playlist playlist, Song song) async {
    if (playlist.songIds.contains(song.id)) {
      playlist.songIds.remove(song.id);
      await playlist.save();
    }
  }

  Future<void> setPlaylistCover(Playlist playlist, String coverPath) async {
    playlist.coverPath = coverPath;
    await playlist.save();
  }

  Future<void> reorderPlaylistSongs(Playlist playlist, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = playlist.songIds.removeAt(oldIndex);
    playlist.songIds.insert(newIndex, item);
    await playlist.save();
  }

  Future<void> clearLibrary() async {
    for (final song in _box.values.toList()) {
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
    }
    await _box.clear();
    await _playlistsBox.clear();
  }
}
