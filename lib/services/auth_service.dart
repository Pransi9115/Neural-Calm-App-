import 'package:firebase_auth/firebase_auth.dart';
import '../firebase_options.dart';

/// Firebase Auth (email + password) with the user's full name
/// stored as displayName — it appears on the professional report.
/// Falls back to local mode if Firebase isn't configured.
class AuthService {
  bool _localSignedIn = false;
  String? _localEmail;
  String? _localName;

  bool get _useFirebase => DefaultFirebaseOptions.isConfigured;

  bool get isSignedIn =>
      _useFirebase ? FirebaseAuth.instance.currentUser != null : _localSignedIn;

  String? get currentEmail =>
      _useFirebase ? FirebaseAuth.instance.currentUser?.email : _localEmail;

  String? get currentName => _useFirebase
      ? FirebaseAuth.instance.currentUser?.displayName
      : _localName;

  String get currentUid => _useFirebase
      ? (FirebaseAuth.instance.currentUser?.uid ?? 'local')
      : 'local';

  Future<bool> restoreSession() async {
    if (!_useFirebase) return false;
    final user = await FirebaseAuth.instance.authStateChanges().first;
    return user != null;
  }

  Future<String?> signUp(String name, String email, String password) async {
    if (!_useFirebase) {
      _localSignedIn = true;
      _localEmail = email;
      _localName = name;
      return null;
    }
    try {
      final cred = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      await cred.user?.updateDisplayName(name);
      return null;
    } on FirebaseAuthException catch (e) {
      return e.message ?? 'Could not create the account.';
    } catch (_) {
      return 'Could not create the account. Check your connection.';
    }
  }

  Future<String?> signIn(String email, String password) async {
    if (!_useFirebase) {
      _localSignedIn = true;
      _localEmail = email;
      _localName ??= email.split('@').first;
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
    _localName = null;
  }
}
