import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/services/artwork_cache_service.dart';

class MetadataService {
  Future<Song> read(File file) async {
    final metadata = readMetadata(file, getImage: true);

    final artworkPath = await sl<ArtworkCacheService>().saveArtwork(
      file.path,
      metadata.pictures.isNotEmpty ? metadata.pictures.first.bytes : null,
    );

    return Song(
      id: file.uri.pathSegments.last,
      path: file.path,
      fileName: file.uri.pathSegments.last,
      title: metadata.title?.trim().isNotEmpty == true
              ? metadata.title!
              : file.uri.pathSegments.last,
      artist: metadata.artist?.trim().isNotEmpty == true ? metadata.artist! : 'Unknown Artist',
      album: metadata.album ?? 'Unknown Album',
      albumArtist: '',
      genre: metadata.genres.isNotEmpty ? metadata.genres.first : '',
      trackNumber: metadata.trackNumber ?? 0,
      discNumber: metadata.discNumber ?? 0,
      year: metadata.year?.year ?? 0,
      duration: metadata.duration?.inMilliseconds ?? 0,
      fileSize: await file.length(),
      lastModified: await file.lastModified(),
      artworkPath: artworkPath,
      favorite: false,
      playCount: 0,
      lastPlayed: null,
      isLossless: file.path.toLowerCase().endsWith('.flac'),
    );
  }
}
