import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool ghost;
  final Color background;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.ghost = false,
    this.background = AppColors.purple,
  });

  @override
  Widget build(BuildContext context) {
    final style = ghost
        ? FilledButton.styleFrom(
            backgroundColor: AppColors.surface,
            foregroundColor: AppColors.purpleDeep,
            side: const BorderSide(color: AppColors.border, width: 1.4),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          )
        : FilledButton.styleFrom(
            backgroundColor: background,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.purplePale,
            disabledForegroundColor: AppColors.muted,
            elevation: 3,
            shadowColor: background.withValues(alpha: .45),
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          );
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        style: style,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (icon != null) ...[Icon(icon, size: 19), const SizedBox(width: 9)],
          Text(label,
              style:
                  const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }
}
