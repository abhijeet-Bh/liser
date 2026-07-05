import 'package:get_it/get_it.dart';

import 'package:liser/core/storage/database/hive_service.dart';
import 'package:liser/core/storage/repositories/settings_repository.dart';
import 'package:liser/core/storage/services/music_storage_service.dart';

import 'package:liser/features/library/data/repositories/library_repository.dart';
import 'package:liser/features/library/data/services/library_scanner.dart';
import 'package:liser/features/library/data/services/metadata_service.dart';

import 'package:liser/features/onboarding/data/repositories/onboarding_repository.dart';
import 'package:liser/features/onboarding/data/services/import_service.dart';

import 'package:liser/features/player/data/services/audio_player_service.dart';
import 'package:liser/core/storage/services/artwork_cache_service.dart';

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  final hiveService = HiveService();

  await hiveService.init();

  sl.registerSingleton<HiveService>(hiveService);

  sl.registerLazySingleton(() => SettingsRepository());

  sl.registerLazySingleton(() => OnboardingRepository());

  sl.registerLazySingleton(() => MusicStorageService());

  sl.registerLazySingleton(() => ImportService(storageService: sl()));

  sl.registerLazySingleton(() => LibraryScanner());

  sl.registerLazySingleton(() => MetadataService());
  sl.registerLazySingleton(() => ArtworkCacheService());

  sl.registerLazySingleton(
    () => LibraryRepository(
      scanner: sl(),
      metadataService: sl(),
      importService: sl(),
    ),
  );

  sl.registerLazySingleton(() => AudioPlayerService());
}
