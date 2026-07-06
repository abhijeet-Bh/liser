import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 2)
class Playlist extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  List<String> songIds;

  @HiveField(3)
  DateTime createdAt;

  @HiveField(4)
  String? coverPath;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    this.coverPath,
  });
}
