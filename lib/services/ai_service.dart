import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/assessment_result.dart';
import '../models/chat_message.dart';

/// ─────────────────────────────────────────────────────────────
/// STEP 6 — Marcus's real AI.
///
/// 1. Get an API key at console.anthropic.com → API keys.
/// 2. Paste it into `apiKey` below. Save, git push. That's it —
///    Marcus becomes a real AI companion, aware of the user's
///    latest Neural Calm Score and category breakdown.
///
/// SECURITY NOTE: a key inside an app can be extracted from the
/// APK. That's fine for private/team testing, but BEFORE a public
/// store release this call must move behind a small server so the
/// key never ships in the app. We'll do that at store prep.
/// ─────────────────────────────────────────────────────────────
class AiService {
  static const String apiKey = '';

  static const String _model = 'claude-sonnet-4-6';
  static const String _url = 'https://api.anthropic.com/v1/messages';

  Future<String> reply(
      List<ChatMessage> conversation, AssessmentResult? latest) async {
    if (apiKey.isEmpty) return _placeholder(latest);

    final scoreContext = latest == null
        ? 'The user has not taken an assessment yet — gently encourage them to take their first one from the Assess tab.'
        : 'Latest Neural Calm Score: ${latest.overall.round()}/100. '
            'Category breakdown (higher = calmer): '
            '${latest.categories.entries.map((e) => '${e.key} ${e.value.round()}').join(', ')}. '
            'Current focus area: ${latest.focusArea}.';

    final system =
        'You are Marcus, the warm, encouraging wellbeing companion inside the '
        'NeuralCalm app. Keep replies short (2-5 sentences), practical and kind. '
        'Base advice on the user\'s data when relevant. $scoreContext '
        'You are a wellbeing tool, not a doctor: never diagnose, and suggest '
        'professional help for anything medical or a crisis.';

    // Send the last 12 turns to keep requests small.
    final recent = conversation.length > 12
        ? conversation.sublist(conversation.length - 12)
        : conversation;
    final messages = recent
        .map((m) => {
              'role': m.fromUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    try {
      final res = await http
          .post(
            Uri.parse(_url),
            headers: {
              'content-type': 'application/json',
              'x-api-key': apiKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': _model,
              'max_tokens': 400,
              'system': system,
              'messages': messages,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final content = (data['content'] as List)
            .where((b) => b['type'] == 'text')
            .map((b) => b['text'] as String)
            .join();
        return content.trim().isEmpty
            ? 'Hmm, I came back empty — try asking me that again?'
            : content.trim();
      }
      if (res.statusCode == 401) {
        return 'My API key looks invalid — please check the key in '
            'lib/services/ai_service.dart.';
      }
      return 'I could not reach my brain just now (error ${res.statusCode}). '
          'Please try again in a moment.';
    } catch (_) {
      return 'I could not connect — check the internet connection and try again.';
    }
  }

  String _placeholder(AssessmentResult? latest) {
    final context = latest == null
        ? "Once you take your first assessment I'll tailor everything to your Neural Calm Score."
        : "I can see your latest Neural Calm Score is ${latest.overall.round()}, with ${latest.focusArea.toLowerCase()} as your focus area.";
    return 'Thanks for sharing. $context (My real AI is one step away — '
        'paste an Anthropic API key into lib/services/ai_service.dart '
        'and I come to life.)';
  }
}
