import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFFFC8A4B); // Vibrant orange
  static const Color accentColor = Color(0xFFFDE9E1);
  static const Color backgroundColor = Color(0xFFF9F9FB);
  static const Color textColor = Color(0xFF2C2C2C);
  static const Color greyColor = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: accentColor,
        surface: Colors.white,
      ),
      fontFamily: 'Inter',
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      textTheme: const TextTheme(
        displayLarge: TextStyle(color: textColor, fontSize: 32, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textColor, fontSize: 24, fontWeight: FontWeight.w700),
        titleMedium: TextStyle(color: textColor, fontSize: 18, fontWeight: FontWeight.w600),
        bodyLarge: TextStyle(color: textColor, fontSize: 16),
        bodyMedium: TextStyle(color: greyColor, fontSize: 14),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
