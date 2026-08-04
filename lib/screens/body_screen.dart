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
      if (!mounted) return;
      setState(() {
        _connected = true;
        _sum = s;
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
    if (!mounted) return;
    setState(() {
      _connected = true;
      _sum = s;
      _loading = false;
    });
    _startPolling();
  }

  Future<void> _refresh() async {
    final s = await _svc.fetchSummary();
    if (!mounted) return;
    setState(() {
      _sum = s;
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
    final worn = _wearableSources.isNotEmpty;

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      children: [
        _freshnessBar(),
        const SizedBox(height: 4),

        _stepsCard(s),

        // Calories and distance are both "how much did I move today",
        // so they read better as a pair than stacked full width.
        Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Expanded(
            child: _miniCard(
              icon: LucideIcons.flame,
              label: 'CALORIES',
              value: s.kcalTotal != null
                  ? s.kcalTotal!.toStringAsFixed(0)
                  : s.kcalActive != null
                      ? s.kcalActive!.toStringAsFixed(0)
                      : '\u2014',
              unit: 'kcal',
            ),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: _miniCard(
              icon: LucideIcons.route,
              label: 'DISTANCE',
              value: s.distanceKm == null
                  ? '\u2014'
                  : s.distanceKm!.toStringAsFixed(2),
              unit: 'km',
            ),
          ),
        ]),

        // One heading carries the "you need a wearable" message, so
        // the cards underneath do not each repeat it.
        _sectionHeading(worn ? 'From your wearable' : 'Needs a band or watch'),

        _metricCard(
          icon: LucideIcons.heart,
          label: 'RESTING HEART RATE',
          value: s.restingHeartRate == null
              ? '\u2014'
              : '${s.restingHeartRate} bpm',
          sub: s.restingHeartRate == null ? null : 'Your most recent reading',
        ),
        _metricCard(
          icon: LucideIcons.gauge,
          label: 'BLOOD PRESSURE',
          value: (s.bpSys == null || s.bpDia == null)
              ? '\u2014'
              : '${s.bpSys}/${s.bpDia}',
          sub: (s.bpSys == null || s.bpDia == null) ? null : 'mmHg',
        ),
        _metricCard(
          icon: LucideIcons.thermometer,
          label: 'BODY TEMPERATURE',
          value: s.tempC == null
              ? '\u2014'
              : '${s.tempC!.toStringAsFixed(1)} \u00B0C',
          sub: s.tempC == null ? null : 'Your most recent reading',
        ),
        _metricCard(
          icon: LucideIcons.activity,
          label: 'HRV \u2014 7-DAY AVERAGE',
          value:
              s.hrv7d == null ? '\u2014' : '${s.hrv7d!.toStringAsFixed(0)} ms',
          sub: hrvDelta == null
              ? null
              : hrvDelta >= 0
                  ? '${hrvDelta.toStringAsFixed(0)}% above your usual'
                  : '${hrvDelta.abs().toStringAsFixed(0)}% below your usual',
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
          // Kept even when populated: no wrist device measures
          // stress, it is inferred from HRV, and dropping the caveat
          // would present an inference as a reading.
          sub: stress == null ? null : 'Worked out from your HRV',
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
              ? null
              : 'Deep sleep ${s.deepPct7d!.toStringAsFixed(0)}% this week',
        ),
        _metricCard(
          icon: LucideIcons.droplets,
          label: 'BLOOD OXYGEN (SPO2)',
          value: s.spo2 == null ? '\u2014' : '${s.spo2!.toStringAsFixed(0)}%',
          sub: s.spo2 == null ? null : 'Your most recent reading',
        ),

        if (!worn) ...[
          const SizedBox(height: 6),
          _bandHelpCard(),
        ],

        const SizedBox(height: 6),
        _card(
          icon: LucideIcons.clipboardCheck,
          title: 'Used in your assessment',
          child: const Text(
            'When you take an assessment, your HRV trend is filled in '
            'for you from this data.',
            style: TextStyle(
                fontSize: 12.5, color: AppColors.muted, height: 1.5),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  /// Half-width card for the pair under steps.
  Widget _miniCard({
    required IconData icon,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 11),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.cardShadow,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(
                color: AppColors.purplePale, shape: BoxShape.circle),
            child: Icon(icon, size: 15, color: AppColors.purple),
          ),
          const SizedBox(width: 9),
          Expanded(child: Text(label, style: secLabel())),
        ]),
        const SizedBox(height: 10),
        Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(value,
                    overflow: TextOverflow.ellipsis,
                    style: cormorant(size: 23)),
              ),
              const SizedBox(width: 4),
              Text(unit,
                  style: const TextStyle(
                      fontSize: 11.5, color: AppColors.muted)),
            ]),
      ]),
    );
  }

  /// Sources other than the phone itself. If this is empty, nothing
  /// on the wrist is reaching Health, which is the single most
  /// useful thing to tell the user.
  Set<String> get _wearableSources => _sum.allSources
      .where((n) {
        final l = n.toLowerCase();
        return !l.contains('iphone') &&
            !l.contains('phone') &&
            !l.contains('clock') &&
            !l.contains('health');
      })
      .toSet();

  Widget _sectionHeading(String text) => Padding(
        padding: const EdgeInsets.fromLTRB(3, 10, 3, 9),
        child: Text(text.toUpperCase(), style: secLabel()),
      );

  /// Plain-language help for the commonest situation by far: the
  /// band is on the wrist but its own app is not passing anything on.
  Widget _bandHelpCard() {
    return _card(
      icon: LucideIcons.info,
      title: 'Not seeing your band yet?',
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          'Your phone can count steps on its own, but heart rate, '
          'sleep and HRV have to come from something on your wrist.',
          style: const TextStyle(
              fontSize: 12.5, color: AppColors.muted, height: 1.5),
        ),
        const SizedBox(height: 10),
        _step(1, 'Open the app that came with your band and let it sync.'),
        _step(2,
            'In that app, turn on sharing with ${_sourceName.split(' ').first} Health.'),
        _step(3,
            'Open the Health app and check your heart rate is showing there.'),
        _step(4, 'Come back here and pull down to refresh.'),
        if (_sum.allSources.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text('SHARING WITH HEALTH RIGHT NOW', style: secLabel()),
          const SizedBox(height: 4),
          Text(
            _sum.allSources.join(' \u00B7 '),
            style: const TextStyle(
                fontSize: 11.5, color: AppColors.muted, height: 1.5),
          ),
        ],
      ]),
    );
  }

  Widget _step(int n, String text) => Padding(
        padding: const EdgeInsets.only(bottom: 7),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            margin: const EdgeInsets.only(top: 1, right: 9),
            decoration: const BoxDecoration(
                color: AppColors.purplePale, shape: BoxShape.circle),
            child: Text('$n',
                style: const TextStyle(
                    fontSize: 10.5,
                    color: AppColors.purple,
                    fontWeight: FontWeight.w700)),
          ),
          Expanded(
            child: Text(text,
                style: const TextStyle(
                    fontSize: 12.5, color: AppColors.ink, height: 1.45)),
          ),
        ]),
      );

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

  // ── Steps, with goal and a per-device split ──────────────────
  /// A phone counts only while carried, a band only while worn, so
  /// the two never match. Showing the split turns a confusing
  /// discrepancy into an explanation.
  Widget _stepsCard(HealthSummary s) {
    final steps = s.steps;
    final v = steps ?? 0;
    final pct = (v / _stepGoal).clamp(0.0, 1.0);

    final phoneName = s.stepSources.firstWhere(
        (n) => n.toLowerCase().contains('phone'),
        orElse: () => 'Phone');
    final wornName = s.stepSources.firstWhere(
        (n) => !n.toLowerCase().contains('phone') &&
            !n.toLowerCase().contains('clock') &&
            !n.toLowerCase().contains('health'),
        orElse: () => 'Band or watch');

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
                  Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
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
        Text('${(pct * 100).toStringAsFixed(0)}% of $_stepGoal steps goal',
            style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
        const SizedBox(height: 13),
        const Divider(height: 1, color: AppColors.border),
        const SizedBox(height: 11),
        Row(children: [
          Expanded(
            child: _stepSplit(
                phoneName, s.stepsPhone, LucideIcons.smartphone),
          ),
          Container(
              width: 1,
              height: 32,
              color: AppColors.border,
              margin: const EdgeInsets.symmetric(horizontal: 12)),
          Expanded(
            child: _stepSplit(wornName, s.stepsWearable, LucideIcons.watch),
          ),
        ]),
      ]),
    );
  }

  Widget _stepSplit(String name, int? value, IconData icon) {
    final has = value != null;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: [
        Icon(icon,
            size: 12,
            color: has ? AppColors.purple : AppColors.muted),
        const SizedBox(width: 5),
        Expanded(
          child: Text(name,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 10.5, color: AppColors.muted)),
        ),
      ]),
      const SizedBox(height: 4),
      Text(has ? value.toString() : '\u2014',
          style: TextStyle(
              fontSize: 17,
              height: 1.1,
              color: has ? AppColors.ink : AppColors.muted,
              fontWeight: FontWeight.w600)),
    ]);
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
