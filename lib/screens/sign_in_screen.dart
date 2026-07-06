import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../firebase_options.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';

/// Sign In + Sign Up (email & password), with forgot-password.
/// Uses real Firebase accounts once lib/firebase_options.dart is
/// filled in; until then it runs in local mode on the device.
class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _signUpMode = false;
  bool _loading = false;
  bool _obscure = true;
  String? _error;

  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (!email.contains('@') || !email.contains('.')) {
      setState(() => _error = 'Please enter a valid email address.');
      return;
    }
    if (pass.length < 6) {
      setState(() => _error = 'Password must be at least 6 characters.');
      return;
    }
    if (_signUpMode && pass != _confirmCtrl.text) {
      setState(() => _error = 'Passwords do not match.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final state = context.read<AppState>();
    final err = _signUpMode
        ? await state.signUp(email, pass)
        : await state.signIn(email, pass);
    if (!mounted) return;
    setState(() {
      _loading = false;
      _error = err;
    });
  }

  Future<void> _forgotPassword() async {
    final ctrl = TextEditingController(text: _emailCtrl.text.trim());
    final email = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Reset password', style: fraunces(size: 20)),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Your account email'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
              child: const Text('Send reset link')),
        ],
      ),
    );
    if (email == null || email.isEmpty || !mounted) return;
    final err = await context.read<AppState>().resetPassword(email);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content:
            Text(err ?? 'Password reset email sent — check your inbox.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/logo/neuralcalm_logo.png',
                  height: 64,
                  errorBuilder: (_, __, ___) => Text('NeuralCalm',
                      style:
                          fraunces(size: 34, color: AppColors.primaryDeep)),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Measure your Neural Calm Score.\nUnderstand it. Improve it.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      fontSize: 15, height: 1.5, color: AppColors.inkMuted),
                ),
                const SizedBox(height: 32),
                _field(_emailCtrl, 'Email', LucideIcons.mail,
                    keyboard: TextInputType.emailAddress),
                const SizedBox(height: 12),
                _field(_passCtrl, 'Password', LucideIcons.lock,
                    obscure: true),
                if (_signUpMode) ...[
                  const SizedBox(height: 12),
                  _field(_confirmCtrl, 'Confirm password', LucideIcons.lock,
                      obscure: true),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 14),
                  Text(_error!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          color: AppColors.danger, fontSize: 13)),
                ],
                const SizedBox(height: 20),
                _loading
                    ? const CircularProgressIndicator(
                        color: AppColors.primary)
                    : PrimaryButton(
                        label:
                            _signUpMode ? 'Create account' : 'Sign in',
                        icon: _signUpMode
                            ? LucideIcons.userPlus
                            : LucideIcons.logIn,
                        onPressed: _submit,
                      ),
                const SizedBox(height: 10),
                TextButton(
                  onPressed: _loading
                      ? null
                      : () => setState(() {
                            _signUpMode = !_signUpMode;
                            _error = null;
                          }),
                  child: Text(
                    _signUpMode
                        ? 'Already have an account?  Sign in'
                        : 'New to NeuralCalm?  Create an account',
                    style: const TextStyle(
                        color: AppColors.primaryDeep,
                        fontWeight: FontWeight.w600),
                  ),
                ),
                if (!_signUpMode)
                  TextButton(
                    onPressed: _loading ? null : _forgotPassword,
                    child: const Text('Forgot password?',
                        style: TextStyle(
                            color: AppColors.inkMuted, fontSize: 13)),
                  ),
                if (!DefaultFirebaseOptions.isConfigured) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.lavenderSoft,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Text(
                      'Local mode: cloud accounts not connected yet. '
                      'Fill in lib/firebase_options.dart to enable real accounts.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 12, color: AppColors.primaryDeep),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController ctrl, String hint, IconData icon,
      {bool obscure = false, TextInputType? keyboard}) {
    return TextField(
      controller: ctrl,
      obscureText: obscure && _obscure,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20, color: AppColors.inkMuted),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 20, color: AppColors.inkMuted),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: AppColors.surface,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primary),
        ),
      ),
    );
  }
}
