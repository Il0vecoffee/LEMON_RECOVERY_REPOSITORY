import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Colors
  // LEMON Specific Palette (Mustard & Cream)
  static const Color lemonHeader = Color(0xFFC8960C); // Mustard Yellow
  static const Color lemonBackground = Color(0xFFFFF8D6); // Soft Cream
  static const Color lemonButton = Color(0xFFA67C00); // Dark Mustard
  static const Color lemonCard = Color(0xFFFFFDF2); // Ivory
  static const Color lemonText = Color(0xFF1E1E1E); // Charcoal
  
  static const Color primaryLemon = Color(0xFFFBC02D); // Vibrant Yellow (Old)
  static const Color lemonYellow = lemonHeader; // Link to new theme
  static const Color creamSilk = lemonBackground; // Link to new theme

  static const Color primaryGreen = Color(0xFF4CAF50); // LIME Green
  static const Color darkTeal = Color(0xFF0F7060); // Darker Green for Header
  static const Color limeBackground = Color(0xFF819A2E); // Olive/Lime Background
  static const Color white = Colors.white;
  static const Color errorRed = Color(0xFFE57373);
  static const Color forestEspresso = Color(0xFF2E3B44); // Darker Graphite

  static TextStyle get serifTitle => GoogleFonts.lora(
        fontWeight: FontWeight.bold,
      );

  static InputDecoration inputDecoration({
    required String labelText,
    String? hintText,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: lemonHeader, width: 2),
      ),
      filled: true,
      fillColor: Colors.white,
    );
  }

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: lemonHeader,
        primary: lemonHeader,
        secondary: lemonButton,
        surface: lemonCard,
        onSurface: lemonText,
        error: errorRed,
      ),
      scaffoldBackgroundColor: lemonBackground,
      textTheme: GoogleFonts.interTextTheme().apply(
        bodyColor: lemonText,
        displayColor: lemonText,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: white,
        elevation: 0,
        iconTheme: IconThemeData(color: forestEspresso),
        titleTextStyle: TextStyle(
          color: forestEspresso,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryGreen,
          foregroundColor: white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primaryGreen, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}
