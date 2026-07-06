import 'package:hive_flutter/hive_flutter.dart';
import 'package:liser/core/storage/models/app_settings.dart';
import 'package:liser/features/library/data/models/playlist.dart';
import 'package:liser/features/library/data/models/song.dart';

class HiveService {
  static const String settingsBoxName = 'settings';
  static const String songsBoxName = 'songs';
  static const String playlistsBoxName = 'playlists';

  Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(AppSettingsAdapter());
    Hive.registerAdapter(SongAdapter());
    Hive.registerAdapter(PlaylistAdapter());

    await Hive.openBox<AppSettings>(settingsBoxName);
    await Hive.openBox<Song>(songsBoxName);
    await Hive.openBox<Playlist>(playlistsBoxName);
  }

  Box<AppSettings> get settingsBox => Hive.box<AppSettings>(settingsBoxName);

  Box<Song> get songsBox => Hive.box<Song>(songsBoxName);

  Box<Playlist> get playlistsBox => Hive.box<Playlist>(playlistsBoxName);
}
