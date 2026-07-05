import 'package:hive/hive.dart';

part 'song.g.dart';

@HiveType(typeId: 1)
class Song extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String path;

  @HiveField(2)
  String fileName;

  @HiveField(3)
  String title;

  @HiveField(4)
  String artist;

  @HiveField(5)
  String album;

  @HiveField(6)
  String albumArtist;

  @HiveField(7)
  String genre;

  @HiveField(8)
  int trackNumber;

  @HiveField(9)
  int discNumber;

  @HiveField(10)
  int year;

  @HiveField(11)
  int duration;

  @HiveField(12)
  int fileSize;

  @HiveField(13)
  DateTime lastModified;

  @HiveField(14)
  bool favorite;

  @HiveField(15)
  int playCount;

  @HiveField(16)
  DateTime? lastPlayed;

  @HiveField(17)
  String? artworkPath;

  @HiveField(18)
  bool isLossless;

  Song({
    required this.id,
    required this.path,
    required this.fileName,
    required this.title,
    required this.artist,
    required this.album,
    required this.albumArtist,
    required this.genre,
    required this.trackNumber,
    required this.discNumber,
    required this.year,
    required this.duration,
    required this.fileSize,
    required this.lastModified,
    this.favorite = false,
    this.playCount = 0,
    this.lastPlayed,
    this.artworkPath,
    this.isLossless = false,
  });
}
