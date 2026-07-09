import '../constants/zones.dart';

class Flag {
  final String label;      // e.g. "Sleep Q3"
  final String answerText; // e.g. "Often wake and struggle to sleep"
  final int value;         // 1..5 as shown to professionals

  const Flag({required this.label, required this.answerText, required this.value});

  Map<String, dynamic> toJson() =>
      {'label': label, 'answerText': answerText, 'value': value};

  factory Flag.fromJson(Map<String, dynamic> j) => Flag(
        label: j['label'] as String,
        answerText: j['answerText'] as String? ?? '',
        value: (j['value'] as num?)?.toInt() ?? 0,
      );
}

/// One completed assessment — backend-identical scoring.
/// LOWER = calmer. Zones: Optimal 0–35 · Moderate 36–60 · Elevated 61–100.
class AssessmentResult {
  final int overall;
  final Map<String, int> domainScores; // domain title -> 0–100
  final List<Flag> flags;
  final DateTime takenAt;
  final int number; // assessment #1, #2, …

  const AssessmentResult({
    required this.overall,
    required this.domainScores,
    required this.flags,
    required this.takenAt,
    required this.number,
  });

  Zone get zone => zoneFor(overall);

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'domainScores': domainScores,
        'flags': flags.map((f) => f.toJson()).toList(),
        'takenAt': takenAt.toIso8601String(),
        'number': number,
      };

  factory AssessmentResult.fromJson(Map<String, dynamic> j) {
    return AssessmentResult(
      overall: (j['overall'] as num).toInt(),
      domainScores: (j['domainScores'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt())),
      flags: ((j['flags'] as List?) ?? const [])
          .map((e) => Flag.fromJson(e as Map<String, dynamic>))
          .toList(),
      takenAt: DateTime.tryParse(j['takenAt'] as String? ?? '') ?? DateTime.now(),
      number: (j['number'] as num?)?.toInt() ?? 1,
    );
  }
}
