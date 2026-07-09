import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/questions.dart';
import '../../providers/app_state.dart';
import '../../services/scoring_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/answer_option.dart';
import '../../widgets/primary_button.dart';
import 'report_screen.dart';

/// One question per screen, exactly the coach-tool questionnaire.
/// Answers auto-save; a half-finished assessment resumes where it
/// left off. Finishing opens the Professional report directly.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  Map<String, int> _answers = {};
  int _flatIndex = 0;
  bool _loaded = false;
  bool _finishing = false;

  // Flat list of (domainIndex, questionIndex).
  late final List<(int, int)> _order = [
    for (var d = 0; d < domains.length; d++)
      for (var q = 0; q < domains[d].questions.length; q++) (d, q)
  ];

  String _key(int flat) {
    final (d, q) = _order[flat];
    return '${domains[d].id}_$q';
  }

  @override
  void initState() {
    super.initState();
    _restore();
  }

  Future<void> _restore() async {
    final state = context.read<AppState>();
    final saved = await state.storage.loadProgress(state.auth.currentUid);
    var start = 0;
    for (var i = 0; i < _order.length; i++) {
      if (!saved.containsKey(_key(i))) {
        start = i;
        break;
      }
      if (i == _order.length - 1) start = i; // everything answered
    }
    if (!mounted) return;
    setState(() {
      _answers = saved;
      _flatIndex = start;
      _loaded = true;
    });
  }

  Future<void> _select(int value) async {
    final state = context.read<AppState>();
    setState(() => _answers[_key(_flatIndex)] = value);
    await state.storage.saveProgress(state.auth.currentUid, _answers);
  }

  bool get _isLast => _flatIndex == _order.length - 1;
  bool get _currentAnswered => _answers.containsKey(_key(_flatIndex));

  bool get _showSafetyCard {
    final (d, q) = _order[_flatIndex];
    if (domains[d].id != safeguardDomainId || q != safeguardQuestionIndex) {
      return false;
    }
    final v = _answers[_key(_flatIndex)];
    return v != null && v >= safeguardThreshold;
  }

  Future<void> _finish() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final state = context.read<AppState>();
    final result =
        ScoringService.score(_answers, number: state.history.length + 1);
    await state.saveResult(result, Map.of(_answers));
    await state.storage.clearProgress(state.auth.currentUid);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (_) => ReportScreen(result: result, isNew: true)));
  }

  void _showSupportResources() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('You are not alone', style: cormorant(size: 22)),
        content: const Text(
          'Thank you for answering honestly — that takes real courage.\n\n'
          'If these thoughts are present, please consider talking to someone you trust, your doctor, or a mental health professional. Suicide-prevention helplines are available in your country and are free and confidential.\n\n'
          'If you are in immediate danger, contact your local emergency services right now.',
          style: TextStyle(fontSize: 13.5, height: 1.55, color: AppColors.ink),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.purple)),
      );
    }
    final (d, q) = _order[_flatIndex];
    final domain = domains[d];
    final question = domain.questions[q];
    final selected = _answers[_key(_flatIndex)];

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(domain.title),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text('Domain ${d + 1} of ${domains.length}',
                  style:
                      const TextStyle(color: AppColors.onNavy, fontSize: 12)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('QUESTION ${q + 1} OF ${domain.questions.length}',
                        style: secLabel()),
                    if (_currentAnswered)
                      Text('✓ saved',
                          style: secLabel(color: AppColors.green)),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: _answers.length / _order.length,
                    minHeight: 5,
                    backgroundColor: AppColors.purplePale,
                    color: AppColors.purple,
                  ),
                ),
                const SizedBox(height: 14),
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
                        Text(question.text,
                            style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                height: 1.4)),
                        const SizedBox(height: 12),
                        for (var i = 0; i < question.options.length; i++)
                          AnswerOption(
                            index: i,
                            label: question.options[i],
                            selected: selected == i,
                            onTap: () => _select(i),
                          ),
                      ]),
                ),
                if (_showSafetyCard) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppColors.purplePale,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('You matter 💜',
                              style: cormorant(
                                  size: 18, color: AppColors.purpleDeep)),
                          const SizedBox(height: 6),
                          const Text(
                            'Thank you for being honest — that takes courage. Support is available whenever you need it, and talking to someone can genuinely help.',
                            style: TextStyle(
                                fontSize: 12.5,
                                height: 1.5,
                                color: AppColors.purpleDeep),
                          ),
                          const SizedBox(height: 10),
                          PrimaryButton(
                            label: 'View support resources',
                            background: AppColors.purpleDeep,
                            onPressed: _showSupportResources,
                          ),
                        ]),
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
            child: Row(children: [
              if (_flatIndex > 0)
                Expanded(
                  child: PrimaryButton(
                    label: 'Back',
                    ghost: true,
                    onPressed: () => setState(() => _flatIndex--),
                  ),
                ),
              if (_flatIndex > 0) const SizedBox(width: 10),
              Expanded(
                flex: 2,
                child: PrimaryButton(
                  label: _isLast ? 'Finish & view report' : 'Next question',
                  onPressed: !_currentAnswered
                      ? null
                      : _isLast
                          ? _finish
                          : () => setState(() => _flatIndex++),
                ),
              ),
            ]),
          ),
        ]),
      ),
    );
  }
}
