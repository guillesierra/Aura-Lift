class ExerciseProgressSummary {
  const ExerciseProgressSummary({
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.sessionsCount,
    required this.totalSets,
    required this.totalVolume,
    required this.bestWeight,
    required this.lastPerformedAt,
  });

  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final int sessionsCount;
  final int totalSets;
  final double totalVolume;
  final double bestWeight;
  final DateTime lastPerformedAt;
}
