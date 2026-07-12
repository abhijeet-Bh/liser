import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/repositories/settings_repository.dart';
import 'package:liser/features/onboarding/data/services/import_service.dart';
import 'package:liser/features/onboarding/data/services/sync_service.dart';
import 'package:liser/features/library/data/repositories/library_repository.dart';

class OnboardingRepository {
  OnboardingRepository();

  final SettingsRepository _settingsRepository = sl<SettingsRepository>();

  final ImportService _importService = sl<ImportService>();

  Future<int> importMusic() async {
    final imported = await _importService.importMusic();

    if (imported == 0) {
      return 0;
    }

    // Scan library to register imported files
    await sl<LibraryRepository>().scanLibrary();

    final settings = await _settingsRepository.getSettings();

    settings.firstLaunch = false;

    await _settingsRepository.save(settings);

    return imported;
  }

  Future<String?> selectSyncFolder() async {
    final syncService = sl<SyncService>();
    final folderPath = await syncService.selectSyncFolder();
    if (folderPath == null) {
      return null;
    }

    // Scan library to register files in the sync folder
    await sl<LibraryRepository>().scanLibrary();

    final settings = await _settingsRepository.getSettings();
    settings.firstLaunch = false;
    await _settingsRepository.save(settings);

    return folderPath;
  }

  Future<void> skipOnboarding() async {
    final settings = await _settingsRepository.getSettings();
    settings.firstLaunch = false;
    await _settingsRepository.save(settings);
  }
}
