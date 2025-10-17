import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFF00C853); // Bright Green
  static const Color primaryDark = Color(0xFF00A843);
  static const Color primaryLight = Color(0xFF5EFC82);

  // Background Colors
  static const Color background = Color(0xFFFFFFFF); // White
  static const Color surface = Color(0xFFF5F5F5); // Light Gray
  static const Color surfaceDark = Color(0xFF1E1E1E); // Dark for cards

  // Text Colors
  static const Color textPrimary = Color(0xFF000000); // Black
  static const Color textSecondary = Color(0xFF666666);
  static const Color textLight = Color(0xFFFFFFFF);
  static const Color textHint = Color(0xFF999999);

  // Accent Colors
  static const Color success = Color(0xFF00C853);
  static const Color error = Color(0xFFD32F2F);
  static const Color warning = Color(0xFFFFA000);
  static const Color info = Color(0xFF1976D2);

  // Voting Colors
  static const Color voteYes = Color(0xFF00C853);
  static const Color voteNo = Color(0xFFD32F2F);
  static const Color voteAbstain = Color(0xFF757575);

  // Status Colors
  static const Color statusPresent = Color(0xFF00C853);
  static const Color statusAbsent = Color(0xFFD32F2F);
  static const Color statusPending = Color(0xFFFFA000);

  // UI Elements
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFBDBDBD);
  static const Color shadow = Color(0x1A000000);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF00C853), Color(0xFF00A843)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF2C2C2C), Color(0xFF1E1E1E)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}
