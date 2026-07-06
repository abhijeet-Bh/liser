import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Theme 0: Liser Purple
  static const Color primary = Color(0xFF7C3AED); // Vibrant violet
  static const Color secondary = Color(0xFF9D4EDD);

  // Theme 1: Midnight Blue
  static const Color bluePrimary = Color(0xFF2563EB);
  static const Color blueSecondary = Color(0xFF3B82F6);

  // Theme 2: Emerald Green
  static const Color emeraldPrimary = Color(0xFF059669);
  static const Color emeraldSecondary = Color(0xFF10B981);

  static Color getPrimary(int themeId) {
    if (themeId == 1) return bluePrimary;
    if (themeId == 2) return emeraldPrimary;
    return primary;
  }

  static Color getSecondary(int themeId) {
    if (themeId == 1) return blueSecondary;
    if (themeId == 2) return emeraldSecondary;
    return secondary;
  }

  // Backgrounds
  static const Color backgroundLight = Color(0xFFF9FAFB);
  static const Color backgroundDark = Color(0xFF09090B); // Deep dark

  // Surfaces (Cards, Bottom Sheets)
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark = Color(0xFF141417);
  
  // Elevated surfaces (Mini player, Dialogs)
  static const Color surfaceElevatedDark = Color(0xFF1C1C21);

  // Text Colors
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);

  static const Color textSecondary = Color(0xFF94A3B8);

  static const Color divider = Color(0xFF27272A);
  
  // Accents
  static const Color lossLessBadge = Color(0xFF10B981); // Emerald
}
