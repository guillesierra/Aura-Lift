import 'package:flutter/material.dart';

enum AppAppearance {
  classic,
  liquidGlass,
}

class AppSettings {
  const AppSettings({
    required this.themeMode,
    required this.languageCode,
    required this.enableMenuAnimations,
    required this.appearance,
    this.heartRateBaseBpm,
    this.heartRateReturnCueBpm,
  });

  final ThemeMode themeMode;
  final String languageCode;
  final bool enableMenuAnimations;
  final AppAppearance appearance;
  final int? heartRateBaseBpm;
  final int? heartRateReturnCueBpm;

  static const defaults = AppSettings(
    themeMode: ThemeMode.system,
    languageCode: 'es',
    enableMenuAnimations: true,
    appearance: AppAppearance.classic,
  );

  AppSettings copyWith({
    ThemeMode? themeMode,
    String? languageCode,
    bool? enableMenuAnimations,
    AppAppearance? appearance,
    int? heartRateBaseBpm,
    bool keepHeartRateBaseBpm = true,
    int? heartRateReturnCueBpm,
    bool keepHeartRateReturnCueBpm = true,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      languageCode: languageCode ?? this.languageCode,
      enableMenuAnimations: enableMenuAnimations ?? this.enableMenuAnimations,
        appearance: appearance ?? this.appearance,
      heartRateBaseBpm: keepHeartRateBaseBpm
          ? (heartRateBaseBpm ?? this.heartRateBaseBpm)
          : null,
      heartRateReturnCueBpm: keepHeartRateReturnCueBpm
          ? (heartRateReturnCueBpm ?? this.heartRateReturnCueBpm)
          : null,
    );
  }
}
