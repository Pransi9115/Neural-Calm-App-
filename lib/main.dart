import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/main_shell.dart';
import 'screens/sign_in_screen.dart';
import 'theme/app_theme.dart';

void main() => runApp(const NeuralCalmApp());

class NeuralCalmApp extends StatelessWidget {
  const NeuralCalmApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'NeuralCalm',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: Consumer<AppState>(
          builder: (context, state, _) =>
              state.isSignedIn ? const MainShell() : const SignInScreen(),
        ),
      ),
    );
  }
}
