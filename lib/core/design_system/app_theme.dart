import 'package:flutter/material.dart';

class AppTheme {
  static const _accent = Color(0xFF0E9F88);
  static const _accentDark = Color(0xFF0B7E6C);
  static const _surfaceTint = Color(0xFFE7F5F1);
  static const _warmAccent = Color(0xFFFF8A5B);
  static const _cardRadius = 8.0;
  static const List<String> _emojiFontFallbacks = [
    'Noto Color Emoji',
    'Apple Color Emoji',
    'Segoe UI Emoji',
    'Segoe UI Symbol',
  ];

  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.light,
    ).copyWith(
      primary: _accent,
      onPrimary: Colors.white,
      secondary: const Color(0xFF263A41),
      onSecondary: Colors.white,
      tertiary: _warmAccent,
      onTertiary: const Color(0xFF331100),
      error: const Color(0xFFBA1A1A),
      onError: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF11181C),
      primaryContainer: _surfaceTint,
      onPrimaryContainer: const Color(0xFF082C26),
      secondaryContainer: const Color(0xFFE6EDF0),
      onSecondaryContainer: const Color(0xFF152B31),
      tertiaryContainer: const Color(0xFFFFE4D7),
      onTertiaryContainer: const Color(0xFF3A1200),
      surfaceContainerHighest: const Color(0xFFEFF4F5),
      onSurfaceVariant: const Color(0xFF546167),
      outline: const Color(0xFFD5DFE2),
      inverseSurface: const Color(0xFF1A2328),
      onInverseSurface: const Color(0xFFF1F5F6),
      inversePrimary: const Color(0xFF59D1BA),
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: scheme,
      fontFamilyFallback: _emojiFontFallbacks,
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF6F8F7),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      textTheme: _textTheme(base.textTheme, Brightness.light),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
      ),
      navigationBarTheme: _navigationBarTheme(scheme),
      chipTheme: _chipTheme(scheme),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconButtonTheme: _iconButtonTheme(scheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: _accent,
      brightness: Brightness.dark,
    ).copyWith(
      primary: const Color(0xFF59D1BA),
      onPrimary: const Color(0xFF042A24),
      secondary: const Color(0xFFB4C9D0),
      onSecondary: const Color(0xFF1D3339),
      tertiary: const Color(0xFFFFB18F),
      onTertiary: const Color(0xFF4B1B00),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      surface: const Color(0xFF141B1F),
      onSurface: const Color(0xFFEAF1F3),
      primaryContainer: const Color(0xFF10352E),
      onPrimaryContainer: const Color(0xFF8FF0DC),
      secondaryContainer: const Color(0xFF24383E),
      onSecondaryContainer: const Color(0xFFD1E7EE),
      tertiaryContainer: const Color(0xFF653016),
      onTertiaryContainer: const Color(0xFFFFDBC9),
      surfaceContainerHighest: const Color(0xFF1E292E),
      onSurfaceVariant: const Color(0xFFB8C4C9),
      outline: const Color(0xFF344249),
      inverseSurface: const Color(0xFFEAF1F3),
      onInverseSurface: const Color(0xFF141B1F),
      inversePrimary: _accentDark,
    );
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      fontFamilyFallback: _emojiFontFallbacks,
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0F1518),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      visualDensity: const VisualDensity(horizontal: -1, vertical: -1),
      textTheme: _textTheme(base.textTheme, Brightness.dark),
      cardTheme: const CardThemeData(
        color: Color(0xFF151B1F),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(_cardRadius)),
        ),
      ),
      navigationBarTheme: _navigationBarTheme(scheme),
      chipTheme: _chipTheme(scheme),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      iconButtonTheme: _iconButtonTheme(scheme),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHighest,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        hintStyle: TextStyle(color: scheme.onSurfaceVariant),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: scheme.primary, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(48),
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            letterSpacing: 0,
          ),
        ),
      ),
      outlinedButtonTheme: _outlinedButtonTheme(scheme),
    );
  }

  static TextTheme _textTheme(TextTheme base, Brightness brightness) {
    final primary = brightness == Brightness.dark
        ? const Color(0xFFEAF0F2)
        : const Color(0xFF11161A);
    final secondary = brightness == Brightness.dark
        ? const Color(0xFFAEB8BE)
        : const Color(0xFF5A656D);

    return base.copyWith(
      displayLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: 0,
        height: 1.1,
      ),
      headlineLarge: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: 0,
        height: 1.12,
      ),
      headlineMedium: TextStyle(
        fontSize: 23,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0,
        height: 1.16,
      ),
      titleLarge: TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0,
      ),
      titleMedium: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0,
      ),
      bodyLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.36,
      ),
      bodyMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: secondary,
        height: 1.32,
      ),
      labelLarge: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: 0,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: secondary,
        letterSpacing: 0,
      ),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(ColorScheme scheme) {
    return NavigationBarThemeData(
      height: 64,
      elevation: 0,
      backgroundColor: scheme.surface,
      indicatorColor: scheme.primaryContainer,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
          size: selected ? 24 : 22,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return TextStyle(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
          color: selected ? scheme.primary : scheme.onSurfaceVariant,
        );
      }),
    );
  }

  static ChipThemeData _chipTheme(ColorScheme scheme) {
    return ChipThemeData(
      backgroundColor: scheme.surfaceContainerHighest,
      selectedColor: scheme.primaryContainer,
      checkmarkColor: scheme.primary,
      side: BorderSide(color: scheme.outline),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      labelStyle: TextStyle(
        color: scheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  static IconButtonThemeData _iconButtonTheme(ColorScheme scheme) {
    return IconButtonThemeData(
      style: IconButton.styleFrom(
        foregroundColor: scheme.onSurface,
        backgroundColor: scheme.surfaceContainerHighest,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(ColorScheme scheme) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(48),
        foregroundColor: scheme.onSurface,
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0,
        ),
      ),
    );
  }
}
