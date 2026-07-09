import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../constants/zones.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/score_ring.dart';
import '../widgets/trend_bars.dart';
import '../widgets/wordmark.dart';
import 'assessment/assessment_screen.dart';
import 'assessment/report_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final latest = state.latestResult;
    final firstName = (state.name ?? 'there').split(' ').first;

    return Scaffold(
      appBar: AppBar(
        title: const Wordmark(fontSize: 18),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Hi, $firstName',
                  style: const TextStyle(
                      color: AppColors.onNavy, fontSize: 12.5)),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: latest == null
                ? Column(children: [
                    Text('CURRENT NEURAL CALM SCORE', style: secLabel()),
                    const SizedBox(height: 16),
                    Text('No score yet', style: cormorant(size: 22)),
                    const SizedBox(height: 8),
                    const Text(
                      'Take your first assessment — 6 domains, 30 questions, about 5 minutes — to get your Neural Calm Score.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.muted, height: 1.5, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      label: 'Take the assessment',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AssessmentScreen()),
                      ),
                    ),
                  ])
                : Column(children: [
                    Align(
                        alignment: Alignment.centerLeft,
                        child: Text('CURRENT NEURAL CALM SCORE',
                            style: secLabel())),
                    const SizedBox(height: 12),
                    GestureDetector(
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ReportScreen(result: latest)),
                      ),
                      child: ScoreRing(score: latest.overall),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 13, vertical: 5),
                      decoration: BoxDecoration(
                        color: latest.zone.paleColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${latest.zone.label.toUpperCase()} ZONE',
                        style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            letterSpacing: .5,
                            color: latest.zone.textColor),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Optimal 0–35  ·  Moderate 36–60  ·  Elevated 61–100',
                      style: TextStyle(fontSize: 10, color: AppColors.muted),
                    ),
                    const SizedBox(height: 14),
                    PrimaryButton(
                      label: 'Retake assessment',
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const AssessmentScreen()),
                      ),
                    ),
                    PrimaryButton(
                      label: 'View professional report',
                      ghost: true,
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => ReportScreen(result: latest)),
                      ),
                    ),
                  ]),
          ),
          if (state.history.length >= 2) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child:
                  Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                    'SCORE TREND — LAST ${state.history.length.clamp(2, 5)} ASSESSMENTS',
                    style: secLabel()),
                const SizedBox(height: 10),
                TrendBars(
                  scores: state.history
                      .map((r) => r.overall)
                      .toList()
                      .reversed
                      .take(5)
                      .toList()
                      .reversed
                      .toList(),
                ),
                const SizedBox(height: 8),
                Builder(builder: (_) {
                  final first = state.history.first.overall;
                  final last = state.history.last.overall;
                  final diff = first - last; // positive = improved (lower)
                  return Text(
                    diff > 0
                        ? '▼ $diff points since your first assessment — improving'
                        : diff < 0
                            ? '▲ ${-diff} points since your first assessment'
                            : 'Holding steady since your first assessment',
                    style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        color: diff > 0 ? AppColors.green : AppColors.muted),
                  );
                }),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}
