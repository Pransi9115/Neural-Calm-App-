import 'dart:convert';
import 'dart:io' show Platform;
import 'package:http/http.dart' as http;
import '../models/assessment_result.dart';

/// ─────────────────────────────────────────────────────────────
/// PHP BACKEND SYNC — currently pointed at your local XAMPP.
/// When going live on GoDaddy, change backendUrl to
/// 'https://yourdomain.com/api' and use the live API key.
/// ─────────────────────────────────────────────────────────────
class BackendService {
  static const String backendUrl = 'http://192.168.31.114/api';
  static const String apiKey = 'NC-test-key-2026-abc123xyz';

  Map<String, String> get _headers => {
        'content-type': 'application/json',
        'x-api-key': apiKey,
      };

  /// Called right after a successful Firebase sign-in or sign-up.
  /// Every login then appears in the admin dashboard.
  Future<void> logLogin({
    required String uid,
    required String name,
    required String email,
    bool isSignup = false,
  }) async {
    if (backendUrl.isEmpty) return;
    try {
      await http
          .post(
            Uri.parse('$backendUrl/log_login.php'),
            headers: _headers,
            body: jsonEncode({
              'uid': uid,
              'name': name,
              'email': email,
              'event_type': isSignup ? 'signup' : 'login',
              'platform': Platform.isIOS
                  ? 'ios'
                  : Platform.isAndroid
                      ? 'android'
                      : 'other',
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Offline — not critical, next login will be recorded.
    }
  }

  /// Called after every chat message (user's AND Marcus's reply) so the
  /// full conversation is visible in the admin dashboard.
  Future<void> saveChat({
    required String uid,
    required String name,
    required String email,
    required String message,
    required bool fromUser,
    required DateTime sentAt,
  }) async {
    if (backendUrl.isEmpty) return;
    try {
      await http
          .post(
            Uri.parse('$backendUrl/save_chat.php'),
            headers: _headers,
            body: jsonEncode({
              'uid': uid,
              'name': name,
              'email': email,
              'message': message,
              'from_user': fromUser,
              'sent_at': sentAt.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 8));
    } catch (_) {
      // Offline — chat still works locally.
    }
  }

  Future<void> submitAssessment({
    required String uid,
    required String name,
    required String email,
    required AssessmentResult result,
    required Map<String, int> answers,
  }) async {
    if (backendUrl.isEmpty) return;
    try {
      await http
          .post(
            Uri.parse('$backendUrl/submit_assessment.php'),
            headers: _headers,
            body: jsonEncode({
              'uid': uid,
              'name': name,
              'email': email,
              'overall': result.overall,
              'zone': result.zone.label,
              'number': result.number,
              'domain_scores': result.domainScores,
              'flags': result.flags.map((f) => f.toJson()).toList(),
              'answers': answers,
              'taken_at': result.takenAt.toIso8601String(),
            }),
          )
          .timeout(const Duration(seconds: 12));
    } catch (_) {
      // Offline or server unavailable — result is already saved on-device.
    }
  }
}
