import 'package:flutter/material.dart';

/// Clean academic and athletic palette tailored for university fests
class AppColors {
  AppColors._();

  // Neutral Canvas & Surface
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAlt = Color(0xFFF1F5F9); // Slate 100
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderHover = Color(0xFFCBD5E1); // Slate 300
  static const Color divider = Color(0xFFEEF2F6);

  // Brand / Academic Primary
  static const Color primary = Color(0xFF1E3A8A); // Deep Varsity Navy (Blue 900)
  static const Color primaryLight = Color(0xFF3B82F6); // Blue 500
  static const Color primaryDark = Color(0xFF172554); // Blue 950
  static const Color primarySurface = Color(0xFFEFF6FF); // Blue 50

  // Semantic & Status
  static const Color liveRed = Color(0xFFE11D48); // Rose 600
  static const Color liveRedSurface = Color(0xFFFFF1F2); // Rose 50
  static const Color scheduledAmber = Color(0xFFD97706); // Amber 600
  static const Color scheduledAmberSurface = Color(0xFFFFFBEB); // Amber 50
  static const Color completedGreen = Color(0xFF059669); // Emerald 600
  static const Color completedGreenSurface = Color(0xFFECFDF5); // Emerald 50

  // Category Colors
  static const Color outdoorIndigo = Color(0xFF4F46E5); // Indigo 600
  static const Color outdoorSurface = Color(0xFFEEF2FF); // Indigo 50
  static const Color indoorTeal = Color(0xFF0D9488); // Teal 600
  static const Color indoorSurface = Color(0xFFF0FDFA); // Teal 50

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF);
}
