import 'package:drift/drift.dart' as drift;
import 'package:liser/core/storage/database/app_database.dart';

class Playlist {
  String id;
  String name;
  List<String> songIds;
  DateTime createdAt;
  String? coverPath;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    this.coverPath,
  });

  factory Playlist.fromDrift(PlaylistData data, {List<String>? songIds}) {
    return Playlist(
      id: data.id,
      name: data.name,
      songIds: songIds ?? [],
      createdAt: data.createdAt,
      coverPath: data.coverPath,
    );
  }

  PlaylistsCompanion toDriftCompanion() {
    return PlaylistsCompanion(
      id: drift.Value(id),
      name: drift.Value(name),
      createdAt: drift.Value(createdAt),
      coverPath: drift.Value(coverPath),
    );
  }
}

