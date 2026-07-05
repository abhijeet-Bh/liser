import 'package:liser/app/di/service_locator.dart';
import 'package:liser/core/storage/repositories/settings_repository.dart';
import 'package:liser/features/onboarding/data/services/import_service.dart';

class OnboardingRepository {
  OnboardingRepository();

  final SettingsRepository _settingsRepository = sl<SettingsRepository>();

  final ImportService _importService = sl<ImportService>();

  Future<int> importMusic() async {
    final imported = await _importService.importMusic();

    if (imported == 0) {
      return 0;
    }

    final settings = await _settingsRepository.getSettings();

    settings.firstLaunch = false;

    await _settingsRepository.save(settings);

    return imported;
  }
}
