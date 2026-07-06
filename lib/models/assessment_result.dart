class AssessmentResult {
  /// Neural Calm Score, 0–100. Higher = calmer.
  final double overall;

  /// Calm % per questionnaire category (section title -> 0–100).
  final Map<String, double> categories;

  /// Lowest-scoring category — the user's focus area.
  final String focusArea;

  /// Human-readable insight for the focus area.
  final String insight;

  /// True if optional biometric inputs contributed to the score.
  final bool usedBiometrics;

  final DateTime takenAt;

  const AssessmentResult({
    required this.overall,
    required this.categories,
    required this.focusArea,
    required this.insight,
    required this.usedBiometrics,
    required this.takenAt,
  });

  Map<String, dynamic> toJson() => {
        'overall': overall,
        'categories': categories,
        'focusArea': focusArea,
        'insight': insight,
        'usedBiometrics': usedBiometrics,
        'takenAt': takenAt.toIso8601String(),
      };

  factory AssessmentResult.fromJson(Map<String, dynamic> json) {
    return AssessmentResult(
      overall: (json['overall'] as num).toDouble(),
      categories: (json['categories'] as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toDouble())),
      focusArea: json['focusArea'] as String,
      insight: json['insight'] as String? ?? '',
      usedBiometrics: json['usedBiometrics'] as bool? ?? false,
      takenAt:
          DateTime.tryParse(json['takenAt'] as String? ?? '') ?? DateTime.now(),
    );
  }
}
