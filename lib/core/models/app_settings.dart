import 'package:flutter/material.dart';

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.languageCode,
  });

  final ThemeMode themeMode;
  final String languageCode;

  static const defaults = AppSettings(
    themeMode: ThemeMode.system,
    languageCode: 'es',
  );

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
    );
  }
}
