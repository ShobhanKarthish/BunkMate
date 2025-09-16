import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/ui_constants.dart';

class AppTheme {
  // --- Pastel Theme ---

  // Re-aliasing for clarity
  static const Color _background = UIConstants.lightBackground;
  static const Color _primaryText = UIConstants.primaryText;
  static const Color _secondaryText = UIConstants.secondaryText;
  static const Color _primaryAccent = UIConstants.primaryAccent;
  static const Color _alertRed = UIConstants.alertRed;

  static ThemeData get pastelTheme {
    const String font = 'Fedra Sans';

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: _background,
      fontFamily: font,

      // Pastel Color Scheme
      colorScheme: const ColorScheme.light(
        brightness: Brightness.light,
        primary: _primaryAccent,
        onPrimary: _primaryText,
        secondary: _primaryAccent,
        onSecondary: _primaryText,
        surface: Colors.white,
        onSurface: _primaryText,
        error: _alertRed,
        onError: Colors.white,
        background: _background,
        onBackground: _primaryText,
      ),

      // Typography
      textTheme: const TextTheme(
        displayLarge: TextStyle(fontWeight: FontWeight.w700, color: _primaryText),
        displayMedium: TextStyle(fontWeight: FontWeight.w600, color: _primaryText),
        headlineLarge: TextStyle(fontWeight: FontWeight.w600, color: _primaryText),
        headlineMedium: TextStyle(fontWeight: FontWeight.w600, color: _primaryText),
        titleLarge: TextStyle(fontWeight: FontWeight.w600, color: _primaryText),
        titleMedium: TextStyle(fontWeight: FontWeight.w500, color: _primaryText),
        bodyLarge: TextStyle(fontWeight: FontWeight.w400, color: _primaryText),
        bodyMedium: TextStyle(fontWeight: FontWeight.w400, color: _secondaryText),
        bodySmall: TextStyle(fontWeight: FontWeight.w400, color: _secondaryText),
        labelLarge: TextStyle(fontWeight: FontWeight.w500, color: _primaryText),
      ).apply(fontFamily: font),

      // App Bar Theme
      appBarTheme: const AppBarTheme(
        backgroundColor: _background,
        foregroundColor: _primaryText,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: font,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: _primaryText,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Card Theme
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusXL), // More rounded
        ),
        margin: EdgeInsets.zero,
      ),

      // Button Themes
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryAccent,
          foregroundColor: _primaryText,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(UIConstants.radiusL),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: UIConstants.spacingL,
            vertical: UIConstants.spacingM,
          ),
          textStyle: const TextStyle(
            fontFamily: font,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),

      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: _primaryAccent,
        foregroundColor: _primaryText,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(UIConstants.radiusXL)),
        ),
      ),

      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: BorderSide(color: Colors.grey.shade300, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(UIConstants.radiusL),
          borderSide: const BorderSide(color: _primaryAccent, width: 2),
        ),
        labelStyle: const TextStyle(color: _secondaryText, fontFamily: font),
        hintStyle: const TextStyle(color: _secondaryText, fontFamily: font),
      ),

      // Divider Theme
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),
    );
  }

  // Exposing semantic colors for direct use
  static const Color attendanceGreen = UIConstants.attendanceGreen;
  static const Color warningYellow = UIConstants.warningYellow;
  static const Color alertRed = UIConstants.alertRed;
  static const Color primaryAccent = UIConstants.primaryAccent;
  static const Color primaryText = UIConstants.primaryText;
  static const Color secondaryText = UIConstants.secondaryText;
}
