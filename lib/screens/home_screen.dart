import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/score_ring.dart';
import 'assessment/assessment_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final result = state.latestResult;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Welcome back',
                style: const TextStyle(
                    fontSize: 14, color: AppColors.inkMuted)),
            const SizedBox(height: 4),
            Text('Your calm, measured.',
                style: fraunces(size: 30, color: AppColors.primaryDeep)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppColors.border),
              ),
              child: result == null
                  ? Column(
                      children: [
                        const Icon(LucideIcons.sparkles,
                            size: 36, color: AppColors.primary),
                        const SizedBox(height: 14),
                        Text('No score yet', style: fraunces(size: 22)),
                        const SizedBox(height: 8),
                        const Text(
                          'Take your first assessment — 6 short sections, about 3 minutes — to get your Neural Calm Score.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppColors.inkMuted, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        PrimaryButton(
                          label: 'Take the assessment',
                          icon: LucideIcons.clipboardList,
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AssessmentScreen()),
                          ),
                        ),
                      ],
                    )
                  : Column(
                      children: [
                        Text('Your Neural Calm Score',
                            style: fraunces(size: 20)),
                        const SizedBox(height: 18),
                        ScoreRing(score: result.overall, size: 170),
                        const SizedBox(height: 18),
                        Text(
                          'Focus area: ${result.focusArea}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: AppColors.primaryDeep),
                        ),
                        const SizedBox(height: 16),
                        PrimaryButton(
                          label: 'Retake assessment',
                          onPressed: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => const AssessmentScreen()),
                          ),
                        ),
                      ],
                    ),
            ),
            const SizedBox(height: 16),
            if (state.history.length > 1)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.lavenderSoft,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    const Icon(LucideIcons.trendingUp,
                        color: AppColors.primaryDeep),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You've taken ${state.history.length} assessments. Score history syncs to your account in Step 4.",
                        style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.primaryDeep,
                            height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
