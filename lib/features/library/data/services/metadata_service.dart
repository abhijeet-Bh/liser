import 'dart:io';

import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:liser/features/library/data/models/song.dart';
import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/services/artwork_cache_service.dart';

class MetadataService {
  Future<Song> read(File file) async {
    final metadata = await MetadataRetriever.fromFile(file);

    final artworkPath = await sl<ArtworkCacheService>().saveArtwork(
      file.path,
      metadata.albumArt,
    );

    return Song(
      id: file.path,
      path: file.path,
      fileName: file.uri.pathSegments.last,

      title:
          metadata.trackName?.trim().isNotEmpty == true
              ? metadata.trackName!
              : file.uri.pathSegments.last,

      artist:
          metadata.trackArtistNames != null &&
                  metadata.trackArtistNames!.isNotEmpty
              ? metadata.trackArtistNames!.join(', ')
              : 'Unknown Artist',

      album: metadata.albumName ?? 'Unknown Album',

      albumArtist: metadata.albumArtistName ?? '',

      genre: metadata.genre ?? '',

      trackNumber: metadata.trackNumber ?? 0,

      discNumber: metadata.discNumber ?? 0,

      year: metadata.year ?? 0,

      duration: metadata.trackDuration ?? 0,

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
