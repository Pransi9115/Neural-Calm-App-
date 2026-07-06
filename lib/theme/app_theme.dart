import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

ThemeData buildAppTheme() {
  final base = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.background,
    colorScheme: ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      primary: AppColors.primary,
      surface: AppColors.surface,
    ),
  );
  return base.copyWith(
    textTheme: GoogleFonts.interTextTheme(base.textTheme).apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      foregroundColor: AppColors.ink,
      elevation: 0,
      centerTitle: false,
    ),
    dividerColor: AppColors.border,
  );
}

/// Fraunces italic — the serif accent used for headings and the score,
/// matching the website's display type.
TextStyle fraunces({
  double size = 28,
  FontWeight weight = FontWeight.w600,
  Color color = AppColors.ink,
}) {
  return GoogleFonts.fraunces(
    fontSize: size,
    fontWeight: weight,
    fontStyle: FontStyle.italic,
    color: color,
  );
}
