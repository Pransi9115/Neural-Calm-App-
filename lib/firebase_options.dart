import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;
import 'package:firebase_core/firebase_core.dart';

/// Firebase connection for the "Neural Calm App" project.
/// Project ID: neural-calm-app   Project number: 973335521953
///
/// ONE THING LEFT TO DO:
///   Replace PASTE_IOS_API_KEY_HERE below with the API_KEY value
///   from GoogleService-Info.plist (open it in Notepad, it starts AIza...).
class DefaultFirebaseOptions {
  // ─────────── ANDROID (live, working) ───────────
  static const String androidApiKey =
      'AIzaSyBZgL65Mb1cZ7BctTqbXmwzuKBP0Rsg0cE';
  static const String androidAppId =
      '1:973335521953:android:54b653ca3094ccdda49ee0';

  // ─────────── iOS ───────────
  static const String iosApiKey = 'AIzaSyCpfuj8jFd8pjEpEL1uG6nWKkOHnOzszoc';
  static const String iosAppId =
      '1:973335521953:ios:e0124bc932876c7ea49ee0';
  static const String iosBundleId = 'com.neuralcalm.neuralcalm';

  // ─────────── shared ───────────
  static const String messagingSenderId = '973335521953';
  static const String projectId = 'neural-calm-app';

  /// True only when the CURRENT platform has real credentials.
  /// If the iOS key is still a placeholder the app falls back to
  /// local-only mode instead of crashing.
  static bool get isConfigured {
    final o = current;
    return !o.apiKey.startsWith('PASTE') &&
        !o.appId.startsWith('PASTE') &&
        !messagingSenderId.startsWith('PASTE') &&
        !projectId.startsWith('PASTE');
  }

  static FirebaseOptions get current {
    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const FirebaseOptions(
          apiKey: iosApiKey,
          appId: iosAppId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
          iosBundleId: iosBundleId,
        );
      default:
        return const FirebaseOptions(
          apiKey: androidApiKey,
          appId: androidAppId,
          messagingSenderId: messagingSenderId,
          projectId: projectId,
        );
    }
  }
}
