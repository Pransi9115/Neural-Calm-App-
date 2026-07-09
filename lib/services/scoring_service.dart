import '../constants/questions.dart';
import '../models/assessment_result.dart';

/// ─────────────────────────────────────────────────────────────
/// Scoring — IDENTICAL to the PHP backend (index.php / score.php):
///   · each answer 0–4
///   · domain score = round( sum / (n × 4) × 100 )   (0–100)
///   · overall = round( Σ(domain × weight) / Σ(weight) )
///   · LOWER = calmer. Zones: Optimal 0–35 · Moderate 36–60 ·
///     Elevated 61–100
///   · a response is flagged when its value ≥ the question's
///     flagThreshold (thresholds copied from the coach tool)
/// ─────────────────────────────────────────────────────────────
class ScoringService {
  static AssessmentResult score(Map<String, int> answers, {required int number}) {
    final domainScores = <String, int>{};
    final flags = <Flag>[];
    double weightedSum = 0, weightTotal = 0;

    for (final d in domains) {
      var total = 0;
      for (var i = 0; i < d.questions.length; i++) {
        final q = d.questions[i];
        final v = answers['${d.id}_$i'] ?? 0;
        total += v;
        if (v >= q.flagThreshold) {
          flags.add(Flag(
            label: '${d.title} Q${i + 1}',
            answerText: q.options[v],
            value: v + 1, // shown to professionals as 1–5
          ));
        }
      }
      final score = ((total / (d.questions.length * 4)) * 100).round();
      domainScores[d.title] = score;
      weightedSum += score * d.weight;
      weightTotal += d.weight;
    }

    return AssessmentResult(
      overall: (weightedSum / weightTotal).round(),
      domainScores: domainScores,
      flags: flags,
      takenAt: DateTime.now(),
      number: number,
    );
  }
}
