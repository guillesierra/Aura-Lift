import 'package:flutter/material.dart';

class AppTheme {
  static const _accent = Color(0xFF0E9F88);
  static const _accentDark = Color(0xFF0B7E6C);
  static const _surfaceTint = Color(0xFFE7F5F1);

  static ThemeData get light {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme(
        brightness: Brightness.light,
        primary: _accent,
        onPrimary: Colors.white,
        secondary: Color(0xFF244B45),
        onSecondary: Colors.white,
        error: Color(0xFFBA1A1A),
        onError: Colors.white,
        surface: Color(0xFFFFFFFF),
        onSurface: Color(0xFF11161A),
        primaryContainer: _surfaceTint,
        onPrimaryContainer: Color(0xFF082C26),
        secondaryContainer: Color(0xFFDCEFE9),
        onSecondaryContainer: Color(0xFF112A26),
        tertiary: Color(0xFF5E7C76),
        onTertiary: Colors.white,
        tertiaryContainer: Color(0xFFDDECE8),
        onTertiaryContainer: Color(0xFF19322E),
        surfaceContainerHighest: Color(0xFFF1F4F5),
        onSurfaceVariant: Color(0xFF566168),
        outline: Color(0xFFDCE2E5),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFF1B2227),
        onInverseSurface: Color(0xFFF3F5F6),
        inversePrimary: Color(0xFF59D1BA),
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFFF4F7F8),
      textTheme: _textTheme(base.textTheme, Brightness.light),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFFF1F4F5),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: const TextStyle(color: Color(0xFF7B8891)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDCE2E5)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFFDCE2E5)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: _accent, width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          backgroundColor: _accent,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
    );
  }

  static ThemeData get dark {
    final base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: Color(0xFF59D1BA),
        onPrimary: Color(0xFF042A24),
        secondary: Color(0xFFA6CEC5),
        onSecondary: Color(0xFF112A26),
        error: Color(0xFFFFB4AB),
        onError: Color(0xFF690005),
        surface: Color(0xFF151B1F),
        onSurface: Color(0xFFEAF0F2),
        primaryContainer: Color(0xFF10352E),
        onPrimaryContainer: Color(0xFF8FF0DC),
        secondaryContainer: Color(0xFF1E3A35),
        onSecondaryContainer: Color(0xFFC1EADF),
        tertiary: Color(0xFF94B8B1),
        onTertiary: Color(0xFF0E2622),
        tertiaryContainer: Color(0xFF25403B),
        onTertiaryContainer: Color(0xFFB0D4CD),
        surfaceContainerHighest: Color(0xFF1D252A),
        onSurfaceVariant: Color(0xFFAEB8BE),
        outline: Color(0xFF313B40),
        shadow: Colors.black,
        scrim: Colors.black,
        inverseSurface: Color(0xFFEAF0F2),
        onInverseSurface: Color(0xFF151B1F),
        inversePrimary: _accentDark,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: const Color(0xFF0D1114),
      textTheme: _textTheme(base.textTheme, Brightness.dark),
      cardTheme: const CardThemeData(
        color: Color(0xFF151B1F),
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(28)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1A2126),
        contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
        hintStyle: const TextStyle(color: Color(0xFF7F8A91)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2B353A)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF2B353A)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: const BorderSide(color: Color(0xFF59D1BA), width: 1.4),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(58),
          backgroundColor: const Color(0xFF59D1BA),
          foregroundColor: const Color(0xFF062E28),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ),
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
        fontSize: 42,
        fontWeight: FontWeight.w800,
        color: primary,
        letterSpacing: -1.6,
        height: 1.05,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.8,
        height: 1.1,
      ),
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.4,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: primary,
        letterSpacing: -0.2,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: primary,
        height: 1.4,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: secondary,
        height: 1.35,
      ),
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: primary,
      ),
    );
  }
}
