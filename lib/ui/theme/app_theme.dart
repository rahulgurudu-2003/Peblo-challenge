import 'package:flutter/material.dart';

class AppTheme {
  // Brand/Kid-Friendly Palette
  static const Color background = Color(0xFFF7F9FC);
  static const Color cardBg = Colors.white;
  
  static const Color primary = Color(0xFFFF6F59);       // Coral Orange (Active Buttons)
  static const Color secondary = Color(0xFF4ECDC4);     // Mint Green (Success/Interactive elements)
  static const Color buddyPrimary = Color(0xFF457B9D);   // Friendly Blue for Pip the Robot
  static const Color buddyAccent = Color(0xFFE63946);    // Rosy Red details
  
  static const Color textDark = Color(0xFF2B2D42);
  static const Color textLight = Color(0xFF8D99AE);
  static const Color optionBorder = Color(0xFFE2E8F0);
  
  // Quiz Colors
  static const Color correctColor = Color(0xFF2EC4B6);
  static const Color incorrectColor = Color(0xFFFF9F1C);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: ColorScheme.fromSeed(
        seedColor: primary,
        background: background,
        primary: primary,
        secondary: secondary,
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w800,
          color: textDark,
          letterSpacing: -0.5,
        ),
        titleLarge: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: textDark,
          letterSpacing: -0.2,
        ),
        bodyLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: textDark,
          height: 1.5,
        ),
        bodyMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.normal,
          color: textLight,
          height: 1.4,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 6,
        shadowColor: Colors.black.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
    );
  }
}
