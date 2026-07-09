import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/zone_chip.dart';
import 'assessment/report_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final latest = state.latestResult;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // navy account card
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                    color: AppColors.purple, shape: BoxShape.circle),
                child: Center(
                  child: Text(
                    (state.name ?? 'U').substring(0, 1).toUpperCase(),
                    style: cormorant(size: 20, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(state.name ?? 'Local account',
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700),
                          overflow: TextOverflow.ellipsis),
                      const SizedBox(height: 2),
                      Text('${state.email ?? ''} · Signed in',
                          style: const TextStyle(
                              color: AppColors.onNavy, fontSize: 10.5),
                          overflow: TextOverflow.ellipsis),
                    ]),
              ),
              if (latest != null) ZoneChip(score: latest.overall),
            ]),
          ),
          const SizedBox(height: 12),
          _card(children: [
            _row(
              icon: LucideIcons.history,
              title: 'Assessments taken',
              subtitle: state.history.isEmpty
                  ? 'None yet — start from the Assess tab'
                  : '${state.history.length} saved · synced to backend',
            ),
            const Divider(height: 1),
            _row(
              icon: LucideIcons.fileText,
              title: 'Professional reports',
              subtitle: latest == null
                  ? 'Available after your first assessment'
                  : 'View & share your latest report',
              onTap: latest == null
                  ? null
                  : () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ReportScreen(result: latest))),
            ),
            const Divider(height: 1),
            _row(
              icon: LucideIcons.heartPulse,
              title: 'Health data',
              subtitle: 'Not connected — coming next',
            ),
            const Divider(height: 1),
            _row(
              icon: LucideIcons.info,
              title: 'About NeuralCalm',
              subtitle: 'neuralcalm.com',
            ),
          ]),
          const SizedBox(height: 12),
          _card(children: [
            ListTile(
              leading:
                  const Icon(LucideIcons.logOut, color: AppColors.red),
              title: const Text('Sign out',
                  style: TextStyle(
                      color: AppColors.red, fontWeight: FontWeight.w600)),
              onTap: () => context.read<AppState>().signOut(),
            ),
          ]),
        ],
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(
      {required IconData icon,
      required String title,
      required String subtitle,
      VoidCallback? onTap}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.purpleDeep),
      title: Text(title,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style: const TextStyle(fontSize: 11.5, color: AppColors.muted)),
      trailing: onTap == null
          ? null
          : const Icon(LucideIcons.chevronRight,
              size: 17, color: AppColors.muted),
      onTap: onTap,
    );
  }
}
