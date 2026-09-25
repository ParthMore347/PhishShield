import 'package:flutter/material.dart';

class AppThemes {
  // Common colors
  static const Color buttonBlue = Color(0xFF3B6695); // Steel/slate blue seen in screenshots
  static const Color darkButtonBg = Color(0xFF15191E); // Dark button bg
  static const Color borderGray = Color(0xFF2E3440); // Outline border color

  // 1. OLED Theme (True Black & Neon Cyan)
  static ThemeData get oledTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: Colors.black,
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF101216),
        primary: Color(0xFF00E5FF), // Cyber Neon Cyan
        secondary: buttonBlue,
        error: Color(0xFFFF5252),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF0D0F12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFF1F242C), width: 1),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF0D0F12),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F242C)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF1F242C)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      useMaterial3: true,
    );
  }

  // 2. Cyberpunk Theme (Dark Slate, Neon Pink & Purple)
  static ThemeData get cyberpunkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF0B001A), // Dark Violet-Black
      colorScheme: const ColorScheme.dark(
        surface: Color(0xFF1F0033),
        primary: Color(0xFFFF007F), // Neon Pink
        secondary: buttonBlue,
        error: Color(0xFFFF3333),
      ),
      cardTheme: const CardThemeData(
        color: Color(0xFF1F0033),
        elevation: 4,
        shadowColor: Color(0xFFFF007F),
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFFF007F), width: 1.5),
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF1F0033),
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF007F)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFFF007F)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFB000FF), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: buttonBlue,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      useMaterial3: true,
    );
  }

  // 3. Enterprise (Corporate Slate & Deep Blue)
  static ThemeData get enterpriseTheme {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: const Color(0xFFF8FAFC), // Off-white
      colorScheme: const ColorScheme.light(
        surface: Colors.white,
        primary: Color(0xFF0F172A), // Deep Slate
        secondary: Color(0xFF2563EB), // Corporate Blue
        error: Color(0xFFDC2626),
      ),
      cardTheme: const CardThemeData(
        color: Colors.white,
        elevation: 2,
        shadowColor: Colors.black12,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: Color(0xFFE2E8F0), width: 1),
          borderRadius: BorderRadius.all(Radius.circular(12)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        labelStyle: const TextStyle(color: Colors.grey),
        hintStyle: const TextStyle(color: Colors.grey),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF2563EB), width: 1.5),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF2563EB),
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      useMaterial3: true,
    );
  }
}
