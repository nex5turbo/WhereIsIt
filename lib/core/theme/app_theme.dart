import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' show TextTheme;
import 'package:google_fonts/google_fonts.dart';

abstract class AppTheme {
  static const _primaryColor = Color(0xFF6C63FF); // Example Premium Purple/Blue
  // ignore: unused_field
  static const _secondaryColor = Color(0xFFFF6584); // Accent Pink/Red
  static const _backgroundColor = Color(0xFFF8F9FE); // Soft White/Gray
  static const _surfaceColor = Color(0xFFFFFFFF);
  static const _onSurfaceColor = Color(0xFF2D3142); // Dark Charcoal

  static final TextTheme _baseTextTheme = GoogleFonts.outfitTextTheme();

  static CupertinoTextThemeData get _textTheme {
    return CupertinoTextThemeData(
      primaryColor: _primaryColor,
      textStyle: _baseTextTheme.bodyMedium?.copyWith(color: _onSurfaceColor),
      actionTextStyle: _baseTextTheme.bodyMedium?.copyWith(
        color: _primaryColor,
      ),
      tabLabelTextStyle: _baseTextTheme.labelSmall,
      navTitleTextStyle: _baseTextTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: _onSurfaceColor,
        fontSize: 20,
      ),
      navLargeTitleTextStyle: _baseTextTheme.headlineMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: _onSurfaceColor,
      ),
      pickerTextStyle: _baseTextTheme.bodyLarge?.copyWith(
        color: _onSurfaceColor,
      ),
      dateTimePickerTextStyle: _baseTextTheme.bodyLarge?.copyWith(
        color: _onSurfaceColor,
      ),
    );
  }

  static CupertinoThemeData get lightTheme {
    return CupertinoThemeData(
      brightness: Brightness.light,
      primaryColor: _primaryColor,
      primaryContrastingColor: _surfaceColor,
      barBackgroundColor: _backgroundColor.withOpacity(0.9), // Glassy header
      scaffoldBackgroundColor: _backgroundColor,
      textTheme: _textTheme,
      applyThemeToAll: true,
    );
  }
}
