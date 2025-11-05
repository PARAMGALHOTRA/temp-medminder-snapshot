import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors
  static const Color primaryLight = Color(0xFF4A90E2);
  static const Color accentLight = Color(0xFF50E3C2);
  static const Color backgroundLight = Color(0xFFF7F9FC);
  static const Color cardLight = Colors.white;
  static const Color textLight = Color(0xFF333333);

  // Dark Theme Colors
  static const Color primaryDark = Color(0xFF4A90E2);
  static const Color accentDark = Color(0xFF50E3C2);
  static const Color backgroundDark = Color(0xFF121212);
  static const Color cardDark = Color(0xFF1E1E1E);
  static const Color textDark = Color(0xFFE0E0E0);

  // Other Colors
  static const Color errorLight = Color(0xFFE57373);
  static const Color errorDark = Color(0xFFD32F2F);
  static const Color warningLight = Color(0xFFFFB74D);
  static const Color warningDark = Color(0xFFFFA000);
  static const Color accentGreen = Color(0xFFB9F6CA);
  static const Color accentGreenDark = Color(0xFF00C853);

  // Adherence Colors
  static const Color greenAdherence = Color(0xFF2ECC71);
  static const Color orangeAdherence = Color(0xFFF39C12);
  static const Color redAdherence = Color(0xFFE74C3C);
  static const Color greyAdherence = Color(0xFFBDBDBD);

  static final TextTheme _textTheme = GoogleFonts.manropeTextTheme();

  static final ThemeData lightTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryLight,
      scaffoldBackgroundColor: backgroundLight,
      cardColor: cardLight,
      hintColor: accentLight,
      textTheme:
          _textTheme.apply(bodyColor: textLight, displayColor: textLight),
      colorScheme: const ColorScheme.light(
        primary: primaryLight,
        secondary: accentLight,
        error: errorLight,
        surface: cardLight,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textLight,
        onError: Colors.white,
        brightness: Brightness.light,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundLight,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryLight),
        titleTextStyle: _textTheme.titleLarge
            ?.copyWith(color: textLight, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryLight,
      )));

  static final ThemeData darkTheme = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryDark,
      scaffoldBackgroundColor: backgroundDark,
      cardColor: cardDark,
      hintColor: accentDark,
      textTheme: _textTheme.apply(bodyColor: textDark, displayColor: textDark),
      colorScheme: const ColorScheme.dark(
        primary: primaryDark,
        secondary: accentDark,
        error: errorDark,
        surface: cardDark,
        onPrimary: Colors.white,
        onSecondary: Colors.black,
        onSurface: textDark,
        onError: Colors.white,
        brightness: Brightness.dark,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: backgroundDark,
        elevation: 0,
        iconTheme: const IconThemeData(color: primaryDark),
        titleTextStyle: _textTheme.titleLarge
            ?.copyWith(color: textDark, fontWeight: FontWeight.bold),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
        foregroundColor: Colors.white,
        backgroundColor: primaryDark,
      )));
}
