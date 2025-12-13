import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static const _primaryColor = Color(0xFF6C63FF); // Example Premium Purple/Blue
  static const _secondaryColor = Color(0xFFFF6584); // Accent Pink/Red
  static const _backgroundColor = Color(0xFFF8F9FE); // Soft White/Gray
  static const _surfaceColor = Colors.white;
  static const _onSurfaceColor = Color(0xFF2D3142); // Dark Charcoal

  static final TextTheme _textTheme = GoogleFonts.outfitTextTheme(
    ThemeData.light().textTheme,
  ).apply(
    bodyColor: _onSurfaceColor, 
    displayColor: _onSurfaceColor,
  );

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: _primaryColor,
        primary: _primaryColor,
        secondary: _secondaryColor,
        surface: _surfaceColor,
        background: _backgroundColor,
        onSurface: _onSurfaceColor,
      ),
      scaffoldBackgroundColor: _backgroundColor,
      textTheme: _textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: _backgroundColor,
        elevation: 0,
        titleTextStyle: _textTheme.headlineSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: _onSurfaceColor,
        ),
        iconTheme: const IconThemeData(color: _onSurfaceColor),
      ),
      /* cardTheme: CardTheme(
        color: _surfaceColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.05),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ), */
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          elevation: 4,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          textStyle: _textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
       inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
