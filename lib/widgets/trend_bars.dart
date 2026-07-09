import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mini bar chart of the last assessments (oldest → latest).
class TrendBars extends StatelessWidget {
  final List<int> scores;
  const TrendBars({super.key, required this.scores});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 76,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < scores.length; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Expanded(
              child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
                Text('${scores[i]}',
                    style: const TextStyle(
                        fontSize: 9, color: AppColors.muted)),
                const SizedBox(height: 2),
                Container(
                  height: 56 * (scores[i] / 100).clamp(0.06, 1.0),
                  decoration: BoxDecoration(
                    color: i == scores.length - 1
                        ? AppColors.purple
                        : AppColors.purplePale,
                    borderRadius:
                        const BorderRadius.vertical(top: Radius.circular(4)),
                  ),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
