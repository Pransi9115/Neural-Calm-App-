import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// One answer row: numbered 1–5, its own label, and the backend's
/// selection colours — 1–2 green, 3 amber, 4–5 red.
class AnswerOption extends StatelessWidget {
  final int index; // 0..4
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const AnswerOption({
    super.key,
    required this.index,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  Color get _selColor {
    if (index <= 1) return AppColors.green;
    if (index == 2) return AppColors.amber;
    return AppColors.red;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 140),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? _selColor : AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border:
              Border.all(color: selected ? _selColor : AppColors.border, width: 1.4),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(top: 1),
            decoration: BoxDecoration(
              color: selected
                  ? Colors.white.withValues(alpha: .25)
                  : AppColors.purplePale,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text('${index + 1}',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w700,
                    color: selected ? Colors.white : AppColors.purpleDeep,
                  )),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.35,
                  fontWeight: FontWeight.w500,
                  color: selected ? Colors.white : AppColors.ink,
                )),
          ),
          if (selected)
            const Padding(
              padding: EdgeInsets.only(left: 6),
              child: Icon(Icons.check, size: 15, color: Colors.white),
            ),
        ]),
      ),
    );
  }
}
