import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ArtworkCacheService {
  Future<String?> saveArtwork(String songId, Uint8List? artwork) async {
    if (artwork == null) return null;

    final dir = await getApplicationDocumentsDirectory();

    final artworkDir = Directory(p.join(dir.path, 'artwork'));

    if (!await artworkDir.exists()) {
      await artworkDir.create(recursive: true);
    }

    final file = File(p.join(artworkDir.path, '${songId.hashCode}.jpg'));

    if (!await file.exists()) {
      await file.writeAsBytes(artwork);
    }

    return file.path;
  }
}
