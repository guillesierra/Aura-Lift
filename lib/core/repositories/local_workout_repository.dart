import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/workout_session.dart';
import 'workout_repository.dart';

class LocalWorkoutRepository implements WorkoutRepository {
  static const _sessionsKey = 'workout_sessions_v1';

  @override
  Future<List<WorkoutSession>> loadSessions() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_sessionsKey);
    if (raw == null || raw.isEmpty) {
      return const [];
    }

    final list = jsonDecode(raw) as List<dynamic>;
    return list
        .map((item) => WorkoutSession.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
  }

  @override
  Future<void> saveSessions(List<WorkoutSession> sessions) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = jsonEncode(
      sessions.map((session) => session.toMap()).toList(growable: false),
    );
    await prefs.setString(_sessionsKey, raw);
  }
}
