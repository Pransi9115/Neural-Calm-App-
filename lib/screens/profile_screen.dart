import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../firebase_options.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final latest = state.latestResult;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text('Profile',
                style: fraunces(size: 30, color: AppColors.primaryDeep)),
            const SizedBox(height: 24),

            // Account card — linked to the signed-in user.
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      color: AppColors.lavenderSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        (state.email ?? 'U')
                            .substring(0, 1)
                            .toUpperCase(),
                        style: fraunces(
                            size: 24, color: AppColors.primaryDeep),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.email ?? 'Local account',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700, fontSize: 15),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 3),
                        Text(
                          DefaultFirebaseOptions.isConfigured
                              ? 'Signed in'
                              : 'This device only — connect Firebase for cloud accounts',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.inkMuted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            _card(children: [
              _row(
                icon: LucideIcons.history,
                title: 'Assessments taken',
                subtitle: state.history.isEmpty
                    ? 'None yet — take your first from the Assess tab'
                    : '${state.history.length} saved to this account',
              ),
              const Divider(height: 1),
              _row(
                icon: LucideIcons.target,
                title: 'Current focus area',
                subtitle: latest == null
                    ? 'Appears after your first assessment'
                    : '${latest.focusArea} · score ${latest.overall.round()}',
              ),
              const Divider(height: 1),
              _row(
                icon: LucideIcons.heartPulse,
                title: 'Health data',
                subtitle: 'Not connected — coming in Step 5',
              ),
            ]),
            const SizedBox(height: 16),

            _card(children: [
              _row(
                icon: LucideIcons.info,
                title: 'About NeuralCalm',
                subtitle: 'neuralcalm.com',
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(LucideIcons.logOut, color: AppColors.danger),
                title: const Text('Sign out',
                    style: TextStyle(
                        color: AppColors.danger,
                        fontWeight: FontWeight.w600)),
                onTap: () => context.read<AppState>().signOut(),
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _card({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: children),
    );
  }

  Widget _row(
      {required IconData icon,
      required String title,
      required String subtitle}) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryDeep),
      title: Text(title,
          style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle,
          style:
              const TextStyle(fontSize: 12, color: AppColors.inkMuted)),
    );
  }
}
