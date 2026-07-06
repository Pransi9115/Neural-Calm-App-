import 'package:flutter/foundation.dart';
import '../models/assessment_result.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final _auth = AuthService();
  final _storage = StorageService();
  final _ai = AiService();

  bool isSignedIn = false;
  String? email;
  bool marcusTyping = false;
  AssessmentResult? latestResult;
  final List<AssessmentResult> history = [];
  final List<ChatMessage> messages = [];

  AppState() {
    _restoreSession();
  }

  /// If the user signed in before, Firebase restores the session
  /// automatically — they land straight on their dashboard.
  Future<void> _restoreSession() async {
    final restored = await _auth.restoreSession();
    if (restored) await _afterAuth();
  }

  Future<void> _afterAuth() async {
    isSignedIn = true;
    email = _auth.currentEmail;
    final items = await _storage.loadHistory(_auth.currentUid);
    history
      ..clear()
      ..addAll(items);
    latestResult = history.isNotEmpty ? history.last : null;
    notifyListeners();
  }

  /// Returns null on success, or an error message for the UI.
  Future<String?> signUp(String emailAddr, String password) async {
    final err = await _auth.signUp(emailAddr.trim(), password);
    if (err == null) await _afterAuth();
    return err;
  }

  /// Returns null on success, or an error message for the UI.
  Future<String?> signIn(String emailAddr, String password) async {
    final err = await _auth.signIn(emailAddr.trim(), password);
    if (err == null) await _afterAuth();
    return err;
  }

  Future<String?> resetPassword(String emailAddr) =>
      _auth.resetPassword(emailAddr.trim());

  Future<void> signOut() async {
    await _auth.signOut();
    isSignedIn = false;
    email = null;
    latestResult = null;
    history.clear();
    messages.clear();
    marcusTyping = false;
    notifyListeners();
  }

  Future<void> saveResult(AssessmentResult result) async {
    latestResult = result;
    history.add(result);
    notifyListeners();
    await _storage.saveHistory(_auth.currentUid, history);
  }

  /// Marcus chat — real AI when an API key is set in
  /// lib/services/ai_service.dart, placeholder otherwise.
  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || marcusTyping) return;
    messages.add(ChatMessage(text: text.trim(), fromUser: true));
    marcusTyping = true;
    notifyListeners();

    final reply = await _ai.reply(List.of(messages), latestResult);

    marcusTyping = false;
    messages.add(ChatMessage(text: reply, fromUser: false));
    notifyListeners();
  }
}
