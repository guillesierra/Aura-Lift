import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/metrics/aura_points_estimator.dart';
import 'package:aura_lift/core/models/exercise_set.dart';
import 'package:aura_lift/core/models/heart_rate_sample.dart';
import 'package:aura_lift/core/models/session_exercise.dart';
import 'package:aura_lift/core/models/workout_session.dart';

void main() {
  test('awards equivalent points for equivalent relative load', () {
    final session = _sessionWithOneSet(weightKg: 50, reps: 8);

    final pointsFor50kgBodyWeight = AuraPointsEstimator.estimateWorkoutPoints(
      session: session,
      bodyWeightKg: 50,
    );
    final pointsFor100kgBodyWeight = AuraPointsEstimator.estimateWorkoutPoints(
      session: session.copyWith(
        exercises: [
          _sessionExercise(weightKg: 100, reps: 8),
        ],
      ),
      bodyWeightKg: 100,
    );

    expect(pointsFor50kgBodyWeight, pointsFor100kgBodyWeight);
  });

  test('awards more points for longer and denser training', () {
    final shortSession = _sessionWithOneSet(weightKg: 50, reps: 8);
    final longSession = WorkoutSession(
      id: 'long',
      title: 'Long',
      startedAt: DateTime.utc(2026, 1, 1, 10, 0),
      endedAt: DateTime.utc(2026, 1, 1, 11, 0),
      selectedExerciseId: 'bench',
      exercises: [
        _sessionExercise(weightKg: 70, reps: 10),
        _sessionExercise(
          id: 'row',
          exerciseId: 'row',
          name: 'Row',
          weightKg: 65,
          reps: 10,
        ),
      ],
      heartRateSamples: const <HeartRateSample>[],
    );

    final shortPoints = AuraPointsEstimator.estimateWorkoutPoints(
      session: shortSession,
      bodyWeightKg: 70,
    );
    final longPoints = AuraPointsEstimator.estimateWorkoutPoints(
      session: longSession,
      bodyWeightKg: 70,
    );

    expect(longPoints, greaterThan(shortPoints));
  });

  test('rewards higher relative intensity in competitive mode', () {
    final highIntensity = WorkoutSession(
      id: 'high-intensity',
      title: 'High intensity',
      startedAt: DateTime.utc(2026, 1, 1, 10, 0),
      endedAt: DateTime.utc(2026, 1, 1, 10, 30),
      selectedExerciseId: 'bench',
      exercises: [
        _sessionExercise(weightKg: 100, reps: 5),
      ],
      heartRateSamples: const <HeartRateSample>[],
    );

    final lowIntensity = WorkoutSession(
      id: 'low-intensity',
      title: 'Low intensity',
      startedAt: DateTime.utc(2026, 1, 1, 10, 0),
      endedAt: DateTime.utc(2026, 1, 1, 10, 30),
      selectedExerciseId: 'bench',
      exercises: [
        _sessionExercise(weightKg: 50, reps: 10),
      ],
      heartRateSamples: const <HeartRateSample>[],
    );

    final highPoints = AuraPointsEstimator.estimateWorkoutPoints(
      session: highIntensity,
      bodyWeightKg: 100,
    );
    final lowPoints = AuraPointsEstimator.estimateWorkoutPoints(
      session: lowIntensity,
      bodyWeightKg: 100,
    );

    expect(highPoints, greaterThan(lowPoints));
  });
}

WorkoutSession _sessionWithOneSet({
  required double weightKg,
  required int reps,
}) {
  return WorkoutSession(
    id: 'session',
    title: 'Session',
    startedAt: DateTime.utc(2026, 1, 1, 10, 0),
    endedAt: DateTime.utc(2026, 1, 1, 10, 30),
    selectedExerciseId: 'bench',
    exercises: [
      _sessionExercise(weightKg: weightKg, reps: reps),
    ],
    heartRateSamples: const <HeartRateSample>[],
  );
}

SessionExercise _sessionExercise({
  String id = 'bench',
  String exerciseId = 'bench',
  String name = 'Bench press',
  required double weightKg,
  required int reps,
}) {
  return SessionExercise(
    id: id,
    exerciseId: exerciseId,
    exerciseName: name,
    muscleGroup: 'Pecho',
    orderIndex: 0,
    startedAt: DateTime.utc(2026, 1, 1, 10, 0),
    sets: [
      ExerciseSet(
        id: 'set-1',
        reps: reps,
        weightKg: weightKg,
        completedAt: DateTime.utc(2026, 1, 1, 10, 5),
      ),
    ],
  );
}
