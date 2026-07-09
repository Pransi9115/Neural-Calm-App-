import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.purple,
      primary: AppColors.purple,
      surface: AppColors.surface,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.outfitTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: GoogleFonts.cormorantGaramond(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    dividerColor: AppColors.border,
  );
}

/// Cormorant Garamond — headings, scores, the wordmark serif.
TextStyle cormorant({
  double size = 24,
  FontWeight weight = FontWeight.w600,
  Color color = AppColors.navy,
}) {
  return GoogleFonts.cormorantGaramond(
      fontSize: size, fontWeight: weight, color: color);
}

/// Small-caps clinical section label ("DOMAIN RESULTS" etc.)
TextStyle secLabel({Color color = AppColors.muted, double size = 10}) {
  return TextStyle(
    fontSize: size,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.0,
    color: color,
  );
}
