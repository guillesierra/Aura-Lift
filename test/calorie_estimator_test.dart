import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/metrics/calorie_estimator.dart';
import 'package:aura_lift/core/models/exercise_set.dart';
import 'package:aura_lift/core/models/heart_rate_sample.dart';
import 'package:aura_lift/core/models/session_exercise.dart';
import 'package:aura_lift/core/models/workout_session.dart';

void main() {
  test('returns zero calories when there are no logged sets', () {
    final startedAt = DateTime.utc(2026, 1, 1, 10);
    final session = WorkoutSession(
      id: 'session-1',
      title: 'Empty',
      startedAt: startedAt,
      endedAt: startedAt.add(const Duration(minutes: 45)),
      selectedExerciseId: null,
      exercises: [
        SessionExercise(
          id: 'session-exercise-1',
          exerciseId: 'exercise-1',
          exerciseName: 'Press',
          muscleGroup: 'Pecho',
          orderIndex: 0,
          startedAt: startedAt,
          sets: const [],
        ),
      ],
      heartRateSamples: const [],
    );

    expect(
      CalorieEstimator.estimateWorkoutCalories(
        session: session,
        bodyWeightKg: 75,
      ),
      0,
    );
  });

  test('estimates positive calories from sets, body weight, duration and bpm', () {
    final session = _sessionWithAverageBpm(125);

    final calories = CalorieEstimator.estimateWorkoutCalories(
      session: session,
      bodyWeightKg: 75,
    );

    expect(calories, greaterThan(0));
  });

  test('higher heart rate increases calories when workout volume is equal', () {
    final lowHeartRate = CalorieEstimator.estimateWorkoutCalories(
      session: _sessionWithAverageBpm(105),
      bodyWeightKg: 75,
    );
    final highHeartRate = CalorieEstimator.estimateWorkoutCalories(
      session: _sessionWithAverageBpm(150),
      bodyWeightKg: 75,
    );

    expect(highHeartRate, greaterThan(lowHeartRate));
  });
}

WorkoutSession _sessionWithAverageBpm(int bpm) {
  final startedAt = DateTime.utc(2026, 1, 1, 10);
  return WorkoutSession(
    id: 'session-1',
    title: 'Push day',
    startedAt: startedAt,
    endedAt: startedAt.add(const Duration(minutes: 45)),
    selectedExerciseId: 'exercise-1',
    exercises: [
      SessionExercise(
        id: 'session-exercise-1',
        exerciseId: 'exercise-1',
        exerciseName: 'Press de banca',
        muscleGroup: 'Pecho',
        orderIndex: 0,
        startedAt: startedAt,
        sets: [
          ExerciseSet(
            id: 'set-1',
            reps: 10,
            weightKg: 60,
            completedAt: startedAt.add(const Duration(minutes: 5)),
          ),
          ExerciseSet(
            id: 'set-2',
            reps: 8,
            weightKg: 65,
            completedAt: startedAt.add(const Duration(minutes: 10)),
          ),
        ],
      ),
    ],
    heartRateSamples: [
      HeartRateSample(
        id: 'hr-1',
        bpm: bpm,
        timestamp: startedAt.add(const Duration(minutes: 6)),
        exerciseId: 'exercise-1',
        source: 'manual',
      ),
      HeartRateSample(
        id: 'hr-2',
        bpm: bpm,
        timestamp: startedAt.add(const Duration(minutes: 12)),
        exerciseId: 'exercise-1',
        source: 'manual',
      ),
    ],
  );
}
