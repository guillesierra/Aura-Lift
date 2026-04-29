import 'exercise_set.dart';
import 'workout_session.dart';

class ExerciseHistorySnapshot {
  const ExerciseHistorySnapshot({
    required this.sessionId,
    required this.sessionDate,
    required this.exerciseName,
    required this.sets,
  });

  final String sessionId;
  final DateTime sessionDate;
  final String exerciseName;
  final List<ExerciseSet> sets;

  bool get hasData => sets.isNotEmpty;

  String get summary => summaryFor('es');

  String summaryFor(String languageCode) {
    if (sets.isEmpty) {
      return languageCode == 'en'
          ? 'No previous records'
          : 'Sin registros previos';
    }

    final pieces = <String>[];
    for (var i = 0; i < sets.length; i += 1) {
      final set = sets[i];
      final weight = set.weightKg % 1 == 0
          ? set.weightKg.toStringAsFixed(0)
          : set.weightKg.toStringAsFixed(1);
      final setLabel = languageCode == 'en' ? 'Set ${i + 1}' : 'S${i + 1}';
      pieces.add('$setLabel: ${set.reps} x $weight kg');
    }
    return pieces.join('  ·  ');
  }

  static ExerciseHistorySnapshot? fromSessions({
    required List<WorkoutSession> sessions,
    required String exerciseId,
    String? excludingSessionId,
  }) {
    for (final session in sessions.reversed) {
      if (session.id == excludingSessionId || session.isActive) {
        continue;
      }
      for (final exercise in session.exercises) {
        if (exercise.exerciseId == exerciseId) {
          return ExerciseHistorySnapshot(
            sessionId: session.id,
            sessionDate: session.startedAt,
            exerciseName: exercise.exerciseName,
            sets: exercise.sets,
          );
        }
      }
    }
    return null;
  }
}
