import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import 'settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  static const _themeModeKey = 'settings_theme_mode_v1';
  static const _languageCodeKey = 'settings_language_code_v1';
  static const _menuAnimationsKey = 'settings_menu_animations_v1';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeRaw = prefs.getString(_themeModeKey);
    final languageCode = prefs.getString(_languageCodeKey) ?? 'es';
    final enableMenuAnimations = prefs.getBool(_menuAnimationsKey) ?? true;

    return AppSettings(
      themeMode: _parseThemeMode(themeModeRaw),
      languageCode: languageCode,
      enableMenuAnimations: enableMenuAnimations,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, settings.themeMode.name);
    await prefs.setString(_languageCodeKey, settings.languageCode);
    await prefs.setBool(_menuAnimationsKey, settings.enableMenuAnimations);
  }

  ThemeMode _parseThemeMode(String? raw) {
    switch (raw) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }
}
