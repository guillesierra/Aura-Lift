import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.languageCode,
    required this.enableMenuAnimations,
  });

  final ThemeMode themeMode;
  final String languageCode;
  final bool enableMenuAnimations;

  static const defaults = AppSettings(
    themeMode: ThemeMode.system,
    languageCode: 'es',
    enableMenuAnimations: true,
  );

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? enableMenuAnimations,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      enableMenuAnimations: enableMenuAnimations ?? this.enableMenuAnimations,
    );
  }
}
