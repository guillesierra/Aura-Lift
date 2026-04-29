import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/insights/training_risk_advisor.dart';
import 'package:aura_lift/core/models/exercise_set.dart';
import 'package:aura_lift/core/models/session_exercise.dart';
import 'package:aura_lift/core/models/workout_session.dart';

void main() {
  test('flags high muscle concentration when one group dominates volume', () {
    final sessions = [
      _session(
        id: 's1',
        daysAgo: 2,
        exercises: [
          _exercise('e1', 'Press de banca con barra', 'Pecho', 8),
          _exercise('e2', 'Press inclinado con mancuernas', 'Pecho', 8),
          _exercise('e3', 'Aperturas en polea', 'Pecho', 8),
          _exercise('e4', 'Sentadilla trasera', 'Piernas', 2),
        ],
      ),
    ];

    final recommendations = TrainingRiskAdvisor.build(
      sessions: sessions,
      languageCode: 'es',
      now: DateTime.utc(2026, 4, 28),
    );

    expect(
      recommendations.any((item) =>
          item.severity == RecommendationSeverity.high &&
          item.message.toLowerCase().contains('demasiada carga en pecho')),
      isTrue,
    );
  });

  test('flags lumbar overuse risk with repeated lumbar-heavy exercises', () {
    final sessions = [
      _session(
        id: 's1',
        daysAgo: 1,
        exercises: [
          _exercise('e1', 'Peso muerto convencional', 'Espalda', 8),
          _exercise('e2', 'Remo con barra', 'Espalda', 8),
          _exercise('e3', 'Buenos dias con barra', 'Piernas', 8),
        ],
      ),
    ];

    final recommendations = TrainingRiskAdvisor.build(
      sessions: sessions,
      languageCode: 'es',
      now: DateTime.utc(2026, 4, 28),
    );

    expect(
      recommendations.any((item) =>
          item.severity == RecommendationSeverity.high &&
          item.message.toLowerCase().contains('zona lumbar')),
      isTrue,
    );
  });

  test('returns low-severity positive message when load is balanced', () {
    final sessions = [
      _session(
        id: 's1',
        daysAgo: 3,
        exercises: [
          _exercise('e1', 'Press de banca con barra', 'Pecho', 4),
          _exercise('e2', 'Remo con mancuerna', 'Espalda', 4),
          _exercise('e3', 'Sentadilla trasera', 'Piernas', 4),
        ],
      ),
      _session(
        id: 's2',
        daysAgo: 1,
        exercises: [
          _exercise('e4', 'Press militar con barra', 'Hombros', 4),
          _exercise('e5', 'Curl con barra', 'Biceps', 4),
          _exercise('e6', 'Extension de triceps en polea', 'Triceps', 4),
        ],
      ),
    ];

    final recommendations = TrainingRiskAdvisor.build(
      sessions: sessions,
      languageCode: 'es',
      now: DateTime.utc(2026, 4, 28),
    );

    expect(
      recommendations.first.severity,
      RecommendationSeverity.low,
    );
  });
}

WorkoutSession _session({
  required String id,
  required int daysAgo,
  required List<SessionExercise> exercises,
}) {
  final now = DateTime.utc(2026, 4, 28, 12);
  final start = now.subtract(Duration(days: daysAgo));
  return WorkoutSession(
    id: id,
    title: id,
    startedAt: start,
    endedAt: start.add(const Duration(minutes: 60)),
    selectedExerciseId: exercises.first.exerciseId,
    exercises: exercises,
    heartRateSamples: const [],
  );
}

SessionExercise _exercise(
  String id,
  String name,
  String group,
  int setCount,
) {
  final startedAt = DateTime.utc(2026, 4, 20, 12);
  return SessionExercise(
    id: 'session-$id',
    exerciseId: id,
    exerciseName: name,
    muscleGroup: group,
    orderIndex: 0,
    startedAt: startedAt,
    sets: List.generate(
      setCount,
      (index) => ExerciseSet(
        id: '$id-set-$index',
        reps: 8,
        weightKg: 40,
        completedAt: startedAt.add(Duration(minutes: index * 3)),
      ),
    ),
  );
}
