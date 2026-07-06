import 'package:flutter/foundation.dart';
import '../models/assessment_result.dart';
import '../models/chat_message.dart';
import '../services/auth_service.dart';

/// App-wide state. In-memory for now; Step 4 persists sign-in and
/// score history per user in Firebase.
class AppState extends ChangeNotifier {
  final _auth = AuthService();

  bool isSignedIn = false;
  AssessmentResult? latestResult;
  final List<AssessmentResult> history = [];
  final List<ChatMessage> messages = [];

  Future<void> signInWithGoogle() async {
    if (await _auth.signInWithGoogle()) {
      isSignedIn = true;
      notifyListeners();
    }
  }

  Future<void> signInWithApple() async {
    if (await _auth.signInWithApple()) {
      isSignedIn = true;
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
    isSignedIn = false;
    notifyListeners();
  }

  void saveResult(AssessmentResult result) {
    latestResult = result;
    history.add(result);
    notifyListeners();
  }

  /// Marcus chat. The reply is a placeholder until the AI backend
  /// lands in Step 6 — but it ALREADY receives the latest score, so
  /// you can see how context will flow into the real conversation.
  void sendMessage(String text) {
    if (text.trim().isEmpty) return;
    messages.add(ChatMessage(text: text.trim(), fromUser: true));
    messages.add(ChatMessage(text: _marcusPlaceholder(), fromUser: false));
    notifyListeners();
  }

  String _marcusPlaceholder() {
    final r = latestResult;
    final context = r == null
        ? "Once you take your first assessment I'll tailor everything to your Neural Calm Score."
        : "I can see your latest Neural Calm Score is ${r.overall.round()}, with ${r.focusArea.toLowerCase()} as your focus area — that's where we'll start.";
    return "Thanks for sharing. $context (I'm a placeholder reply for now — my real AI arrives in Step 6.)";
  }
}
