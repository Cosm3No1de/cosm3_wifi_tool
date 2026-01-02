import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Professional Cyberpunk Palette
  static const Color primary = Color(0xFF00E5FF); // Cyan Accent (Cleaner)
  static const Color background = Color(0xFF121212); // Material Dark (Standard)
  static const Color cardColor = Color(0xFF1E1E1E); // Elevated Dark Surface
  static const Color accent = Color(0xFFFF003C); // Neon Red (Alerts)
  static const Color success = Color(0xFF00FF9D); // Neon Green (Success)

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: background,
      primaryColor: primary,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: accent,
        surface: cardColor,
        error: accent,
      ),
      // Typography: Fira Code for Tech/Data, Inter for UI/Readability
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme)
          .copyWith(
            displayLarge: GoogleFonts.firaCode(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
            displayMedium: GoogleFonts.firaCode(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
            displaySmall: GoogleFonts.firaCode(
              color: primary,
              fontWeight: FontWeight.bold,
            ),
            headlineLarge: GoogleFonts.firaCode(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            headlineMedium: GoogleFonts.firaCode(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            headlineSmall: GoogleFonts.firaCode(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
            titleLarge: GoogleFonts.inter(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
            bodyLarge: GoogleFonts.inter(color: Colors.white70),
            bodyMedium: GoogleFonts.inter(color: Colors.white70),
          )
          .apply(bodyColor: Colors.white70, displayColor: primary),
      cardColor: cardColor,
      appBarTheme: AppBarTheme(
        backgroundColor: background, // Solid background for better readability
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.firaCode(
          fontSize: 20, // Slightly smaller for professional look
          fontWeight: FontWeight.bold,
          color: primary,
          letterSpacing: 1.2,
        ),
        iconTheme: const IconThemeData(color: primary),
      ),
      dividerColor: Colors.white10,
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: cardColor,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(12), // Softer corners
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: primary, width: 1.5),
          borderRadius: BorderRadius.circular(12),
        ),
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5)),
        hintStyle: TextStyle(color: Colors.white.withValues(alpha: 0.3)),
        prefixIconColor: primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary.withValues(alpha: 0.15),
          foregroundColor: primary,
          side: BorderSide(color: primary.withValues(alpha: 0.5)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
          elevation: 0,
          textStyle: GoogleFonts.firaCode(
            fontWeight: FontWeight.bold,
            letterSpacing: 1.0,
          ),
        ),
      ),
    );
  }
}
