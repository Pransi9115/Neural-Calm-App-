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

class _BodyScreenState extends State<BodyScreen> {
  final _svc = HealthService();
  bool _loading = true;
  bool _connected = false;
  bool _needsInstall = false;
  HealthSummary _sum = const HealthSummary();

  @override
  void initState() {
    super.initState();
    _init();
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
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text(
              'Permission not granted. Open Health Connect → App permissions → NeuralCalm to allow access.')));
      return;
    }
    final s = await _svc.fetchSummary();
    if (!mounted) return;
    setState(() {
      _connected = true;
      _sum = s;
      _loading = false;
    });
  }

  Future<void> _refresh() async {
    final s = await _svc.fetchSummary();
    if (!mounted) return;
    setState(() => _sum = s);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body'), actions: [
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
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(15),
      children: [
        if (s.isEmpty)
          _card(
            icon: LucideIcons.info,
            title: 'Connected — waiting for data',
            child: const Text(
              'No readings found yet. Make sure your band\'s app (BMH Healthband, Zepp, Mi Fitness…) is set to sync with Health Connect, then pull down to refresh.',
              style: TextStyle(
                  fontSize: 12.5, color: AppColors.muted, height: 1.5),
            ),
          ),
        _metricCard(
          icon: LucideIcons.footprints,
          label: 'STEPS TODAY',
          value: s.steps?.toString() ?? '—',
          sub: 'From your phone or band',
        ),
        _metricCard(
          icon: LucideIcons.moon,
          label: 'SLEEP LAST NIGHT',
          value: s.sleepHours == null
              ? '—'
              : '${s.sleepHours!.toStringAsFixed(1)} h',
          sub: s.deepPct7d == null
              ? 'Deep-sleep % appears once your band syncs sleep stages'
              : 'Deep sleep ${s.deepPct7d!.toStringAsFixed(0)}% (7-day avg)',
        ),
        _metricCard(
          icon: LucideIcons.heart,
          label: 'RESTING HEART RATE',
          value: s.restingHeartRate == null
              ? '—'
              : '${s.restingHeartRate} bpm',
          sub: 'Most recent reading',
        ),
        _metricCard(
          icon: LucideIcons.activity,
          label: 'HRV — 7-DAY AVERAGE',
          value:
              s.hrv7d == null ? '—' : '${s.hrv7d!.toStringAsFixed(0)} ms',
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
        const SizedBox(height: 6),
        _card(
          icon: LucideIcons.clipboardCheck,
          title: 'Used in your assessment',
          child: const Text(
            'When you take an assessment, the Biometric Data answers for HRV trend and deep sleep are filled in automatically from this data (you can always change them).',
            style: TextStyle(
                fontSize: 12.5, color: AppColors.muted, height: 1.5),
          ),
        ),
      ],
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
