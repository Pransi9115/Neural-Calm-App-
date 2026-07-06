import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../../constants/questions.dart';
import '../../providers/app_state.dart';
import '../../services/scoring_service.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_theme.dart';
import '../../widgets/answer_pill.dart';
import '../../widgets/primary_button.dart';
import 'results_screen.dart';

/// The full 6-step assessment:
/// steps 0–4 = the questionnaire sections, step 5 = optional biometrics.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _step = 0;
  final Map<String, int> _answers = {};

  final _sleepCtrl = TextEditingController();
  final _hrCtrl = TextEditingController();
  final _exerciseCtrl = TextEditingController();

  int get _totalSteps => sections.length + 1; // + biometrics
  bool get _isBiometricStep => _step == sections.length;

  bool get _stepComplete {
    if (_isBiometricStep) return true; // biometrics are optional
    return sections[_step].questions.every((q) => _answers.containsKey(q.id));
  }

  @override
  void dispose() {
    _sleepCtrl.dispose();
    _hrCtrl.dispose();
    _exerciseCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_step < _totalSteps - 1) {
      setState(() => _step++);
    } else {
      _finish();
    }
  }

  void _finish() {
    final result = ScoringService.score(
      answers: _answers,
      sleepHours: double.tryParse(_sleepCtrl.text.trim()),
      restingHeartRate: int.tryParse(_hrCtrl.text.trim()),
      exerciseMinutes: int.tryParse(_exerciseCtrl.text.trim()),
    );
    context.read<AppState>().saveResult(result);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => ResultsScreen(result: result)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(LucideIcons.x),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Step ${_step + 1} of $_totalSteps',
            style: const TextStyle(fontSize: 15)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / _totalSteps,
            backgroundColor: AppColors.lavenderSoft,
            color: AppColors.primary,
            minHeight: 4,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child:
                  _isBiometricStep ? _biometricStep() : _questionStep(),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  if (_step > 0)
                    OutlinedButton(
                      onPressed: () => setState(() => _step--),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryDeep,
                        side: const BorderSide(color: AppColors.border),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 16),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: const Text('Back'),
                    ),
                  if (_step > 0) const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: _step == _totalSteps - 1
                          ? 'See my score'
                          : 'Next',
                      onPressed: _stepComplete ? _next : null,
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

  Widget _questionStep() {
    final section = sections[_step];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.lavenderSoft,
                shape: BoxShape.circle,
              ),
              child:
                  Icon(section.icon, size: 22, color: AppColors.primaryDeep),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(section.title,
                      style: fraunces(
                          size: 24, color: AppColors.primaryDeep)),
                  Text(section.subtitle,
                      style: const TextStyle(
                          fontSize: 13, color: AppColors.inkMuted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...section.questions.map(_questionCard),
      ],
    );
  }

  Widget _questionCard(Question q) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(q.text,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(answerLabels.length, (i) {
              return AnswerPill(
                label: answerLabels[i],
                selected: _answers[q.id] == i,
                onTap: () => setState(() => _answers[q.id] = i),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _biometricStep() {
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: const BoxDecoration(
                color: AppColors.lavenderSoft,
                shape: BoxShape.circle,
              ),
              child: const Icon(LucideIcons.heartPulse,
                  size: 22, color: AppColors.primaryDeep),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Biometric Data',
                      style: fraunces(
                          size: 24, color: AppColors.primaryDeep)),
                  const Text('Optional — leave blank to skip',
                      style: TextStyle(
                          fontSize: 13, color: AppColors.inkMuted)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.only(top: 12),
          child: Text(
            'If you know these, they refine your score (20% weighting). In Step 5 the app will read them automatically from Apple Health / Health Connect.',
            style: TextStyle(color: AppColors.inkMuted, height: 1.5),
          ),
        ),
        _bioField(_sleepCtrl, 'Average sleep per night', 'e.g. 7.5', 'hours'),
        _bioField(_hrCtrl, 'Resting heart rate', 'e.g. 64', 'bpm'),
        _bioField(
            _exerciseCtrl, 'Movement / exercise per day', 'e.g. 30', 'min'),
      ],
    );
  }

  Widget _bioField(TextEditingController ctrl, String label, String hint,
      String suffix) {
    return Container(
      margin: const EdgeInsets.only(top: 14),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          TextField(
            controller: ctrl,
            keyboardType:
                const TextInputType.numberWithOptions(decimal: true),
            decoration: InputDecoration(
              hintText: hint,
              suffixText: suffix,
              filled: true,
              fillColor: AppColors.background,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.border),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
