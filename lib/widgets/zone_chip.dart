import 'package:flutter/material.dart';
import '../constants/zones.dart';

/// Clinical zone chip: "55 · MOD" or full "Moderate".
class ZoneChip extends StatelessWidget {
  final int score;
  final bool short;
  final bool showScore;
  const ZoneChip(
      {super.key, required this.score, this.short = true, this.showScore = true});

  @override
  Widget build(BuildContext context) {
    final zone = zoneFor(score);
    final label = short ? zone.shortLabel : zone.label;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: zone.paleColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        showScore ? '$score · $label' : label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          letterSpacing: .3,
          color: zone.textColor,
        ),
      ),
    );
  }
}
