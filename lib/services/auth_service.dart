/// ─────────────────────────────────────────────────────────────
/// STEP 4 SEAM — real sign-in.
///
/// Today: both methods succeed locally so the app is fully
/// testable. In Step 4 this file is replaced with firebase_auth
/// + google_sign_in + sign_in_with_apple (packages are already
/// listed, commented, in pubspec.yaml) — the sign-in screen
/// won't need to change.
/// ─────────────────────────────────────────────────────────────
class AuthService {
  Future<bool> signInWithGoogle() async => true;

  Future<bool> signInWithApple() async => true;

  Future<void> signOut() async {}
}
