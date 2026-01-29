import 'package:flutter/material.dart';

/// Centralized color palette for the Daily News App
/// Provides consistent theming and easy maintenance
class AppColors {
  AppColors._(); // Private constructor

  // ============ Primary Colors ============
  static const Color primary = Colors.black;
  static const Color primaryLight = Color(0xFF424242);
  static const Color primaryDark = Color(0xFF000000);

  // ============ Accent Colors ============
  static const Color accent = Colors.amber;
  static const Color accentLight = Color(0xFFFFD54F);

  // ============ Background Colors ============
  static const Color scaffoldBackground = Colors.white;
  static const Color cardBackground = Colors.white;
  static const Color surfaceBackground = Color(0xFFFAFAFA);

  // ============ Text Colors ============
  static const Color textPrimary = Colors.black;
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFFBDBDBD);
  static const Color textOnPrimary = Colors.white;

  // ============ State Colors ============
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFF44336);
  static const Color warning = Color(0xFFFF9800);
  static const Color info = Color(0xFF2196F3);

  // ============ Border Colors ============
  static const Color border = Color(0xFFE0E0E0);
  static const Color borderLight = Color(0xFFEEEEEE);
  static const Color divider = Color(0xFFBDBDBD);

  // ============ Overlay Colors ============
  static const Color overlay =
      Color(0x80000000); // Semi-transparent black (50%)
  static const Color overlayLight = Color(0x33000000); // Light overlay (20%)
  static const Color overlayDark = Color(0xCC000000); // Dark overlay (80%)

  // ============ Icon Colors ============
  static const Color iconPrimary = Colors.black;
  static const Color iconSecondary = Color(0xFF757575);
  static const Color iconDisabled = Color(0xFFBDBDBD);
  static const Color iconOnPrimary = Colors.white;

  // ============ Shadow Colors ============
  static Color shadow = Colors.black.withValues(alpha: 0.05);
  static Color shadowMedium = Colors.black.withValues(alpha: 0.1);
  static Color shadowDark = Colors.black.withValues(alpha: 0.2);

  // ============ Gradient Colors ============
  static const List<Color> heroGradient = [
    Color(0x73000000), // black45
    Colors.transparent,
    Color(0x8A000000), // black54
  ];

  static const List<double> heroGradientStops = [0.0, 0.4, 1.0];
}
