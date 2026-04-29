import 'dart:math' as math;

import '../models/session_exercise.dart';
import '../models/workout_session.dart';

class CalorieEstimator {
  const CalorieEstimator._();

  static int estimateWorkoutCalories({
    required WorkoutSession session,
    required double bodyWeightKg,
  }) {
    final calories = estimateWorkoutCaloriesValue(
      session: session,
      bodyWeightKg: bodyWeightKg,
    );
    return calories.round().clamp(0, 9999).toInt();
  }

  static double estimateWorkoutCaloriesValue({
    required WorkoutSession session,
    required double bodyWeightKg,
  }) {
    if (bodyWeightKg <= 0 || session.exercises.isEmpty) {
      return 0;
    }

    return session.exercises.fold<double>(
      0,
      (sum, exercise) =>
          sum +
          _estimateExerciseCaloriesValue(
            session: session,
            exercise: exercise,
            bodyWeightKg: bodyWeightKg,
          ),
    );
  }

  static int estimateExerciseCalories({
    required WorkoutSession session,
    required SessionExercise exercise,
    required double bodyWeightKg,
  }) {
    final calories = _estimateExerciseCaloriesValue(
      session: session,
      exercise: exercise,
      bodyWeightKg: bodyWeightKg,
    );
    return calories.round().clamp(0, 9999).toInt();
  }

  static double _estimateExerciseCaloriesValue({
    required WorkoutSession session,
    required SessionExercise exercise,
    required double bodyWeightKg,
  }) {
    if (bodyWeightKg <= 0 || exercise.sets.isEmpty) {
      return 0;
    }

    final minutes = _exerciseMinutes(session, exercise);
    if (minutes <= 0) {
      return 0;
    }

    final heartRate =
        session.averageHeartRateForExercise(exercise.exerciseId) ??
            session.averageHeartRate;
    final met = _baseMetForMuscleGroup(exercise.muscleGroup) *
        _volumeIntensityFactor(exercise, bodyWeightKg) *
        _heartRateFactor(heartRate);

    return met * 3.5 * bodyWeightKg / 200 * minutes;
  }

  static double _exerciseMinutes(
    WorkoutSession session,
    SessionExercise exercise,
  ) {
    final workoutMinutes = _effectiveWorkoutMinutes(session);
    if (workoutMinutes <= 0 || session.exercises.isEmpty) {
      return 0;
    }

    if (session.totalSets > 0) {
      return workoutMinutes * exercise.sets.length / session.totalSets;
    }

    return workoutMinutes / session.exercises.length;
  }

  static double _effectiveWorkoutMinutes(WorkoutSession session) {
    final actualMinutes = session.duration.inSeconds / 60;
    if (actualMinutes.isFinite && actualMinutes >= 1) {
      return actualMinutes;
    }

    final totalReps = session.exercises.fold<int>(
      0,
      (sum, exercise) => sum + _totalReps(exercise),
    );
    if (session.totalSets == 0 && totalReps == 0) {
      return 0;
    }

    return math.max(1, session.totalSets * 2.5 + totalReps * 0.04);
  }

  static double _baseMetForMuscleGroup(String muscleGroup) {
    switch (muscleGroup.toLowerCase()) {
      case 'cardio':
        return 7.5;
      case 'piernas':
      case 'espalda':
        return 6.0;
      case 'pecho':
      case 'hombros':
        return 5.5;
      case 'core':
        return 4.5;
      case 'biceps':
      case 'triceps':
      case 'gemelos':
      case 'trapecio':
        return 4.0;
      default:
        return 4.5;
    }
  }

  static double _volumeIntensityFactor(
    SessionExercise exercise,
    double bodyWeightKg,
  ) {
    final totalReps = _totalReps(exercise);
    final volumePerBodyKg = exercise.totalVolume / math.max(bodyWeightKg, 1);
    final repsFactor = _clampDouble(0.9 + totalReps / 300, 0.85, 1.2);
    final loadFactor = _clampDouble(0.9 + volumePerBodyKg / 180, 0.85, 1.25);
    return (repsFactor + loadFactor) / 2;
  }

  static double _heartRateFactor(int? averageBpm) {
    if (averageBpm == null) {
      return 1;
    }

    return _clampDouble(0.75 + (averageBpm - 90) / 100, 0.75, 1.35);
  }

  static int _totalReps(SessionExercise exercise) {
    return exercise.sets.fold<int>(0, (sum, set) => sum + set.reps);
  }

  static double _clampDouble(double value, double min, double max) {
    return value.clamp(min, max).toDouble();
  }
}
