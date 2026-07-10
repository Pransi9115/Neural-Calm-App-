import 'package:health/health.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// ─────────────────────────────────────────────────────────────
/// DEVICE HEALTH DATA — Android Health Connect + Apple HealthKit
/// via the `health` package.
///
/// Data flow: any band (BMH Healthband, Mi/Amazfit via Zepp or
/// Mi Fitness, Samsung, Fitbit…) syncs into Health Connect /
/// Apple Health, and NeuralCalm reads from there with the
/// user's permission.
///
/// Used by:
///  • Body tab — live dashboard (steps, sleep, resting HR, HRV)
///  • Assessment — auto-fills Biometric Data (d5):
///      Q1 (index 0) HRV vs baseline    ← device
///      Q3 (index 2) deep-sleep %       ← device
///      Q4 (index 3) score trend        ← app's own history
///    Q2 (EDA events) and Q5 (Anandanol) stay manual.
/// ─────────────────────────────────────────────────────────────

class HealthSummary {
  final int? steps; // today
  final double? sleepHours; // last night, total asleep
  final double? deepPct7d; // avg deep-sleep % over last 7 days
  final int? restingHeartRate; // most recent
  final double? hrv7d; // avg RMSSD last 7 days (ms)
  final double? hrvBaseline; // avg RMSSD previous 30 days (ms)

  const HealthSummary({
    this.steps,
    this.sleepHours,
    this.deepPct7d,
    this.restingHeartRate,
    this.hrv7d,
    this.hrvBaseline,
  });

  bool get isEmpty =>
      steps == null &&
      sleepHours == null &&
      deepPct7d == null &&
      restingHeartRate == null &&
      hrv7d == null;

  /// % change of recent HRV vs baseline (positive = above baseline).
  double? get hrvDeltaPct {
    if (hrv7d == null || hrvBaseline == null || hrvBaseline == 0) return null;
    return (hrv7d! - hrvBaseline!) / hrvBaseline! * 100;
  }
}

class HealthService {
  static const _prefKey = 'nc2_health_connected';
  final Health _health = Health();

  static const _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.SLEEP_SESSION,
    HealthDataType.SLEEP_DEEP,
    HealthDataType.SLEEP_LIGHT,
    HealthDataType.SLEEP_REM,
    HealthDataType.SLEEP_ASLEEP,
    HealthDataType.HEART_RATE,
    HealthDataType.RESTING_HEART_RATE,
    HealthDataType.HEART_RATE_VARIABILITY_RMSSD,
  ];

  Future<void> _configure() async {
    try {
      await _health.configure();
    } catch (_) {}
  }

  /// True on Android when the Health Connect app itself is missing
  /// (Android 13 and older need it from the Play Store).
  Future<bool> healthConnectNeedsInstall() async {
    try {
      await _configure();
      final status = await _health.getHealthConnectSdkStatus();
      return status != HealthConnectSdkStatus.sdkAvailable;
    } catch (_) {
      return false; // iOS or check unsupported → nothing to install
    }
  }

  Future<void> openHealthConnectInstall() async {
    try {
      await _health.installHealthConnect();
    } catch (_) {}
  }

  /// Ask the user for read permission on all our data types.
  Future<bool> connect() async {
    try {
      await _configure();
      final ok = await _health.requestAuthorization(
        _types,
        permissions:
            List.filled(_types.length, HealthDataAccess.READ),
      );
      if (ok) {
        final p = await SharedPreferences.getInstance();
        await p.setBool(_prefKey, true);
      }
      return ok;
    } catch (_) {
      return false;
    }
  }

  Future<bool> isConnected() async {
    final p = await SharedPreferences.getInstance();
    return p.getBool(_prefKey) ?? false;
  }

  Future<void> disconnect() async {
    final p = await SharedPreferences.getInstance();
    await p.setBool(_prefKey, false);
  }

  double _num(HealthDataPoint p) {
    final v = p.value;
    if (v is NumericHealthValue) return v.numericValue.toDouble();
    return 0;
  }

  Duration _dur(HealthDataPoint p) => p.dateTo.difference(p.dateFrom);

  Future<List<HealthDataPoint>> _fetch(
      List<HealthDataType> types, DateTime from, DateTime to) async {
    try {
      final data = await _health.getHealthDataFromTypes(
          types: types, startTime: from, endTime: to);
      return _health.removeDuplicates(data);
    } catch (_) {
      return const [];
    }
  }

  /// Everything the Body tab and the assessment need, in one call.
  Future<HealthSummary> fetchSummary() async {
    await _configure();
    final now = DateTime.now();

    // Steps today
    int? steps;
    try {
      steps = await _health.getTotalStepsInInterval(
          DateTime(now.year, now.month, now.day), now);
    } catch (_) {}

    // Sleep — last night (18:00 yesterday → now)
    double? sleepHours;
    final nightFrom =
        DateTime(now.year, now.month, now.day).subtract(const Duration(hours: 6));
    final night = await _fetch([
      HealthDataType.SLEEP_SESSION,
      HealthDataType.SLEEP_ASLEEP,
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
    ], nightFrom, now);
    if (night.isNotEmpty) {
      final sessions =
          night.where((p) => p.type == HealthDataType.SLEEP_SESSION);
      if (sessions.isNotEmpty) {
        sleepHours = sessions
                .map(_dur)
                .fold<Duration>(Duration.zero, (a, b) => a + b)
                .inMinutes /
            60.0;
      } else {
        final stages = night.where((p) =>
            p.type == HealthDataType.SLEEP_ASLEEP ||
            p.type == HealthDataType.SLEEP_DEEP ||
            p.type == HealthDataType.SLEEP_LIGHT ||
            p.type == HealthDataType.SLEEP_REM);
        if (stages.isNotEmpty) {
          sleepHours = stages
                  .map(_dur)
                  .fold<Duration>(Duration.zero, (a, b) => a + b)
                  .inMinutes /
              60.0;
        }
      }
    }

    // Deep-sleep % — last 7 days
    double? deepPct;
    final week = await _fetch([
      HealthDataType.SLEEP_DEEP,
      HealthDataType.SLEEP_LIGHT,
      HealthDataType.SLEEP_REM,
      HealthDataType.SLEEP_ASLEEP,
    ], now.subtract(const Duration(days: 7)), now);
    if (week.isNotEmpty) {
      int deepMin = 0, totalMin = 0;
      for (final p in week) {
        final m = _dur(p).inMinutes;
        if (p.type == HealthDataType.SLEEP_DEEP) deepMin += m;
        totalMin += m;
      }
      if (totalMin > 0 && deepMin > 0) deepPct = deepMin / totalMin * 100;
    }

    // Resting heart rate — most recent in 7 days
    int? restingHr;
    final rhr = await _fetch([HealthDataType.RESTING_HEART_RATE],
        now.subtract(const Duration(days: 7)), now);
    if (rhr.isNotEmpty) {
      rhr.sort((a, b) => a.dateTo.compareTo(b.dateTo));
      restingHr = _num(rhr.last).round();
    }

    // HRV — 7-day average + previous-30-day baseline
    double? hrv7, hrvBase;
    final hrvRecent = await _fetch(
        [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
        now.subtract(const Duration(days: 7)),
        now);
    if (hrvRecent.isNotEmpty) {
      hrv7 = hrvRecent.map(_num).reduce((a, b) => a + b) / hrvRecent.length;
    }
    final hrvOld = await _fetch(
        [HealthDataType.HEART_RATE_VARIABILITY_RMSSD],
        now.subtract(const Duration(days: 37)),
        now.subtract(const Duration(days: 7)));
    if (hrvOld.isNotEmpty) {
      hrvBase = hrvOld.map(_num).reduce((a, b) => a + b) / hrvOld.length;
    }

    return HealthSummary(
      steps: steps,
      sleepHours: sleepHours,
      deepPct7d: deepPct,
      restingHeartRate: restingHr,
      hrv7d: hrv7,
      hrvBaseline: hrvBase,
    );
  }

  // ── Assessment auto-fill (answer values 0–4) ────────────────

  /// d5 Q1: HRV trend vs personal baseline.
  static int? answerHrv(HealthSummary s) {
    final d = s.hrvDeltaPct;
    if (d == null) return null;
    if (d > 15) return 0; // well above baseline
    if (d > 5) return 1; // slightly above
    if (d >= -5) return 2; // at / near baseline
    if (d >= -15) return 3; // slightly below
    return 4; // well below
  }

  /// d5 Q3: average deep-sleep % over the past week.
  static int? answerDeepSleep(HealthSummary s) {
    final p = s.deepPct7d;
    if (p == null) return null;
    if (p > 25) return 0;
    if (p >= 20) return 1;
    if (p >= 15) return 2;
    if (p >= 10) return 3;
    return 4;
  }

  /// d5 Q4: Neural Calm Score trend — from the app's own history
  /// (LOWER score = calmer, so falling scores are improvement).
  static int? answerTrend(List<int> overallHistory) {
    if (overallHistory.length < 2) return null;
    final scores = overallHistory.length > 6
        ? overallHistory.sublist(overallHistory.length - 6)
        : overallHistory;
    final half = scores.length ~/ 2;
    final older = scores.sublist(0, half);
    final recent = scores.sublist(half);
    final avgO = older.reduce((a, b) => a + b) / older.length;
    final avgR = recent.reduce((a, b) => a + b) / recent.length;
    final improve = avgO - avgR; // positive = score dropping = better
    if (improve >= 8) return 0;
    if (improve >= 3) return 1;
    if (improve > -3) return 2;
    if (improve > -8) return 3;
    return 4;
  }
}
