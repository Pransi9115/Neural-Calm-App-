import 'package:flutter/foundation.dart';
import '../models/assessment_result.dart';
import '../models/chat_message.dart';
import '../services/ai_service.dart';
import '../services/auth_service.dart';
import '../services/backend_service.dart';
import '../services/storage_service.dart';

class AppState extends ChangeNotifier {
  final auth = AuthService();
  final storage = StorageService();
  final _ai = AiService();
  final _backend = BackendService();

  bool isSignedIn = false;
  String? email;
  String? name;
  bool marcusTyping = false;
  AssessmentResult? latestResult;
  final List<AssessmentResult> history = [];
  final List<ChatMessage> messages = [];

  AppState() {
    _restoreSession();
  }

  Future<void> _restoreSession() async {
    if (await auth.restoreSession()) await _afterAuth();
  }

  Future<void> _afterAuth() async {
    isSignedIn = true;
    email = auth.currentEmail;
    name = auth.currentName ?? email?.split('@').first ?? 'You';
    final items = await storage.loadHistory(auth.currentUid);
    history
      ..clear()
      ..addAll(items);
    latestResult = history.isNotEmpty ? history.last : null;
    notifyListeners();
  }

  Future<String?> signUp(String fullName, String emailAddr, String password) async {
    final err = await auth.signUp(fullName.trim(), emailAddr.trim(), password);
    if (err == null) await _afterAuth();
    return err;
  }

  Future<String?> signIn(String emailAddr, String password) async {
    final err = await auth.signIn(emailAddr.trim(), password);
    if (err == null) await _afterAuth();
    return err;
  }

  Future<String?> resetPassword(String emailAddr) =>
      auth.resetPassword(emailAddr.trim());

  Future<void> signOut() async {
    await auth.signOut();
    isSignedIn = false;
    email = null;
    name = null;
    latestResult = null;
    history.clear();
    messages.clear();
    marcusTyping = false;
    notifyListeners();
  }

  /// Saves locally, then syncs to the PHP backend (if configured).
  Future<void> saveResult(
      AssessmentResult result, Map<String, int> answers) async {
    latestResult = result;
    history.add(result);
    notifyListeners();
    await storage.saveHistory(auth.currentUid, history);
    _backend.submitAssessment(
      uid: auth.currentUid,
      name: name ?? '',
      email: email ?? '',
      result: result,
      answers: answers,
    );
  }

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
