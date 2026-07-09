import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assessment_result.dart';

/// On-device persistence, per account uid:
///  · completed assessment history
///  · in-progress answers (so a half-finished assessment resumes)
class StorageService {
  String _histKey(String uid) => 'nc2_history_$uid';
  String _progKey(String uid) => 'nc2_progress_$uid';

  Future<List<AssessmentResult>> loadHistory(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_histKey(uid));
    if (raw == null) return [];
    try {
      return (jsonDecode(raw) as List)
          .map((e) => AssessmentResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(String uid, List<AssessmentResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _histKey(uid), jsonEncode(history.map((r) => r.toJson()).toList()));
  }

  Future<Map<String, int>> loadProgress(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_progKey(uid));
    if (raw == null) return {};
    try {
      return (jsonDecode(raw) as Map<String, dynamic>)
          .map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return {};
    }
  }

  Future<void> saveProgress(String uid, Map<String, int> answers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_progKey(uid), jsonEncode(answers));
  }

  Future<void> clearProgress(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_progKey(uid));
  }
}
