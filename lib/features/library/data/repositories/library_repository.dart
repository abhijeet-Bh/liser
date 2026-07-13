import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/database/hive_service.dart';
import 'package:liser/core/storage/services/music_storage_service.dart';
import 'package:path/path.dart' as p;
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

  Future<int>? _activeScanFuture;

  Future<int> scanLibrary() async {
    if (_activeScanFuture != null) {
      return _activeScanFuture!;
    }

    final completer = Completer<int>();
    _activeScanFuture = completer.future;

    try {
      final result = await _scanLibraryInternal();
      completer.complete(result);
      return result;
    } catch (e) {
      completer.completeError(e);
      rethrow;
    } finally {
      _activeScanFuture = null;
    }
  }

  Future<int> _scanLibraryInternal() async {
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
    
    final newSongs = <Song>[];
    final scannedPaths = <String>{};
    final migratedIds = <String, String>{};

    for (final file in files) {
      scannedPaths.add(file.path);
      final fileName = p.basename(file.path);
      
      final matches = existingSongs.where((s) => s.path == file.path || s.fileName == fileName || p.basename(s.path) == fileName).toList();
      
      if (matches.isNotEmpty) {
        final song = matches.first;
        bool needsSave = false;
        
        if (song.id == song.path || song.id.startsWith('/')) {
          final oldId = song.id;
          song.id = fileName;
          migratedIds[oldId] = fileName;
          needsSave = true;
        }
        
        if (song.path != file.path) {
          song.path = file.path;
          needsSave = true;
        }

        if (song.artworkPath != null) {
          final musicDir = await sl<MusicStorageService>().getMusicDirectory();
          final artworkDir = p.join(musicDir.parent.path, 'artwork');
          final newArtworkPath = p.join(artworkDir, p.basename(song.artworkPath!));
          if (song.artworkPath != newArtworkPath) {
            song.artworkPath = newArtworkPath;
            needsSave = true;
          }
        }
        
        if (needsSave) {
          await song.save();
        }
      } else {
        try {
          final song = await _metadataService.read(file);
          newSongs.add(song);
        } catch (e) {
          // Skip
        }
      }
    }

    final toRemove = existingSongs.where((s) => !scannedPaths.contains(s.path)).toList();
    for (final s in toRemove) {
      await s.delete();
    }

    if (newSongs.isNotEmpty) {
      await _box.addAll(newSongs);
    }
    
    // Cleanup and repair playlists
    final allValidFilenames = _box.values.map((s) => s.id).toSet();
    bool playlistsModified = false;
    
    for (final playlist in _playlistsBox.values) {
      bool playlistChanged = false;
      final newSongIds = <String>[];
      
      for (final id in playlist.songIds) {
        if (allValidFilenames.contains(id)) {
          newSongIds.add(id);
        } else {
          final extractedFilename = p.basename(id);
          if (allValidFilenames.contains(extractedFilename)) {
            newSongIds.add(extractedFilename);
            playlistChanged = true;
          } else {
            playlistChanged = true;
          }
        }
      }
      
      if (playlistChanged) {
        playlist.songIds = newSongIds;
        await playlist.save();
        playlistsModified = true;
      }
    }
    
    if (playlistsModified) {
      await _backupPlaylists();
    }

    await _restorePlaylists(scanPath);

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
    await _backupPlaylists();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await playlist.delete();
    await _backupPlaylists();
  }

  Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    if (!playlist.songIds.contains(song.id)) {
      playlist.songIds = List<String>.from(playlist.songIds)..add(song.id);
      await playlist.save();
      await _backupPlaylists();
    }
  }

  Future<void> removeSongFromPlaylist(Playlist playlist, Song song) async {
    if (playlist.songIds.contains(song.id)) {
      playlist.songIds = List<String>.from(playlist.songIds)..remove(song.id);
      await playlist.save();
      await _backupPlaylists();
    }
  }

  Future<void> setPlaylistCover(Playlist playlist, String coverPath) async {
    playlist.coverPath = coverPath;
    await playlist.save();
    await _backupPlaylists();
  }

  Future<void> reorderPlaylistSongs(Playlist playlist, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newList = List<String>.from(playlist.songIds);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    playlist.songIds = newList;
    await playlist.save();
    await _backupPlaylists();
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
    
    // Also clear backup
    final String? syncFolderPath = _syncService.getSyncFolderPath();
    String scanPath = syncFolderPath ?? (await sl<MusicStorageService>().getMusicDirectory()).path;
    final backupFile = File(p.join(scanPath, 'playlists_backup.json'));
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
  }

  Future<void> _backupPlaylists() async {
    final String? syncFolderPath = _syncService.getSyncFolderPath();
    String scanPath;
    if (syncFolderPath != null) {
      scanPath = syncFolderPath;
    } else {
      final musicDirectory = await sl<MusicStorageService>().getMusicDirectory();
      scanPath = musicDirectory.path;
    }
    
    final file = File(p.join(scanPath, 'playlists_backup.json'));
    final List<Map<String, dynamic>> data = _playlistsBox.values.map((pList) => {
      'id': pList.id,
      'name': pList.name,
      'songIds': pList.songIds,
      'createdAt': pList.createdAt.toIso8601String(),
      'coverPath': pList.coverPath,
    }).toList();
    
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> _restorePlaylists(String scanPath) async {
    if (_playlistsBox.isNotEmpty) return;
    
    final file = File(p.join(scanPath, 'playlists_backup.json'));
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final List<dynamic> data = jsonDecode(content);
        final playlists = data.map((json) => Playlist(
          id: json['id'] as String,
          name: json['name'] as String,
          songIds: List<String>.from(json['songIds'] ?? []),
          createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
          coverPath: json['coverPath'] as String?,
        )).toList();
        await _playlistsBox.addAll(playlists);
      } catch (e) {
        // Ignore backup restore errors
      }
    }
  }
}
