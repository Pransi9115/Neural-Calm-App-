import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Zones — identical to the backend (score.php).
/// LOWER score = calmer. Optimal 0–35 · Moderate 36–60 · Elevated 61–100.
enum Zone { optimal, moderate, elevated }

Zone zoneFor(num score) {
  if (score <= 35) return Zone.optimal;
  if (score <= 60) return Zone.moderate;
  return Zone.elevated;
}

extension ZoneX on Zone {
  String get label => switch (this) {
        Zone.optimal => 'Optimal',
        Zone.moderate => 'Moderate',
        Zone.elevated => 'Elevated',
      };
  String get shortLabel => switch (this) {
        Zone.optimal => 'OPT',
        Zone.moderate => 'MOD',
        Zone.elevated => 'ELEV',
      };
  Color get color => switch (this) {
        Zone.optimal => AppColors.green,
        Zone.moderate => AppColors.amber,
        Zone.elevated => AppColors.red,
      };
  Color get paleColor => switch (this) {
        Zone.optimal => AppColors.greenPale,
        Zone.moderate => AppColors.amberPale,
        Zone.elevated => AppColors.redPale,
      };
  Color get textColor => switch (this) {
        Zone.optimal => AppColors.green,
        Zone.moderate => AppColors.amber,
        Zone.elevated => AppColors.redDark,
      };
}
