import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// Shows Apple sign-in on iOS and Google sign-in on Android,
/// automatically. Both work locally today; Step 4 wires Firebase.
class SignInScreen extends StatelessWidget {
  const SignInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<AppState>();
    final isIOS = !kIsWeb && Platform.isIOS;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Container(
                width: 84,
                height: 84,
                decoration: const BoxDecoration(
                  color: AppColors.lavenderSoft,
                  shape: BoxShape.circle,
                ),
                child: const Icon(LucideIcons.brainCircuit,
                    size: 40, color: AppColors.primary),
              ),
              const SizedBox(height: 28),
              Text('NeuralCalm',
                  style: fraunces(size: 36, color: AppColors.primaryDeep)),
              const SizedBox(height: 12),
              const Text(
                'Measure your Neural Calm Score.\nUnderstand it. Improve it.',
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 16, height: 1.5, color: AppColors.inkMuted),
              ),
              const Spacer(flex: 3),
              if (isIOS)
                PrimaryButton(
                  label: 'Continue with Apple',
                  icon: LucideIcons.apple,
                  background: AppColors.ink,
                  onPressed: () => state.signInWithApple(),
                )
              else
                PrimaryButton(
                  label: 'Continue with Google',
                  icon: LucideIcons.chrome,
                  onPressed: () => state.signInWithGoogle(),
                ),
              const SizedBox(height: 14),
              const Text(
                'Sign-in is local for now — real accounts arrive in Step 4.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}
