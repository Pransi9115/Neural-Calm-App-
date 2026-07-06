import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'providers/app_state.dart';
import 'screens/main_shell.dart';
import 'screens/sign_in_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (DefaultFirebaseOptions.isConfigured) {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.current);
    } catch (_) {
      // App still runs in local mode if Firebase init fails.
    }
  }
  runApp(const NeuralCalmApp());
}

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
