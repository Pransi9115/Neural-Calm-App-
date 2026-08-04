import 'dart:async';
import 'dart:io' show Platform;

import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../services/health_service.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// Body tab — live device health dashboard.
/// Reads steps, sleep, resting HR and HRV from Health Connect
/// (Android) / Apple Health (iOS). Any band that syncs into those
/// (BMH Healthband, Mi/Amazfit via Zepp or Mi Fitness, Samsung,
/// Fitbit…) automatically appears here.
class BodyScreen extends StatefulWidget {
  const BodyScreen({super.key});
  @override
  State<BodyScreen> createState() => _BodyScreenState();
}

class _BodyScreenState extends State<BodyScreen>
    with WidgetsBindingObserver {
  final _svc = HealthService();

  /// Daily step target. Local for now; move it to the profile when
  /// there is a place for the user to set it.
  static const int _stepGoal = 5000;

  /// Health Connect and Apple Health receive data whenever the
  /// band's own app syncs, and have no way to notify us. Polling
  /// while the tab is open is the only way a new reading appears
  /// without the user pulling to refresh.
  Timer? _poll;
  bool _loading = true;
  bool _connected = false;
  bool _needsInstall = false;
  HealthSummary _sum = const HealthSummary();
  Map<String, int>? _probe;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _init();
  }

  @override
  void dispose() {
    _poll?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  /// Re-read on return to the app: the usual pattern is to open the
  /// band's app, sync, then come back here expecting fresh numbers.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _connected) _refresh();
  }

  void _startPolling() {
    _poll?.cancel();
    _poll = Timer.periodic(const Duration(minutes: 2), (_) {
      if (mounted && _connected) _refresh();
    });
  }

  Future<void> _init() async {
    final connected = await _svc.isConnected();
    if (connected) {
      final s = await _svc.fetchSummary();
      Map<String, int>? probe;
      if (s.isEmpty) probe = await _svc.probe();
      if (!mounted) return;
      setState(() {
        _connected = true;
        _sum = s;
        _probe = probe;
        _loading = false;
      });
      _startPolling();
    } else {
      final needs = await _svc.healthConnectNeedsInstall();
      if (!mounted) return;
      setState(() {
        _needsInstall = needs;
        _loading = false;
      });
    }
  }

  Future<void> _connect() async {
    setState(() => _loading = true);
    if (_needsInstall) {
      await _svc.openHealthConnectInstall();
      final still = await _svc.healthConnectNeedsInstall();
      if (still) {
        if (!mounted) return;
        setState(() => _loading = false);
        return;
      }
    }
    final ok = await _svc.connect();
    if (!ok) {
      // Health Connect sometimes reports "denied" even when access is
      // granted (no dialog shown). Open the dashboard anyway — the
      // per-type record counts there reveal the true state.
      await _svc.markConnected();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            duration: Duration(seconds: 6),
            content: Text(
                'Could not verify permission — opening the dashboard. If every record count shows 0, re-check Health Connect → App permissions → neuralcalm.')));
      }
    }
    final s = await _svc.fetchSummary();
    Map<String, int>? probe;
    if (s.isEmpty) probe = await _svc.probe();
    if (!mounted) return;
    setState(() {
      _connected = true;
      _sum = s;
      _probe = probe;
      _loading = false;
    });
    _startPolling();
  }

  Future<void> _refresh() async {
    final s = await _svc.fetchSummary();
    Map<String, int>? probe;
    if (s.isEmpty) probe = await _svc.probe();
    if (!mounted) return;
    setState(() {
      _sum = s;
      _probe = probe;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Monitoring'), actions: [
        if (_connected)
          IconButton(
              onPressed: _refresh,
              icon: const Icon(LucideIcons.refreshCw, size: 19)),
      ]),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : !_connected
              ? _connectView()
              : RefreshIndicator(onRefresh: _refresh, child: _dashboard()),
    );
  }

  // ── Not connected yet ────────────────────────────────────────
  Widget _connectView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child:
            Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            width: 88,
            height: 88,
            decoration: const BoxDecoration(
                color: AppColors.purplePale, shape: BoxShape.circle),
            child: const Icon(LucideIcons.heartPulse,
                size: 40, color: AppColors.purple),
          ),
          const SizedBox(height: 18),
          Text('No health data yet', style: cormorant(size: 22)),
          const SizedBox(height: 8),
          Text(
            _needsInstall
                ? 'Your phone needs the free Health Connect app (by Google) first — tap below to install it, then come back and connect.'
                : 'Connect Health Connect / Apple Health to bring your band\'s HRV, sleep and heart data into NeuralCalm. Works with the BMH Healthband, Mi and Amazfit (enable Health Connect sync in the Zepp / Mi Fitness app), Samsung, Fitbit and more.',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontSize: 13.5, color: AppColors.muted, height: 1.5),
          ),
          const SizedBox(height: 20),
          PrimaryButton(
            label: _needsInstall
                ? 'Install Health Connect'
                : 'Connect health data',
            onPressed: _connect,
          ),
        ]),
      ),
    );
  }

  // ── Connected dashboard ─────────────────────────────────────
  Widget _dashboard() {
    final s = _sum;
    final hrvDelta = s.hrvDeltaPct;
    final stress = s.stressLevel;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      children: [
        _freshnessBar(),
        const SizedBox(height: 4),

        // ── STEPS, with goal ring ───────────────────────────
        _stepsCard(s.steps),

        // ── Everything below is always shown, even with no
        //    reading. A card that vanishes when empty makes the
        //    app look broken; a card that says what it is waiting
        //    for teaches the user what their band needs to send.
        _metricCard(
          icon: LucideIcons.heart,
          label: 'RESTING HEART RATE',
          value: s.restingHeartRate == null
              ? '\u2014'
              : '${s.restingHeartRate} bpm',
          sub: s.restingHeartRate == null
              ? 'Needs a band or watch worn at rest'
              : 'Most recent reading',
        ),
        _metricCard(
          icon: LucideIcons.activity,
          label: 'HRV \u2014 7-DAY AVERAGE',
          value:
              s.hrv7d == null ? '\u2014' : '${s.hrv7d!.toStringAsFixed(0)} ms',
          sub: hrvDelta == null
              ? 'Baseline appears after ~a week of readings'
              : hrvDelta >= 0
                  ? '${hrvDelta.toStringAsFixed(0)}% above your baseline'
                  : '${hrvDelta.abs().toStringAsFixed(0)}% below your baseline',
          subColor: hrvDelta == null
              ? null
              : hrvDelta >= -5
                  ? AppColors.green
                  : AppColors.red,
        ),
        _metricCard(
          icon: LucideIcons.brain,
          label: 'STRESS LEVEL',
          value: stress == null ? '\u2014' : '$stress/100',
          // Labelled as derived on purpose. No wrist device measures
          // stress; this is inferred from HRV against the baseline,
          // and presenting it as a reading would be a false claim.
          sub: stress == null
              ? 'Calculated from HRV once a baseline exists'
              : 'Derived from HRV, not a direct measurement',
          subColor: stress == null
              ? null
              : stress <= 40
                  ? AppColors.green
                  : stress <= 70
                      ? AppColors.amber
                      : AppColors.red,
        ),
        _metricCard(
          icon: LucideIcons.moon,
          label: 'SLEEP LAST NIGHT',
          value: s.sleepHours == null
              ? '\u2014'
              : '${s.sleepHours!.toStringAsFixed(1)} h',
          sub: s.deepPct7d == null
              ? 'Wear your band overnight to track sleep stages'
              : 'Deep sleep ${s.deepPct7d!.toStringAsFixed(0)}% (7-day avg)',
        ),
        _metricCard(
          icon: LucideIcons.droplets,
          label: 'BLOOD OXYGEN (SPO2)',
          value: s.spo2 == null ? '\u2014' : '${s.spo2!.toStringAsFixed(0)}%',
          sub: s.spo2 == null
              ? 'Appears once your band syncs SpO2 readings'
              : 'Latest reading',
        ),
        _metricCard(
          icon: LucideIcons.thermometer,
          label: 'BODY TEMPERATURE',
          value:
              s.tempC == null ? '\u2014' : '${s.tempC!.toStringAsFixed(1)} \u00B0C',
          sub: s.tempC == null
              ? 'Appears once your band syncs skin temperature'
              : 'Latest reading',
        ),
        _metricCard(
          icon: LucideIcons.gauge,
          label: 'BLOOD PRESSURE',
          value: (s.bpSys == null || s.bpDia == null)
              ? '\u2014'
              : '${s.bpSys}/${s.bpDia}',
          sub: (s.bpSys == null || s.bpDia == null)
              ? 'Needs a cuff or band that records blood pressure'
              : 'Latest reading (mmHg)',
        ),
        _metricCard(
          icon: LucideIcons.flame,
          label: 'CALORIES TODAY',
          value: s.kcalTotal != null
              ? '${s.kcalTotal!.toStringAsFixed(0)} kcal'
              : s.kcalActive != null
                  ? '${s.kcalActive!.toStringAsFixed(0)} kcal'
                  : '\u2014',
          sub: s.kcalActive != null && s.kcalTotal != null
              ? '${s.kcalActive!.toStringAsFixed(0)} kcal active'
              : s.kcalActive != null
                  ? 'Active burn'
                  : 'From your phone or band',
        ),
        _metricCard(
          icon: LucideIcons.route,
          label: 'DISTANCE TODAY',
          value: s.distanceKm == null
              ? '\u2014'
              : '${s.distanceKm!.toStringAsFixed(2)} km',
          sub: s.distanceKm == null ? 'From your phone or band' : null,
        ),

        // ── Diagnostics, only when nothing came back at all ──
        if (s.isEmpty) ...[
          const SizedBox(height: 6),
          _card(
            icon: LucideIcons.info,
            title: 'Connected \u2014 waiting for data',
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Permission is fine, but no readings have arrived yet. '
                    'Your phone alone can only count steps \u2014 heart rate, '
                    'HRV and sleep need a band or watch. Open your band\'s '
                    'own app, switch on syncing to Health, then pull down '
                    'to refresh here.',
                    style: TextStyle(
                        fontSize: 12.5, color: AppColors.muted, height: 1.5),
                  ),
                  if (_probe != null) ...[
                    const SizedBox(height: 8),
                    Text('RECORDS FOUND (LAST 7 DAYS)', style: secLabel()),
                    const SizedBox(height: 4),
                    Text(
                      _probe!.entries
                          .map((e) => '${e.key}: ${e.value}')
                          .join(' \u00B7 '),
                      style: const TextStyle(
                          fontSize: 10.5,
                          color: AppColors.muted,
                          height: 1.6),
                    ),
                  ],
                ]),
          ),
        ],

        const SizedBox(height: 6),
        _card(
          icon: LucideIcons.clipboardCheck,
          title: 'Used in your assessment',
          child: const Text(
            'When you take an assessment, the Biometric Data answer for '
            'HRV trend is filled in automatically from this data.',
            style: TextStyle(
                fontSize: 12.5, color: AppColors.muted, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  // ── Freshness ────────────────────────────────────────────────
  /// Apple Health and Health Connect are stores, not live feeds: a
  /// reading arrives whenever the band's own app last synced. Saying
  /// when we read it is the difference between a number the user can
  /// trust and one they cannot place.
  Widget _freshnessBar() {
    final t = _sum.fetchedAt;
    final label = t == null ? 'Not read yet' : _ago(t);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 2),
      child: Row(children: [
        const Icon(LucideIcons.refreshCw, size: 11, color: AppColors.muted),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            '$_sourceName \u00B7 $label',
            style: const TextStyle(fontSize: 11, color: AppColors.muted),
          ),
        ),
      ]),
    );
  }

  String get _sourceName =>
      Platform.isAndroid ? 'Health Connect' : 'Apple Health';

  static String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inSeconds < 45) return 'updated just now';
    if (d.inMinutes < 60) return 'updated ${d.inMinutes} min ago';
    if (d.inHours < 24) return 'updated ${d.inHours} h ago';
    return 'updated ${d.inDays} d ago';
  }

  // ── Steps, with goal ─────────────────────────────────────────
  Widget _stepsCard(int? steps) {
    final v = steps ?? 0;
    final pct = (v / _stepGoal).clamp(0.0, 1.0);
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 38,
            height: 38,
            decoration: const BoxDecoration(
                color: AppColors.purplePale, shape: BoxShape.circle),
            child: const Icon(LucideIcons.footprints,
                size: 18, color: AppColors.purple),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('STEPS TODAY', style: secLabel()),
                  const SizedBox(height: 3),
                  Row(crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(steps?.toString() ?? '\u2014',
                            style: cormorant(size: 26)),
                        Text('  / $_stepGoal',
                            style: const TextStyle(
                                fontSize: 12.5, color: AppColors.muted)),
                      ]),
                ]),
          ),
        ]),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: LinearProgressIndicator(
            value: pct,
            minHeight: 7,
            backgroundColor: AppColors.purplePale,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.purple),
          ),
        ),
        const SizedBox(height: 7),
        Text(
          '${(pct * 100).toStringAsFixed(0)}% of $_stepGoal steps goal',
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted),
        ),
      ]),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required String label,
    required String value,
    String? sub,
    Color? subColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Row(children: [
        Container(
          width: 42,
          height: 42,
          decoration: const BoxDecoration(
              color: AppColors.purplePale, shape: BoxShape.circle),
          child: Icon(icon, size: 20, color: AppColors.purple),
        ),
        const SizedBox(width: 13),
        Expanded(
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, style: secLabel()),
            const SizedBox(height: 2),
            Text(value,
                style: cormorant(size: 24, color: AppColors.navy)),
            if (sub != null)
              Text(sub,
                  style: TextStyle(
                      fontSize: 11,
                      color: subColor ?? AppColors.muted)),
          ]),
        ),
      ]),
    );
  }

  Widget _card(
      {required IconData icon,
      required String title,
      required Widget child}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Icon(icon, size: 16, color: AppColors.purple),
          const SizedBox(width: 7),
          Expanded(child: Text(title, style: cormorant(size: 17))),
        ]),
        const SizedBox(height: 7),
        child,
      ]),
    );
  }
}
