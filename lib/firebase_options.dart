import 'package:firebase_core/firebase_core.dart';

/// ─────────────────────────────────────────────────────────────
/// STEP 4 — PASTE YOUR FIREBASE VALUES HERE.
///
/// Where to get them (5 minutes, one time):
///  1. console.firebase.google.com → Add project → "NeuralCalm"
///     (Google Analytics can be OFF) → Create.
///  2. Build → Authentication → Get started →
///     Sign-in method → Email/Password → Enable → Save.
///  3. Gear icon → Project settings → General → Your apps →
///     Android → package name:  com.neuralcalm.neuralcalm
///     → Register app → download google-services.json → Continue.
///  4. Open google-services.json in Notepad and copy:
///       projectId            = project_info.project_id
///       messagingSenderId    = project_info.project_number
///       appId                = client[0].client_info.mobilesdk_app_id
///       apiKey               = client[0].api_key[0].current_key
///  5. Paste the 4 values below, save, git push. Done.
///
/// Until these are filled in, the app runs in LOCAL MODE:
/// sign up / sign in work, but only on that one device.
/// ─────────────────────────────────────────────────────────────
class DefaultFirebaseOptions {
  static const String apiKey = 'PASTE_API_KEY';
  static const String appId = 'PASTE_APP_ID';
  static const String messagingSenderId = 'PASTE_SENDER_ID';
  static const String projectId = 'PASTE_PROJECT_ID';

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
