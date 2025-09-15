import 'package:flutter/material.dart';

class UIConstants {
  // Spacing
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 16.0;
  static const double spacingL = 24.0;
  static const double spacingXL = 32.0;

  // Border Radius
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 16.0;

  // Card Dimensions
  static const double cardElevation = 2.0;
  static const double subjectCardHeight = 120.0;

  // Icon Sizes
  static const double iconS = 16.0;
  static const double iconM = 24.0;
  static const double iconL = 32.0;

  // Font Sizes
  static const double fontS = 12.0;
  static const double fontM = 14.0;
  static const double fontL = 16.0;
  static const double fontXL = 18.0;
  static const double fontXXL = 24.0;

  // Class Type Icons
  static const Map<String, IconData> classTypeIcons = {
    'Lecture': Icons.school,
    'Lab': Icons.science,
    'OPD': Icons.medical_services,
  };

  // Attendance Colors
  static const Color attendedColor = Colors.green;
  static const Color missedColor = Colors.red;
  static const Color canceledColor = Colors.orange;
}
