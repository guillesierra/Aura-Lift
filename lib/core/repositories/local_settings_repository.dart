import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_settings.dart';
import 'settings_repository.dart';

class LocalSettingsRepository implements SettingsRepository {
  static const _themeModeKey = 'settings_theme_mode_v1';
  static const _languageCodeKey = 'settings_language_code_v1';
  static const _menuAnimationsKey = 'settings_menu_animations_v1';
  static const _appearanceKey = 'settings_appearance_v1';
  static const _heartRateBaseBpmKey = 'settings_heart_rate_base_bpm_v1';
  static const _heartRateReturnCueBpmKey =
      'settings_heart_rate_return_cue_bpm_v1';

  @override
  Future<AppSettings> load() async {
    final prefs = await SharedPreferences.getInstance();
    final themeModeRaw = prefs.getString(_themeModeKey);
    final languageCode = prefs.getString(_languageCodeKey) ?? 'es';
    final enableMenuAnimations = prefs.getBool(_menuAnimationsKey) ?? true;
    final appearanceRaw = prefs.getString(_appearanceKey);
    final heartRateBaseBpm = prefs.getInt(_heartRateBaseBpmKey);
    final heartRateReturnCueBpm = prefs.getInt(_heartRateReturnCueBpmKey);

    return AppSettings(
      themeMode: _parseThemeMode(themeModeRaw),
      languageCode: languageCode,
      enableMenuAnimations: enableMenuAnimations,
      appearance: _parseAppearance(appearanceRaw),
      heartRateBaseBpm: heartRateBaseBpm,
      heartRateReturnCueBpm: heartRateReturnCueBpm,
    );
  }

  @override
  Future<void> save(AppSettings settings) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, settings.themeMode.name);
    await prefs.setString(_languageCodeKey, settings.languageCode);
    await prefs.setBool(_menuAnimationsKey, settings.enableMenuAnimations);
    await prefs.setString(_appearanceKey, settings.appearance.name);
    if (settings.heartRateBaseBpm == null) {
      await prefs.remove(_heartRateBaseBpmKey);
    } else {
      await prefs.setInt(_heartRateBaseBpmKey, settings.heartRateBaseBpm!);
    }
    if (settings.heartRateReturnCueBpm == null) {
      await prefs.remove(_heartRateReturnCueBpmKey);
    } else {
      await prefs.setInt(
        _heartRateReturnCueBpmKey,
        settings.heartRateReturnCueBpm!,
      );
    }
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

  AppAppearance _parseAppearance(String? raw) {
    switch (raw) {
      case 'liquidGlass':
        return AppAppearance.liquidGlass;
      case 'classic':
      default:
        return AppAppearance.classic;
    }
  }
}
