import 'package:flutter/material.dart';

/// Clean academic and athletic palette tailored for university fests
class AppColors {
  AppColors._();

  // Neutral Canvas & Surface
  static const Color background = Color(0xFFF6F8FA); // Cool stadium slate 50
  static const Color surface = Color(0xFFFFFFFF); // Pure White
  static const Color surfaceAlt = Color(0xFFF0F4F2); // Subtle mint-slate tint
  static const Color border = Color(0xFFE1E8E5); // Subtle greenish border
  static const Color borderHover = Color(0xFFCBD6D1); // Slate-green 300
  static const Color divider = Color(0xFFEBF1EE);

  // Cricbuzz Brand Primary (Cricket Green)
  static const Color primary = Color(0xFF009270); // Signature Cricbuzz Green
  static const Color primaryLight = Color(0xFF05B289); // Vibrant Cricket Turf Green
  static const Color primaryDark = Color(0xFF005944); // Deep Stadium Green
  static const Color primarySurface = Color(0xFFE8F6F1); // Light Mint Surface
  static const Color cricbuzzGreen = Color(0xFF009270);
  static const Color cricbuzzAmber = Color(0xFFF59E0B); // Cricket Gold Accent

  // Zest Brand Accents (Aligned to Cricbuzz Green)
  static const Color zestOrange = Color(0xFF009270); // Cricbuzz Green
  static const Color zestOrangeSurface = Color(0xFFE8F6F1); // Mint Surface
  static const Color zestOrangeHover = Color(0xFF007A5E); // Deeper Green Hover

  // Semantic & Status
  static const Color liveRed = Color(0xFFE11D48); // Rose 600
  static const Color liveRedSurface = Color(0xFFFFF1F2); // Rose 50
  static const Color scheduledAmber = Color(0xFFD97706); // Amber 600
  static const Color scheduledAmberSurface = Color(0xFFFFFBEB); // Amber 50
  static const Color completedGreen = Color(0xFF009270); // Cricbuzz Green
  static const Color completedGreenSurface = Color(0xFFE8F6F1); // Cricbuzz Mint Surface

  // Category Colors
  static const Color outdoorIndigo = Color(0xFF008365); // Grass Outdoor Green
  static const Color outdoorSurface = Color(0xFFE8F6F1); // Mint Surface
  static const Color indoorTeal = Color(0xFF0D9488); // Teal 600
  static const Color indoorSurface = Color(0xFFF0FDFA); // Teal 50

  // Typography
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF);
}
