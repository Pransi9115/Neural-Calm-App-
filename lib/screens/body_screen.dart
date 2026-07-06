import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// The Body tab. Honest empty state until Step 5 wires the `health`
/// package (Apple HealthKit + Google Health Connect via one API).
class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Body',
                  style: fraunces(size: 30, color: AppColors.primaryDeep)),
              const Spacer(),
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 96,
                      height: 96,
                      decoration: const BoxDecoration(
                        color: AppColors.lavenderSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(LucideIcons.heartPulse,
                          size: 44, color: AppColors.primary),
                    ),
                    const SizedBox(height: 22),
                    Text('No health data yet', style: fraunces(size: 22)),
                    const SizedBox(height: 10),
                    const Text(
                      'Connect Apple Health or Health Connect to bring sleep, heart rate, and activity into your Neural Calm Score automatically.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.inkMuted, height: 1.5),
                    ),
                    const SizedBox(height: 24),
                    PrimaryButton(
                      label: 'Connect health data',
                      icon: LucideIcons.plugZap,
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Health connections arrive in Step 5.')),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const Spacer(flex: 2),
            ],
          ),
        ),
      ),
    );
  }
}
