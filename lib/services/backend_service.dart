static const String backendUrl = 'http://192.168.31.114/api';   // ← YOUR IP from ipconfig
static const String apiKey = 'NC-test-key-2026-abc123xyz';   // ← EXACTLY as in config.php
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../constants/zones.dart';
import '../models/assessment_result.dart';

/// ─────────────────────────────────────────────────────────────
/// PHP BACKEND SYNC.
/// 1. Upload the `php-backend-api/api/` folder (in this package)
///    to your server, e.g. https://www.neuralcalm.com/api/
/// 2. Create the MySQL table with api/db.sql and set the DB
///    credentials + API key in api/config.php.
/// 3. Set the SAME values below and push.
/// While backendUrl is empty, sync is silently skipped — the app
/// works fully offline-first either way.
/// ─────────────────────────────────────────────────────────────
class BackendService {
  static const String backendUrl = ''; // e.g. 'https://www.neuralcalm.com/api'
  static const String apiKey = 'change-me-neuralcalm-2026';

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
            headers: {
              'content-type': 'application/json',
              'x-api-key': apiKey,
            },
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
      // Offline or server unavailable — the result is already saved
      // on-device; syncing hardening (retry queue) comes later.
    }
  }
}
