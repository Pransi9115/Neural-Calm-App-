import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../constants/questions.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import 'assessment_screen.dart';

/// The "Assess" tab — overview of the 6 sections + start button.
class AssessmentIntroScreen extends StatelessWidget {
  const AssessmentIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Assessment',
                style: fraunces(size: 30, color: AppColors.primaryDeep)),
            const SizedBox(height: 8),
            const Text(
              '6 sections, about 3 minutes. Answer honestly — there are no right answers, only your answers.',
              style: TextStyle(color: AppColors.inkMuted, height: 1.5),
            ),
            const SizedBox(height: 24),
            ...sections.map((s) => _SectionRow(
                index: sections.indexOf(s) + 1,
                icon: s.icon,
                title: s.title)),
            const _SectionRow(
                index: 6,
                icon: LucideIcons.heartPulse,
                title: 'Biometric Data (optional)'),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Start assessment',
              icon: LucideIcons.play,
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const AssessmentScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  final int index;
  final IconData icon;
  final String title;

  const _SectionRow(
      {required this.index, required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Text('$index',
              style: fraunces(size: 18, color: AppColors.primary)),
          const SizedBox(width: 16),
          Icon(icon, size: 20, color: AppColors.primaryDeep),
          const SizedBox(width: 12),
          Text(title,
              style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
