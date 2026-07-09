import 'package:flutter/material.dart';
import '../constants/zones.dart';
import '../theme/app_colors.dart';
import 'zone_chip.dart';

class DomainBar extends StatelessWidget {
  final String label;
  final int score;
  const DomainBar({super.key, required this.label, required this.score});

  @override
  Widget build(BuildContext context) {
    final zone = zoneFor(score);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style:
                    const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            ZoneChip(score: score),
          ],
        ),
        const SizedBox(height: 5),
        ClipRRect(
          borderRadius: BorderRadius.circular(5),
          child: Container(
            height: 7,
            color: AppColors.purplePale,
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: (score / 100).clamp(0.0, 1.0),
              child: Container(color: zone.color),
            ),
          ),
        ),
      ]),
    );
  }
}
