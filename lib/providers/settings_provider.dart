import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import '../models/app_settings.dart';

class SettingsProvider extends ChangeNotifier {
  static const _boxName = 'settings';
  static const _key = 'main';

  AppSettings _settings = AppSettings.defaults;

  AppSettings get settings => _settings;

  SettingsProvider() {
    _load();
  }

  void _load() {
    final box = Hive.box<AppSettings>(_boxName);
    _settings = box.get(_key) ?? AppSettings.defaults;
  }

  Future<void> save(AppSettings updated) async {
    final box = Hive.box<AppSettings>(_boxName);
    await box.put(_key, updated);
    _settings = updated;
    notifyListeners();
  }

  // Convenience getters
  String get novaPoshtaApiKey => _settings.novaPoshtaApiKey;
  String get ukrposhtaToken => _settings.ukrposhtaToken;
  bool get hasNovaPoshtaKey => _settings.novaPoshtaApiKey.isNotEmpty;
  bool get hasUkrposhtaToken => _settings.ukrposhtaToken.isNotEmpty;
}
