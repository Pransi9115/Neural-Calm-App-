import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../firebase_options.dart';
import '../providers/app_state.dart';
import '../theme/app_colors.dart';
import '../theme/app_theme.dart';
import '../widgets/primary_button.dart';
import '../widgets/wordmark.dart';

/// Sign In / Sign Up — navy hero band with the brand wordmark,
/// form panel on the lavender page below.
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

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    final pass = _passCtrl.text;

    if (_signUpMode && name.isEmpty) {
      setState(() => _error = 'Please enter your full name.');
      return;
    }
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
        ? await state.signUp(name, email, pass)
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: Text('Reset password', style: cormorant(size: 22)),
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
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Navy hero — the wordmark shows exactly as the brand:
        // white "Neural", purple "Calm".
        Container(
          width: double.infinity,
          color: AppColors.navy,
          padding: EdgeInsets.fromLTRB(
              24, MediaQuery.of(context).padding.top + 40, 24, 28),
          child: Column(children: [
            const Center(child: Wordmark(fontSize: 26)),
            const SizedBox(height: 12),
            Text(
              _signUpMode
                  ? 'Create your account'
                  : 'Clinical-grade wellbeing measurement.\nYour Neural Calm Score, tracked over time.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  color: AppColors.onNavy, fontSize: 13, height: 1.55),
            ),
          ]),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 28),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          _signUpMode
                              ? 'YOUR DETAILS'
                              : 'SIGN IN TO YOUR ACCOUNT',
                          style: secLabel()),
                      const SizedBox(height: 12),
                      if (_signUpMode) ...[
                        _field(_nameCtrl, 'Full name', LucideIcons.user),
                        const SizedBox(height: 10),
                      ],
                      _field(_emailCtrl, 'Email', LucideIcons.mail,
                          keyboard: TextInputType.emailAddress),
                      const SizedBox(height: 10),
                      _field(_passCtrl, 'Password', LucideIcons.lock,
                          obscure: true),
                      if (_signUpMode) ...[
                        const SizedBox(height: 10),
                        _field(_confirmCtrl, 'Confirm password',
                            LucideIcons.lock,
                            obscure: true),
                      ],
                      if (_error != null) ...[
                        const SizedBox(height: 12),
                        Text(_error!,
                            style: const TextStyle(
                                color: AppColors.red, fontSize: 12.5)),
                      ],
                      const SizedBox(height: 14),
                      _loading
                          ? const Center(
                              child: CircularProgressIndicator(
                                  color: AppColors.purple))
                          : PrimaryButton(
                              label: _signUpMode
                                  ? 'Create account'
                                  : 'Sign in',
                              onPressed: _submit,
                            ),
                      if (!_signUpMode)
                        Center(
                          child: TextButton(
                            onPressed: _loading ? null : _forgotPassword,
                            child: const Text('Forgot password?',
                                style: TextStyle(
                                    color: AppColors.purpleDeep,
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                    ]),
              ),
              const SizedBox(height: 6),
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
                      color: AppColors.purpleDeep,
                      fontWeight: FontWeight.w600,
                      fontSize: 13),
                ),
              ),
              if (!DefaultFirebaseOptions.isConfigured)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.purplePale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Local mode: cloud accounts not connected yet. Fill in lib/firebase_options.dart to enable real accounts.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 11.5, color: AppColors.purpleDeep),
                  ),
                ),
            ]),
          ),
        ),
      ]),
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
        hintStyle: const TextStyle(color: AppColors.muted, fontSize: 13.5),
        prefixIcon: Icon(icon, size: 19, color: AppColors.muted),
        suffixIcon: obscure
            ? IconButton(
                icon: Icon(_obscure ? LucideIcons.eye : LucideIcons.eyeOff,
                    size: 19, color: AppColors.muted),
                onPressed: () => setState(() => _obscure = !_obscure),
              )
            : null,
        filled: true,
        fillColor: AppColors.background,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.purple),
        ),
      ),
    );
  }
}
