import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// One row of the results breakdown: category name, bar, value.
class CategoryBar extends StatelessWidget {
  final String label;
  final double value; // 0–100, higher = calmer

  const CategoryBar({super.key, required this.label, required this.value});

  Color get _color {
    if (value >= 70) return AppColors.success;
    if (value >= 45) return AppColors.warning;
    return AppColors.danger;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600)),
              Text('${value.round()}',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: _color)),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Container(
              height: 8,
              color: AppColors.lavenderSoft,
              child: FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: (value / 100.0).clamp(0.0, 1.0),
                child: Container(color: _color),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
