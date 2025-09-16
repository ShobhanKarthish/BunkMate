import 'package:flutter/material.dart';

class UIConstants {
  // --- Modern Neon Theme ---

  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;
  static const double spacingXXL = 48.0;

  // Border Radius - Modern rounded corners
  static const double radiusXS = 6.0;
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;
  static const double radiusXL = 20.0;
  static const double radiusXXL = 24.0;

  // Card Dimensions
  static const double cardElevation = 0.0;
  static const double subjectCardHeight = 140.0;
  static const double progressRingSize = 60.0;
  static const double progressRingStroke = 6.0;

  // Icon Sizes
  static const double iconXS = 14.0;
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;
  static const double iconXL = 48.0;

  // Font Sizes
  static const double fontXS = 11.0;
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 20.0;
  static const double fontXXXL = 24.0;

  // --- Pastel Color Palette ---
  static const Color lightBackground = Color(0xFFF5F7FA); // Light, slightly blueish grey
  static const Color cardBlue = Color(0xFFE3F2FD); // Light Blue
  static const Color cardOrange = Color(0xFFFFF3E0); // Light Orange
  static const Color cardGreen = Color(0xFFE8F5E9); // Light Green
  static const Color primaryAccent = Color(0xFFFFD54F); // Friendly Yellow
  static const Color primaryText = Color(0xFF333333); // Dark Grey
  static const Color secondaryText = Color(0xFF757575); // Medium Grey

  // Accent Colors
  static const Color pastelBlue = Color(0xFFB3E5FC);
  static const Color pastelGreen = Color(0xFFC8E6C9);
  static const Color pastelPink = Color(0xFFF8BBD0);
  static const Color pastelYellow = Color(0xFFFFF9C4);


  // Semantic Colors
  static const Color attendanceGreen = Color(0xFF4CAF50);
  static const Color warningYellow = Color(0xFFFFC107);
  static const Color alertRed = Color(0xFFF44336);
  static const Color neutralGray = Color(0xFF9E9E9E);

  // Modern line-style icons
  static const Map<String, IconData> classTypeIcons = {
    'Lecture': Icons.school_outlined,
    'Lab': Icons.science_outlined,
    'OPD': Icons.medical_services_outlined,
  };

  // Legacy color support
  static const Color attendedColor = attendanceGreen;
  static const Color missedColor = alertRed;
  static const Color canceledColor = warningYellow;

  // Animation durations
  static const Duration animationFast = Duration(milliseconds: 200);
  static const Duration animationMedium = Duration(milliseconds: 300);
  static const Duration animationSlow = Duration(milliseconds: 500);
}
