import '../models/workout_session.dart';

abstract class WorkoutRepository {
  Future<List<WorkoutSession>> loadSessions();
  Future<void> saveSessions(List<WorkoutSession> sessions);
}
