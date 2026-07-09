import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../constants/questions.dart';
import '../../providers/app_state.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/zone_chip.dart';
import 'assessment_screen.dart';

/// The Assess tab: consultation protocol + per-domain progress,
/// with live zone chips once a domain is complete.
class AssessmentIntroScreen extends StatefulWidget {
  const AssessmentIntroScreen({super.key});

  @override
  State<AssessmentIntroScreen> createState() => _AssessmentIntroScreenState();
}

class _AssessmentIntroScreenState extends State<AssessmentIntroScreen> {
  Map<String, int> _progress = {};

  Future<void> _load() async {
    final state = context.read<AppState>();
    final p = await state.storage.loadProgress(state.auth.currentUid);
    if (mounted) setState(() => _progress = p);
  }

  @override
  Widget build(BuildContext context) {
    final answered = _progress.length;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('$answered of $totalQuestions answered',
                  style: const TextStyle(
                      color: AppColors.onNavy, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('CONSULTATION PROTOCOL', style: secLabel()),
                    const SizedBox(height: 6),
                    const Text(
                      '6 domains · 5 questions each · about 5 minutes. Answers save automatically as you go — you can leave and continue any time.',
                      style: TextStyle(
                          fontSize: 12.5,
                          color: AppColors.muted,
                          height: 1.5),
                    ),
                  ]),
            ),
            const SizedBox(height: 12),
            for (var d = 0; d < domains.length; d++) _domainRow(d),
            const SizedBox(height: 8),
            PrimaryButton(
              label: answered == 0
                  ? 'Start assessment'
                  : answered == totalQuestions
                      ? 'Review & finish'
                      : 'Continue assessment',
              onPressed: () async {
                await Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const AssessmentScreen()));
                _load();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _domainRow(int index) {
    final d = domains[index];
    var count = 0, total = 0;
    for (var i = 0; i < d.questions.length; i++) {
      final v = _progress['${d.id}_$i'];
      if (v != null) {
        count++;
        total += v;
      }
    }
    Widget trailing;
    if (count == d.questions.length) {
      final score = ((total / (d.questions.length * 4)) * 100).round();
      trailing = ZoneChip(score: score);
    } else if (count > 0) {
      trailing = Text('$count of ${d.questions.length}',
          style: const TextStyle(fontSize: 11, color: AppColors.muted));
    } else {
      trailing = const Text('—',
          style: TextStyle(fontSize: 11, color: AppColors.muted));
    }
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(children: [
        Text('${index + 1}',
            style: cormorant(size: 18, color: AppColors.purple)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(d.title,
              style:
                  const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w600)),
        ),
        trailing,
      ]),
    );
  }
}
