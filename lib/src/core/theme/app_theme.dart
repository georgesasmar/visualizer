import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryGreen = Color(0xFF1DB954);
  static const Color primaryBlack = Color(0xFF191414);
  static const Color darkGrey = Color(0xFF121212);
  static const Color lightGrey = Color(0xFFB3B3B3);
  static const Color white = Color(0xFFFFFFFF);
  
  // Visualizer colors
  static const Color neonGreen = Color(0xFF39FF14);
  static const Color neonBlue = Color(0xFF00FFFF);
  static const Color neonPink = Color(0xFFFF073A);
  static const Color neonYellow = Color(0xFFFFFF00);
  static const Color neonOrange = Color(0xFFFF8C00);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: white,
      colorScheme: const ColorScheme.light(
        primary: primaryGreen,
        onPrimary: white,
        secondary: primaryBlack,
        onSecondary: white,
        surface: white,
        onSurface: primaryBlack,
        background: white,
        onBackground: primaryBlack,
        error: Colors.red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        foregroundColor: primaryBlack,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: white,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryBlack,
          fontFamily: 'Orbitron',
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: primaryBlack,
          fontFamily: 'Orbitron',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: primaryBlack,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: lightGrey,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      primaryColor: primaryGreen,
      scaffoldBackgroundColor: primaryBlack,
      colorScheme: const ColorScheme.dark(
        primary: primaryGreen,
        onPrimary: white,
        secondary: lightGrey,
        onSecondary: primaryBlack,
        surface: darkGrey,
        onSurface: white,
        background: primaryBlack,
        onBackground: white,
        error: Colors.red,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryBlack,
        foregroundColor: white,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      cardTheme: CardTheme(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        color: darkGrey,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: white,
          fontFamily: 'Orbitron',
        ),
        headlineMedium: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: white,
          fontFamily: 'Orbitron',
        ),
        bodyLarge: TextStyle(
          fontSize: 16,
          color: white,
        ),
        bodyMedium: TextStyle(
          fontSize: 14,
          color: lightGrey,
        ),
      ),
    );
  }

  static List<Color> get visualizerColorPresets => [
    neonGreen,
    neonBlue,
    neonPink,
    neonYellow,
    neonOrange,
    primaryGreen,
  ];
}