import 'package:flutter/material.dart';

/// Clean palette matching Figma design system colors ("Color styles").
abstract final class AppColors {
  // ═════════════════ Figma Palette ═════════════════

  static const Color yellow = Color(0xFFFAF176);
  static const Color blue = Color(0xFFCBE6EF);
  static const Color lightGreen = Color(0xFFDEEE98);
  static const Color pink = Color(0xFFFCD4E1);
  static const Color background = Color(0xFFF6F4F2);
  static const Color backgroundCream = Color(0xFFF6F4F2);
  static const Color wrong = Color(0xFFB71C1C);
  static const Color trueColor = Color(0xFF00875A);

  // ═════════════════ Additional Unique UI Colors ═════════════════

  static const Color ink = Color(0xFF111111);
  static const Color logoMark = Color(0xFF1C1C1C);
  static const Color tagline = Color(0xFF9A9A9A);
  static const Color statusBarIcon = Color(0xFF1C1C1C);

  static const Color textPrimary = Color(0xFF191919);
  static const Color textSecondary = Color(0xFF74736F);

  static const Color badgeText = Color(0xFF6D6A64);
  static const Color badgeBg = Color(0xFFEBE8E3);
  static const Color cardBorder = Color(0xFFE8E5DF);
  static const Color checkedInBg = Color(0xFFD7EAE0);

  static const Color glowPeach = Color(0xFFFFD9B0);
  static const Color glowLavender = Color(0xFFE4D4F8);
}
