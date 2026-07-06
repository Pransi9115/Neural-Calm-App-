import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

/// Real accounts via Firebase Auth (email + password).
/// If Firebase isn't configured yet (see lib/firebase_options.dart),
/// it falls back to LOCAL MODE so the app stays fully usable.
class AuthService {
  bool _localSignedIn = false;
  String? _localEmail;

  bool get _useFirebase => DefaultFirebaseOptions.isConfigured;

  bool get isSignedIn => _useFirebase
      ? FirebaseAuth.instance.currentUser != null
      : _localSignedIn;

  String? get currentEmail => _useFirebase
      ? FirebaseAuth.instance.currentUser?.email
      : _localEmail;

  String get currentUid => _useFirebase
      ? (FirebaseAuth.instance.currentUser?.uid ?? 'local')
      : 'local';

  /// Waits for Firebase to restore a previous session on app start.
  Future<bool> restoreSession() async {
    if (!_useFirebase) return false;
    final user = await FirebaseAuth.instance.authStateChanges().first;
    return user != null;
  }

  /// Returns null on success, or a message to show the user.
  Future<String?> signUp(String email, String password) async {
    if (!_useFirebase) {
      _localSignedIn = true;
      _localEmail = email;
      return null;
    }
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not create the account.';
    } catch (_) {
      return 'Could not create the account. Check your connection.';
    }
  }

  /// Returns null on success, or a message to show the user.
  Future<String?> signIn(String email, String password) async {
    if (!_useFirebase) {
      _localSignedIn = true;
      _localEmail = email;
      return null;
    }
    try {
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Sign in failed. Check your email and password.';
    } catch (_) {
      return 'Sign in failed. Check your connection.';
    }
  }

  /// Returns null on success, or a message to show the user.
  Future<String?> resetPassword(String email) async {
    if (!_useFirebase) {
      return 'Password reset needs cloud accounts (Firebase) connected.';
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not send the reset email.';
    }
  }

  Future<void> signOut() async {
    if (_useFirebase) await FirebaseAuth.instance.signOut();
    _localSignedIn = false;
    _localEmail = null;
  }
}
