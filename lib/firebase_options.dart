import 'package:firebase_core/firebase_core.dart';

/// Firebase connection for the "Neural Calm App" project — LIVE.
class DefaultFirebaseOptions {
  static const String apiKey = 'AIzaSyBZgL65Mb1cZ7BctTqbXmwzuKBP0Rsg0cE';
  static const String appId = '1:973335521953:android:54b653ca3094ccdda49ee0';
  static const String messagingSenderId = '973335521953';
  static const String projectId = 'neural-calm-app';

  static bool get isConfigured =>
      !apiKey.startsWith('PASTE') &&
      !appId.startsWith('PASTE') &&
      !messagingSenderId.startsWith('PASTE') &&
      !projectId.startsWith('PASTE');

  static FirebaseOptions get current => const FirebaseOptions(
        apiKey: apiKey,
        appId: appId,
        messagingSenderId: messagingSenderId,
        projectId: projectId,
      );
}
