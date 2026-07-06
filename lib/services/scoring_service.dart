import '../constants/questions.dart';
import '../models/assessment_result.dart';

/// ─────────────────────────────────────────────────────────────
/// The Neural Calm Score engine.
///
/// How it works (edit the weights here when the NeuralCalm team
/// defines final weightings):
///
/// 1. Each answer is 0 (Never) .. 4 (Always).
/// 2. "Positive" questions (reverse: true) are flipped so that a
///    higher number always means MORE distress.
/// 3. Each section becomes a calm % : 100 = fully calm, 0 = max
///    distress on every question.
/// 4. Overall score = simple average of the 5 section scores.
/// 5. Biometrics are OPTIONAL — "use if present". If the user
///    entered any, they blend in at 20% (questionnaire keeps 80%).
///    If they entered none, the score is 100% questionnaire and
///    nothing is penalised.
/// ─────────────────────────────────────────────────────────────
class ScoringService {
  static const _questionnaireWeight = 0.8; // when biometrics present

  static AssessmentResult score({
    required Map<String, int> answers,
    double? sleepHours,
    int? restingHeartRate,
    int? exerciseMinutes,
  }) {
    // 1–3: per-section calm percentages.
    final categories = <String, double>{};
    for (final section in sections) {
      var distress = 0.0;
      for (final q in section.questions) {
        final raw = (answers[q.id] ?? 0).toDouble();
        distress += q.reverse ? 4.0 - raw : raw;
      }
      final maxDistress = section.questions.length * 4.0;
      categories[section.title] = (1.0 - distress / maxDistress) * 100.0;
    }

    // 4: questionnaire average.
    var overall =
        categories.values.reduce((a, b) => a + b) / categories.length;

    // 5: optional biometric blend.
    final bio = _biometricScore(sleepHours, restingHeartRate, exerciseMinutes);
    final usedBiometrics = bio != null;
    if (bio != null) {
      overall =
          overall * _questionnaireWeight + bio * (1.0 - _questionnaireWeight);
    }

    // Focus area = lowest category.
    var focusArea = categories.keys.first;
    categories.forEach((title, value) {
      if (value < categories[focusArea]!) focusArea = title;
    });

    return AssessmentResult(
      overall: overall.clamp(0.0, 100.0),
      categories: categories,
      focusArea: focusArea,
      insight: focusInsights[focusArea] ?? '',
      usedBiometrics: usedBiometrics,
      takenAt: DateTime.now(),
    );
  }

  /// Averages whichever biometric inputs the user provided.
  /// Returns null when none were entered.
  static double? _biometricScore(
      double? sleepHours, int? restingHeartRate, int? exerciseMinutes) {
    final parts = <double>[];

    if (sleepHours != null) {
      // 100 points inside the 7–9h band, tapering outside it.
      double s;
      if (sleepHours >= 7.0 && sleepHours <= 9.0) {
        s = 100.0;
      } else if (sleepHours < 7.0) {
        s = ((sleepHours - 4.0) / 3.0 * 100.0).clamp(0.0, 100.0);
      } else {
        s = ((11.0 - sleepHours) / 2.0 * 100.0).clamp(0.0, 100.0);
      }
      parts.add(s);
    }

    if (restingHeartRate != null) {
      // 100 at <= 60 bpm, 0 at >= 100 bpm, linear in between.
      final s = ((100.0 - restingHeartRate) / 40.0 * 100.0).clamp(0.0, 100.0);
      parts.add(s);
    }

    if (exerciseMinutes != null) {
      // 30+ minutes/day of movement = full points.
      final s = (exerciseMinutes / 30.0 * 100.0).clamp(0.0, 100.0);
      parts.add(s);
    }

    if (parts.isEmpty) return null;
    return parts.reduce((a, b) => a + b) / parts.length;
  }
}
