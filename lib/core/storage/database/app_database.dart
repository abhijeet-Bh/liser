import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

part 'app_database.g.dart';

@DataClassName('SongData')
class Songs extends Table {
  TextColumn get id => text()();
  TextColumn get path => text()();
  TextColumn get fileName => text()();
  TextColumn get title => text()();
  TextColumn get artist => text()();
  TextColumn get album => text()();
  TextColumn get albumArtist => text()();
  TextColumn get genre => text()();
  IntColumn get trackNumber => integer()();
  IntColumn get discNumber => integer()();
  IntColumn get year => integer()();
  IntColumn get duration => integer()();
  IntColumn get fileSize => integer()();
  DateTimeColumn get lastModified => dateTime()();
  BoolColumn get favorite => boolean().withDefault(const Constant(false))();
  IntColumn get playCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get lastPlayed => dateTime().nullable()();
  TextColumn get artworkPath => text().nullable()();
  BoolColumn get isLossless => boolean().withDefault(const Constant(false))();
  DateTimeColumn get dateAdded => dateTime().withDefault(currentDateAndTime)();
  TextColumn get sourceMode => text().withDefault(const Constant('local'))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PlaylistData')
class Playlists extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get coverPath => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class PlaylistSongs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get playlistId => text().references(Playlists, #id, onDelete: KeyAction.cascade)();
  TextColumn get songId => text().references(Songs, #id, onDelete: KeyAction.cascade)();
  IntColumn get position => integer()();
}

@DriftDatabase(tables: [Songs, Playlists, PlaylistSongs])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  // Songs Queries
  Future<List<SongData>> getAllSongs() => select(songs).get();
  Stream<List<SongData>> watchAllSongs() => select(songs).watch();

  Future<SongData?> getSongById(String id) =>
      (select(songs)..where((tbl) => tbl.id.equals(id))).getSingleOrNull();

  Future<void> insertSong(SongsCompanion song) => into(songs).insertOnConflictUpdate(song);
  Future<void> insertSongs(List<SongsCompanion> songList) =>
      batch((b) => b.insertAllOnConflictUpdate(songs, songList));

  Future<void> updateSong(SongsCompanion song) => update(songs).replace(song);
  Future<void> deleteSong(String id) => (delete(songs)..where((tbl) => tbl.id.equals(id))).go();
  Future<void> deleteAllSongs() => delete(songs).go();

  // Custom Song Sorting & Filtering Queries
  Future<List<SongData>> getRecentlyAddedSongs({int limit = 50}) {
    return (select(songs)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dateAdded, mode: OrderingMode.desc)])
      ..limit(limit))
        .get();
  }

  Stream<List<SongData>> watchRecentlyAddedSongs({int limit = 50}) {
    return (select(songs)
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.dateAdded, mode: OrderingMode.desc)])
      ..limit(limit))
        .watch();
  }

  Stream<List<SongData>> watchSongsBySourceMode(String mode) {
    return (select(songs)
      ..where((tbl) => tbl.sourceMode.equals(mode))
      ..orderBy([(tbl) => OrderingTerm(expression: tbl.title, mode: OrderingMode.asc)]))
        .watch();
  }

  // Playlists Queries
  Future<List<PlaylistData>> getAllPlaylists() => select(playlists).get();
  Stream<List<PlaylistData>> watchAllPlaylists() => select(playlists).watch();

  Future<void> insertPlaylist(PlaylistsCompanion playlist) =>
      into(playlists).insertOnConflictUpdate(playlist);

  Future<void> updatePlaylistCover(String id, String coverPath) =>
      (update(playlists)..where((tbl) => tbl.id.equals(id)))
          .write(PlaylistsCompanion(coverPath: Value(coverPath)));

  Future<void> deletePlaylist(String id) =>
      (delete(playlists)..where((tbl) => tbl.id.equals(id))).go();

  Future<void> deleteAllPlaylists() => delete(playlists).go();

  // Playlist Songs Queries
  Future<List<SongData>> getSongsForPlaylist(String playlistId) async {
    final query = select(playlistSongs).join([
      innerJoin(songs, songs.id.equalsExp(playlistSongs.songId)),
    ])
      ..where(playlistSongs.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistSongs.position)]);

    final rows = await query.get();
    return rows.map((row) => row.readTable(songs)).toList();
  }

  Stream<List<SongData>> watchSongsForPlaylist(String playlistId) {
    final query = select(playlistSongs).join([
      innerJoin(songs, songs.id.equalsExp(playlistSongs.songId)),
    ])
      ..where(playlistSongs.playlistId.equals(playlistId))
      ..orderBy([OrderingTerm.asc(playlistSongs.position)]);

    return query.watch().map((rows) => rows.map((row) => row.readTable(songs)).toList());
  }

  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    final existing = await (select(playlistSongs)
          ..where((tbl) => tbl.playlistId.equals(playlistId))
          ..orderBy([(tbl) => OrderingTerm.desc(tbl.position)]))
        .get();

    final nextPosition = existing.isEmpty ? 0 : existing.first.position + 1;

    await into(playlistSongs).insert(
      PlaylistSongsCompanion.insert(
        playlistId: playlistId,
        songId: songId,
        position: nextPosition,
      ),
    );
  }

  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    await (delete(playlistSongs)
          ..where((tbl) => tbl.playlistId.equals(playlistId) & tbl.songId.equals(songId)))
        .go();
  }

  Future<void> setPlaylistSongOrder(String playlistId, List<String> songIds) async {
    await transaction(() async {
      await (delete(playlistSongs)..where((tbl) => tbl.playlistId.equals(playlistId))).go();
      for (int i = 0; i < songIds.length; i++) {
        await into(playlistSongs).insert(
          PlaylistSongsCompanion.insert(
            playlistId: playlistId,
            songId: songIds[i],
            position: i,
          ),
        );
      }
    });
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(p.join(dbFolder.path, 'liser_db.sqlite'));
    return NativeDatabase.createInBackground(file);
  });
}
