import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../models/assessment_result.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/category_bar.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/score_ring.dart';

class ResultsScreen extends StatelessWidget {
  final AssessmentResult result;

  const ResultsScreen({super.key, required this.result});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 12),
            Center(
                child: Text('Your Neural Calm Score',
                    style:
                        fraunces(size: 26, color: AppColors.primaryDeep))),
            const SizedBox(height: 6),
            Center(
              child: Text(
                result.usedBiometrics
                    ? 'Questionnaire + biometrics'
                    : 'Questionnaire only',
                style: const TextStyle(
                    fontSize: 13, color: AppColors.inkMuted),
              ),
            ),
            const SizedBox(height: 24),
            Center(child: ScoreRing(score: result.overall)),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Breakdown', style: fraunces(size: 19)),
                  const SizedBox(height: 8),
                  ...result.categories.entries.map(
                      (e) => CategoryBar(label: e.key, value: e.value)),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.lavenderSoft,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(LucideIcons.target,
                          size: 20, color: AppColors.primaryDeep),
                      const SizedBox(width: 10),
                      Text('Focus area: ${result.focusArea}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.primaryDeep)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(result.insight,
                      style: const TextStyle(
                          color: AppColors.primaryDeep, height: 1.5)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: 'Done',
              onPressed: () => Navigator.of(context).pop(),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'This is a wellbeing tool, not a medical diagnosis.',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
