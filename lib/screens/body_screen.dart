import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

class BodyScreen extends StatelessWidget {
  const BodyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Body')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
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
            const Text(
              'Connect Apple Health or Health Connect to bring HRV, deep sleep and stress events into your Biometric Data domain automatically.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: AppColors.muted, height: 1.55, fontSize: 13),
            ),
            const SizedBox(height: 20),
            PrimaryButton(
              label: 'Connect health data',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content:
                        Text('Health connections arrive in the next step.')));
              },
            ),
          ]),
        ),
      ),
    );
  }
}
