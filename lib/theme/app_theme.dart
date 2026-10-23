import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary Emerald Palette
  static const Color primary = Color(0xFF1B4D2E);
  static const Color primaryLight = Color(0xFFABD0AF);
  static const Color primaryContainer = Color(0xFFD6E8D8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Background & Surfaces
  static const Color bgLight = Color(0xFFFAF9F5);
  static const Color bgDark = Color(0xFF121411);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color surfaceDark = Color(0xFF1A1D18);
  static const Color surfaceContainerHighLight = Color(0xFFE8E8E4);
  static const Color surfaceContainerHighDark = Color(0xFF252A23);

  // Accents
  static const Color secondary = Color(0xFFE8DFCF);
  static const Color tertiaryAlert = Color(0xFF73464F);
  static const Color alertBg = Color(0xFFFDF2F4);
  static const Color alertText = Color(0xFF9E2A3F);

  // Status & Utility
  static const Color success = Color(0xFF1B7B43);
  static const Color warning = Color(0xFFD97706);
  static const Color info = Color(0xFF2563EB);
  static const Color outlineLight = Color(0xFFE2E4DE);
  static const Color outlineDark = Color(0xFF333830);
  static const Color textPrimaryLight = Color(0xFF1A1C19);
  static const Color textSecondaryLight = Color(0xFF5B6058);
  static const Color textPrimaryDark = Color(0xFFE2E4DE);
  static const Color textSecondaryDark = Color(0xFFA1A69D);
}

class AppTheme {
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: AppColors.bgLight,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      surface: AppColors.surfaceLight,
      surfaceContainerHigh: AppColors.surfaceContainerHighLight,
      outline: AppColors.outlineLight,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.hankenGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      displayMedium: GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryLight,
      ),
      titleLarge: GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      titleMedium: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
      bodyLarge: GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryLight,
      ),
      bodyMedium: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryLight,
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryLight,
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bgDark,
    primaryColor: AppColors.primaryLight,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryLight,
      onPrimary: AppColors.bgDark,
      secondary: AppColors.surfaceContainerHighDark,
      surface: AppColors.surfaceDark,
      surfaceContainerHigh: AppColors.surfaceContainerHighDark,
      outline: AppColors.outlineDark,
    ),
    textTheme: TextTheme(
      displayLarge: GoogleFonts.hankenGrotesk(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      displayMedium: GoogleFonts.hankenGrotesk(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: AppColors.textPrimaryDark,
      ),
      titleLarge: GoogleFonts.hankenGrotesk(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      titleMedium: GoogleFonts.hankenGrotesk(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
      bodyLarge: GoogleFonts.hankenGrotesk(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: AppColors.textPrimaryDark,
      ),
      bodyMedium: GoogleFonts.hankenGrotesk(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.textSecondaryDark,
      ),
      labelLarge: GoogleFonts.jetBrainsMono(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimaryDark,
      ),
    ),
  );
}
