import 'package:drift/drift.dart' as drift;
import 'package:liser/core/storage/database/app_database.dart';

class Song {
  String id;
  String path;
  String fileName;
  String title;
  String artist;
  String album;
  String albumArtist;
  String genre;
  int trackNumber;
  int discNumber;
  int year;
  int duration;
  int fileSize;
  DateTime lastModified;
  bool favorite;
  int playCount;
  DateTime? lastPlayed;
  String? artworkPath;
  bool isLossless;
  DateTime dateAdded;
  String sourceMode;

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
    DateTime? dateAdded,
    this.sourceMode = 'local',
  }) : dateAdded = dateAdded ?? DateTime.now();

  factory Song.fromDrift(SongData data) {
    return Song(
      id: data.id,
      path: data.path,
      fileName: data.fileName,
      title: data.title,
      artist: data.artist,
      album: data.album,
      albumArtist: data.albumArtist,
      genre: data.genre,
      trackNumber: data.trackNumber,
      discNumber: data.discNumber,
      year: data.year,
      duration: data.duration,
      fileSize: data.fileSize,
      lastModified: data.lastModified,
      favorite: data.favorite,
      playCount: data.playCount,
      lastPlayed: data.lastPlayed,
      artworkPath: data.artworkPath,
      isLossless: data.isLossless,
      dateAdded: data.dateAdded,
      sourceMode: data.sourceMode,
    );
  }

  SongsCompanion toDriftCompanion() {
    return SongsCompanion(
      id: drift.Value(id),
      path: drift.Value(path),
      fileName: drift.Value(fileName),
      title: drift.Value(title),
      artist: drift.Value(artist),
      album: drift.Value(album),
      albumArtist: drift.Value(albumArtist),
      genre: drift.Value(genre),
      trackNumber: drift.Value(trackNumber),
      discNumber: drift.Value(discNumber),
      year: drift.Value(year),
      duration: drift.Value(duration),
      fileSize: drift.Value(fileSize),
      lastModified: drift.Value(lastModified),
      favorite: drift.Value(favorite),
      playCount: drift.Value(playCount),
      lastPlayed: drift.Value(lastPlayed),
      artworkPath: drift.Value(artworkPath),
      isLossless: drift.Value(isLossless),
      dateAdded: drift.Value(dateAdded),
      sourceMode: drift.Value(sourceMode),
    );
  }
}

