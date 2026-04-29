import '../models/workout_session.dart';

class AuraPointsEstimator {
  const AuraPointsEstimator._();

  static int estimateWorkoutPoints({
    required WorkoutSession session,
    required double bodyWeightKg,
  }) {
    final safeBodyWeight = bodyWeightKg <= 0 ? 70.0 : bodyWeightKg;
    final durationMinutes = session.duration.inMinutes < 1
        ? 1
        : session.duration.inMinutes;

    var relativeVolume = 0.0;
    var weightedSetCount = 0.0;
    var intensityScore = 0.0;
    var heavySetBonus = 0.0;

    for (final exercise in session.exercises) {
      for (final set in exercise.sets) {
        final relativeLoad = (set.weightKg / safeBodyWeight).clamp(0.0, 4.0);
        relativeVolume += set.reps * relativeLoad;
        weightedSetCount += 0.55 + (relativeLoad * 0.6);
        intensityScore += set.reps * relativeLoad * relativeLoad;
        if (relativeLoad >= 1.0) {
          heavySetBonus += 2.6;
        } else if (relativeLoad >= 0.8) {
          heavySetBonus += 1.3;
        }
      }
    }

    final exerciseBonus = session.exercises.length * 4.0;
    final durationBonus = durationMinutes * 0.42;
    final workScore = relativeVolume * 2.9;
    final setScore = weightedSetCount * 1.35;
    final competitiveScore = intensityScore * 2.1;

    final total =
        workScore + setScore + competitiveScore + heavySetBonus + durationBonus + exerciseBonus;
    return total <= 0 ? 0 : total.round();
  }
}
