/// ─────────────────────────────────────────────────────────────
/// STEP 5 SEAM — device health data.
///
/// This interface is already used by the Body tab. In Step 5 it
/// will be implemented with the `health` package, which wraps
/// BOTH Apple HealthKit (iOS) and Google Health Connect (Android)
/// behind one API — no platform-specific code needed in screens.
/// ─────────────────────────────────────────────────────────────

class HealthSummary {
  final double? sleepHours;
  final int? restingHeartRate;
  final int? steps;

  const HealthSummary({this.sleepHours, this.restingHeartRate, this.steps});

  bool get isEmpty =>
      sleepHours == null && restingHeartRate == null && steps == null;
}

class HealthService {
  /// Step 5: request HealthKit / Health Connect permissions.
  Future<bool> requestPermissions() async => false;

  /// Step 5: pull last night's sleep, resting HR, and today's steps.
  Future<HealthSummary> fetchToday() async => const HealthSummary();
}
