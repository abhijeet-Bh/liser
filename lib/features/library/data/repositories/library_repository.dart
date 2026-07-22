import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:drift/drift.dart';
import 'package:hive/hive.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/database/app_database.dart';
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
    AppDatabase? db,
  })  : _scanner = scanner,
        _metadataService = metadataService,
        _importService = importService,
        _syncService = syncService,
        _db = db ?? sl<AppDatabase>() {
    _initMigration();
  }

  final LibraryScanner _scanner;
  final MetadataService _metadataService;
  final ImportService _importService;
  final SyncService _syncService;
  final AppDatabase _db;

  Future<int>? _activeScanFuture;

  Future<void> _initMigration() async {
    await _migrateFromHiveToDrift();
  }

  Future<void> _migrateFromHiveToDrift() async {
    try {
      if (await Hive.boxExists('songs')) {
        try {
          final box = await Hive.openBox<dynamic>('songs');
          if (box.isNotEmpty) {
            final List<SongsCompanion> companions = [];
            for (final value in box.values) {
              if (value != null) {
                try {
                  final id = value.id?.toString() ?? value['id']?.toString() ?? '';
                  if (id.isEmpty) continue;
                  companions.add(
                    SongsCompanion(
                      id: Value(id),
                      path: Value(value.path?.toString() ?? ''),
                      fileName: Value(value.fileName?.toString() ?? ''),
                      title: Value(value.title?.toString() ?? ''),
                      artist: Value(value.artist?.toString() ?? ''),
                      album: Value(value.album?.toString() ?? ''),
                      albumArtist: Value(value.albumArtist?.toString() ?? ''),
                      genre: Value(value.genre?.toString() ?? ''),
                      trackNumber: Value(int.tryParse(value.trackNumber?.toString() ?? '0') ?? 0),
                      discNumber: Value(int.tryParse(value.discNumber?.toString() ?? '0') ?? 0),
                      year: Value(int.tryParse(value.year?.toString() ?? '0') ?? 0),
                      duration: Value(int.tryParse(value.duration?.toString() ?? '0') ?? 0),
                      fileSize: Value(int.tryParse(value.fileSize?.toString() ?? '0') ?? 0),
                      lastModified: Value(value.lastModified as DateTime? ?? DateTime.now()),
                      favorite: Value(value.favorite as bool? ?? false),
                      playCount: Value(value.playCount as int? ?? 0),
                      lastPlayed: Value(value.lastPlayed as DateTime?),
                      artworkPath: Value(value.artworkPath?.toString()),
                      isLossless: Value(value.isLossless as bool? ?? false),
                      dateAdded: Value(value.lastModified as DateTime? ?? DateTime.now()),
                      sourceMode: Value('local'),
                    ),
                  );
                } catch (_) {}
              }
            }
            if (companions.isNotEmpty) {
              await _db.insertSongs(companions);
            }
            await box.clear();
            await box.close();
          }
        } catch (_) {}
        try {
          await Hive.deleteBoxFromDisk('songs');
        } catch (_) {}
      }

      if (await Hive.boxExists('playlists')) {
        try {
          final box = await Hive.openBox<dynamic>('playlists');
          if (box.isNotEmpty) {
            for (final value in box.values) {
              if (value != null) {
                try {
                  final id = value.id?.toString() ?? value['id']?.toString() ?? '';
                  final name = value.name?.toString() ?? '';
                  final songIds = (value.songIds as List?)?.map((e) => e.toString()).toList() ?? [];
                  if (id.isNotEmpty) {
                    await _db.insertPlaylist(PlaylistsCompanion(
                      id: Value(id),
                      name: Value(name),
                      createdAt: Value(value.createdAt as DateTime? ?? DateTime.now()),
                      coverPath: Value(value.coverPath?.toString()),
                    ));
                    for (int i = 0; i < songIds.length; i++) {
                      await _db.addSongToPlaylist(id, songIds[i]);
                    }
                  }
                } catch (_) {}
              }
            }
            await box.clear();
            await box.close();
          }
        } catch (_) {}
        try {
          await Hive.deleteBoxFromDisk('playlists');
        } catch (_) {}
      }
    } catch (_) {
      // Ignore migration errors
    }
  }

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
    final existingSongDatas = await _db.getAllSongs();
    final existingSongs = existingSongDatas.map(Song.fromDrift).toList();
    
    final newSongs = <Song>[];
    final scannedPaths = <String>{};

    for (final file in files) {
      scannedPaths.add(file.path);
      final fileName = p.basename(file.path);
      
      final matches = existingSongs.where((s) => s.path == file.path || s.fileName == fileName || p.basename(s.path) == fileName).toList();
      
      if (matches.isNotEmpty) {
        final song = matches.first;
        bool needsSave = false;
        
        if (song.id == song.path || song.id.startsWith('/')) {
          song.id = fileName;
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
          await _db.insertSong(song.toDriftCompanion());
        }
      } else {
        try {
          final song = await _metadataService.read(file);
          newSongs.add(song);
        } catch (_) {
          // Skip file if unreadable
        }
      }
    }

    final toRemove = existingSongs.where((s) => !scannedPaths.contains(s.path)).toList();
    for (final s in toRemove) {
      await _db.deleteSong(s.id);
    }

    if (newSongs.isNotEmpty) {
      await _db.insertSongs(newSongs.map((s) => s.toDriftCompanion()).toList());
    }

    await _restorePlaylists(scanPath);

    return newSongs.length;
  }

  Future<List<Song>> getSongs() async {
    final list = await _db.getAllSongs();
    return list.map(Song.fromDrift).toList();
  }

  Stream<List<Song>> watchSongs() {
    return _db.watchAllSongs().map((list) => list.map(Song.fromDrift).toList());
  }

  Stream<List<Song>> watchSongsBySourceMode(String mode) {
    return _db.watchSongsBySourceMode(mode).map((list) => list.map(Song.fromDrift).toList());
  }

  Stream<List<Song>> watchRecentlyAddedSongs({int limit = 50}) {
    return _db.watchRecentlyAddedSongs(limit: limit).map((list) => list.map(Song.fromDrift).toList());
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
    } catch (_) {
      // Ignore file deletion errors
    }

    await _db.deleteSong(song.id);
  }

  Future<void> toggleFavorite(Song song) async {
    song.favorite = !song.favorite;
    await _db.insertSong(song.toDriftCompanion());
  }

  Future<void> incrementPlayCount(Song song) async {
    song.playCount = song.playCount + 1;
    song.lastPlayed = DateTime.now();
    await _db.insertSong(song.toDriftCompanion());
  }

  Future<List<Playlist>> getPlaylists() async {
    final pDataList = await _db.getAllPlaylists();
    final playlists = <Playlist>[];
    for (final pData in pDataList) {
      final sDataList = await _db.getSongsForPlaylist(pData.id);
      playlists.add(Playlist.fromDrift(
        pData,
        songIds: sDataList.map((s) => s.id).toList(),
      ));
    }
    return playlists;
  }

  Stream<List<Playlist>> watchPlaylists() {
    final controller = StreamController<List<Playlist>>();
    StreamSubscription? sub1;
    StreamSubscription? sub2;

    void update() async {
      try {
        final playlists = await getPlaylists();
        if (!controller.isClosed) {
          controller.add(playlists);
        }
      } catch (_) {}
    }

    sub1 = _db.select(_db.playlists).watch().listen((_) => update());
    sub2 = _db.select(_db.playlistSongs).watch().listen((_) => update());

    controller.onCancel = () {
      sub1?.cancel();
      sub2?.cancel();
    };

    update();

    return controller.stream;
  }

  Future<void> createPlaylist(String name) async {
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final playlist = Playlist(
      id: id,
      name: name,
      songIds: [],
      createdAt: DateTime.now(),
    );
    await _db.insertPlaylist(playlist.toDriftCompanion());
    await _backupPlaylists();
  }

  Future<void> deletePlaylist(Playlist playlist) async {
    await _db.deletePlaylist(playlist.id);
    await _backupPlaylists();
  }

  Future<void> addSongToPlaylist(Playlist playlist, Song song) async {
    await _db.addSongToPlaylist(playlist.id, song.id);
    await _backupPlaylists();
  }

  Future<void> removeSongFromPlaylist(Playlist playlist, Song song) async {
    await _db.removeSongFromPlaylist(playlist.id, song.id);
    await _backupPlaylists();
  }

  Future<void> setPlaylistCover(Playlist playlist, String coverPath) async {
    playlist.coverPath = coverPath;
    await _db.updatePlaylistCover(playlist.id, coverPath);
    await _backupPlaylists();
  }

  Future<void> reorderPlaylistSongs(Playlist playlist, int oldIndex, int newIndex) async {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final newList = List<String>.from(playlist.songIds);
    final item = newList.removeAt(oldIndex);
    newList.insert(newIndex, item);
    await _db.setPlaylistSongOrder(playlist.id, newList);
    await _backupPlaylists();
  }

  Future<void> clearLibrary() async {
    final songDatas = await _db.getAllSongs();
    for (final sData in songDatas) {
      try {
        final audioFile = File(sData.path);
        if (await audioFile.exists()) {
          await audioFile.delete();
        }
        if (sData.artworkPath != null) {
          final artworkFile = File(sData.artworkPath!);
          if (await artworkFile.exists()) {
            await artworkFile.delete();
          }
        }
      } catch (_) {
        // Ignore file deletion errors
      }
    }
    await _db.deleteAllSongs();
    await _db.deleteAllPlaylists();

    final String? syncFolderPath = _syncService.getSyncFolderPath();
    String scanPath = syncFolderPath ?? (await sl<MusicStorageService>().getMusicDirectory()).path;
    final backupFile = File(p.join(scanPath, 'playlists_backup.json'));
    if (await backupFile.exists()) {
      await backupFile.delete();
    }
  }

  Future<void> _backupPlaylists() async {
    final playlists = await getPlaylists();
    final String? syncFolderPath = _syncService.getSyncFolderPath();
    String scanPath = syncFolderPath ?? (await sl<MusicStorageService>().getMusicDirectory()).path;
    
    final file = File(p.join(scanPath, 'playlists_backup.json'));
    final List<Map<String, dynamic>> data = playlists.map((pList) => {
      'id': pList.id,
      'name': pList.name,
      'songIds': pList.songIds,
      'createdAt': pList.createdAt.toIso8601String(),
      'coverPath': pList.coverPath,
    }).toList();
    
    await file.writeAsString(jsonEncode(data));
  }

  Future<void> _restorePlaylists(String scanPath) async {
    final currentPlaylists = await _db.getAllPlaylists();
    if (currentPlaylists.isNotEmpty) return;
    
    final file = File(p.join(scanPath, 'playlists_backup.json'));
    if (await file.exists()) {
      try {
        final content = await file.readAsString();
        final List<dynamic> data = jsonDecode(content);
        for (final json in data) {
          final id = json['id'] as String;
          final name = json['name'] as String;
          final songIds = List<String>.from(json['songIds'] ?? []);
          final createdAt = DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now();
          final coverPath = json['coverPath'] as String?;

          await _db.insertPlaylist(PlaylistsCompanion(
            id: Value(id),
            name: Value(name),
            createdAt: Value(createdAt),
            coverPath: Value(coverPath),
          ));

          for (final sId in songIds) {
            await _db.addSongToPlaylist(id, sId);
          }
        }
      } catch (_) {
        // Ignore backup restore errors
      }
    }
  }
}

