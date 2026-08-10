import 'dart:io';
import 'package:audio_metadata_reader/audio_metadata_reader.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/services/artwork_cache_service.dart';

class MetadataService {
  String _sanitizeString(String? input, String fallback) {
    if (input == null || input.trim().isEmpty) return fallback;
    
    // 1. Truncate at the first control character (handles null bytes and binary size bytes)
    final controlCharIdx = input.indexOf(RegExp(r'[\x00-\x1F\x7F]'));
    if (controlCharIdx != -1) {
      input = input.substring(0, controlCharIdx);
    }
    
    // 2. Remove common parsing artifacts from corrupted m4a files where it reads into the next 'data' atom
    // This looks for anything like f"data • at the end of the string
    input = input.replaceAll(RegExp(r'.?"?data\s*[•・\u2022]?.*$'), '');

    // 3. Remove any remaining non-printable characters or weird unicode artifacts
    input = input.replaceAll(RegExp(r'[^\p{L}\p{N}\p{P}\p{Z}\p{S}]', unicode: true), '');
    
    return input.trim().isEmpty ? fallback : input.trim();
  }

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
      title: _sanitizeString(metadata.title, file.uri.pathSegments.last),
      artist: _sanitizeString(metadata.artist, 'Unknown Artist'),
      album: _sanitizeString(metadata.album, 'Unknown Album'),
      albumArtist: '',
      genre: _sanitizeString(metadata.genres.isNotEmpty ? metadata.genres.first : null, ''),
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
