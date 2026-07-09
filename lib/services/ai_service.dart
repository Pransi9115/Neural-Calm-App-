import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/zones.dart';
import '../models/assessment_result.dart';
import '../models/chat_message.dart';

/// ─────────────────────────────────────────────────────────────
/// Marcus's AI — supports TWO providers. Fill in ONE key:
///
/// Keys are NEVER stored in this code (GitHub blocks that, rightly).
/// They live in Codemagic → your app → Settings → Environment
/// variables, in a group called `keys`:
///   GEMINI_API_KEY    → free trial via aistudio.google.com
///   ANTHROPIC_API_KEY → production via console.anthropic.com
/// codemagic.yaml injects them at build time with --dart-define.
/// If both are set, Anthropic is used. If neither, Marcus uses
/// friendly placeholder replies.
///
/// SECURITY: even injected keys ship inside the APK and can be
/// extracted. Fine for private/team testing; before a PUBLIC
/// store release this moves behind a small server.
/// ─────────────────────────────────────────────────────────────
class AiService {
  static const String geminiKey = String.fromEnvironment('GEMINI_API_KEY');
  static const String anthropicKey = String.fromEnvironment('ANTHROPIC_API_KEY');

  static const String _geminiModel = 'gemini-2.5-flash';
  static const String _anthropicModel = 'claude-sonnet-4-6';

  Future<String> reply(
      List<ChatMessage> conversation, AssessmentResult? latest) async {
    if (anthropicKey.isNotEmpty) return _anthropic(conversation, latest);
    // Gemini keys may start with "AIza" (old) or "AQ." (new format since
    // mid-2026) — both work on the native endpoint used below, so we never
    // judge the key's shape here; Google's API is the judge.
    if (geminiKey.isNotEmpty) return _gemini(conversation, latest);
    return _placeholder(latest);
  }

  String _systemPrompt(AssessmentResult? latest) {
    final scoreContext = latest == null
        ? 'The user has not taken an assessment yet — gently encourage them to take their first one from the Assess tab.'
        : 'Latest Neural Calm Score: ${latest.overall}/100 — LOWER is calmer. '
            'Zone: ${latest.zone.label} (Optimal 0-35, Moderate 36-60, Elevated 61-100). '
            'Domain scores (0-100, lower = calmer): '
            '${latest.domainScores.entries.map((e) => '${e.key} ${e.value}').join(', ')}.';
    return 'You are Marcus, the warm, encouraging wellbeing companion inside the '
        'NeuralCalm app. Keep replies short (2-5 sentences), practical and kind. '
        'Base advice on the user\'s data when relevant, and remember the scale: '
        'a LOWER Neural Calm Score is better. $scoreContext '
        'You are a wellbeing tool, not a doctor: never diagnose, and suggest '
        'professional help for anything medical or a crisis.';
  }

  List<ChatMessage> _recent(List<ChatMessage> conversation) =>
      conversation.length > 12
          ? conversation.sublist(conversation.length - 12)
          : conversation;

  // ───────────────────────── Gemini (free tier) ─────────────────────────
  Future<String> _gemini(
      List<ChatMessage> conversation, AssessmentResult? latest) async {
    final url =
        'https://generativelanguage.googleapis.com/v1beta/models/$_geminiModel:generateContent?key=$geminiKey';
    final contents = _recent(conversation)
        .map((m) => {
              'role': m.fromUser ? 'user' : 'model',
              'parts': [
                {'text': m.text}
              ],
            })
        .toList();

    try {
      final res = await http
          .post(
            Uri.parse(url),
            headers: {'content-type': 'application/json'},
            body: jsonEncode({
              'systemInstruction': {
                'parts': [
                  {'text': _systemPrompt(latest)}
                ]
              },
              'contents': contents,
              'generationConfig': {'maxOutputTokens': 500},
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final candidates = data['candidates'] as List?;
        if (candidates == null || candidates.isEmpty) {
          return 'Hmm, I came back empty — try asking me that again?';
        }
        final parts =
            (candidates[0]['content']?['parts'] as List?) ?? const [];
        final text = parts
            .map((p) => (p['text'] ?? '') as String)
            .join()
            .trim();
        return text.isEmpty
            ? 'Hmm, I came back empty — try asking me that again?'
            : text;
      }
      if (res.statusCode == 429) {
        return "I'm a little busy right now (free-tier limit). "
            'Give me a minute and ask again.';
      }
      if (res.statusCode == 400 || res.statusCode == 403) {
        return 'My Gemini key was rejected (error ${res.statusCode}). Please create '
            'a fresh key at aistudio.google.com and update GEMINI_API_KEY in '
            'Codemagic -> Environment variables (group "keys"), then rebuild.';
      }
      return 'I could not reach my brain just now (error ${res.statusCode}). '
          'Please try again in a moment.';
    } catch (_) {
      return 'I could not connect — check the internet connection and try again.';
    }
  }

  // ─────────────────────── Anthropic (production) ───────────────────────
  Future<String> _anthropic(
      List<ChatMessage> conversation, AssessmentResult? latest) async {
    final messages = _recent(conversation)
        .map((m) => {
              'role': m.fromUser ? 'user' : 'assistant',
              'content': m.text,
            })
        .toList();

    try {
      final res = await http
          .post(
            Uri.parse('https://api.anthropic.com/v1/messages'),
            headers: {
              'content-type': 'application/json',
              'x-api-key': anthropicKey,
              'anthropic-version': '2023-06-01',
            },
            body: jsonEncode({
              'model': _anthropicModel,
              'max_tokens': 400,
              'system': _systemPrompt(latest),
              'messages': messages,
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final content = (data['content'] as List)
            .where((b) => b['type'] == 'text')
            .map((b) => b['text'] as String)
            .join()
            .trim();
        return content.isEmpty
            ? 'Hmm, I came back empty — try asking me that again?'
            : content;
      }
      if (res.statusCode == 401) {
        return 'My Anthropic key was rejected. Please check ANTHROPIC_API_KEY in '
            'Codemagic -> Environment variables (group "keys"), then rebuild.';
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
        : "I can see your latest Neural Calm Score is ${latest.overall} — ${latest.zone.label} zone.";
    return 'Thanks for sharing. $context (Setup check: NO AI key was included '
        'in this build. In Codemagic open your app -> Environment variables, '
        'add GEMINI_API_KEY with your key from aistudio.google.com, '
        'put it in a group named exactly "keys", tick Secure, save — then '
        'run a NEW build.)';
  }
}
