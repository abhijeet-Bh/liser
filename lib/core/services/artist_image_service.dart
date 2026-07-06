import 'dart:convert';
import 'package:http/http.dart' as http;

class ArtistImageService {
  final Map<String, String> _cache = {}; // In-memory cache for the session

  Future<String?> getArtistImageUrl(String artistName) async {
    if (artistName.isEmpty) return null;

    // Check memory cache first
    if (_cache.containsKey(artistName)) {
      return _cache[artistName];
    }

    try {
      final query = Uri.encodeComponent(artistName);
      final url = Uri.parse('https://api.deezer.com/search/artist?q=$query');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final items = data['data'] as List?;
        
        if (items != null && items.isNotEmpty) {
          // Get the best match (first result)
          final artistData = items.first;
          final imageUrl = artistData['picture_medium'] as String?;
          
          if (imageUrl != null) {
            _cache[artistName] = imageUrl;
            return imageUrl;
          }
        }
      }
    } catch (e) {
      // Silently fail on network error or parsing error to allow fallback UI
      print('Error fetching artist image for $artistName: $e');
    }

    return null;
  }
}
