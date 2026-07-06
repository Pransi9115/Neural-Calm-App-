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
}
