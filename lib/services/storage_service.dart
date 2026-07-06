import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/assessment_result.dart';

/// Persists each user's score history on the device, keyed by their
/// account uid — so history survives app restarts and each account
/// keeps its own history on a shared phone.
class StorageService {
  String _key(String uid) => 'nc_history_$uid';

  Future<List<AssessmentResult>> loadHistory(String uid) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key(uid));
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => AssessmentResult.fromJson(e as Map<String, dynamic>))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> saveHistory(String uid, List<AssessmentResult> history) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _key(uid), jsonEncode(history.map((r) => r.toJson()).toList()));
  }
}
