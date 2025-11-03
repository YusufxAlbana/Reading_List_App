import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFE8C547);
  static const background = Color(0xFF2C3E45);
  static const surface = Color(0xFF3D5159);
  static const error = Colors.redAccent;
  static const text = Colors.white;
  static const textSecondary = Colors.white70;
}

class AppTheme {
  static final lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    primaryColor: AppColors.primary,
    // ...add light theme properties
  );

  static final darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.surface,
      surface: AppColors.surface,
      error: AppColors.error,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
      foregroundColor: AppColors.text,
    ),
    cardTheme: CardThemeData(
      color: AppColors.surface,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.text),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
      titleLarge: TextStyle(
        color: AppColors.text, 
        fontWeight: FontWeight.bold
      ),
    ),
  );
}
