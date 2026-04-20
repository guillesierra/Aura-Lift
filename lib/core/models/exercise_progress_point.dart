class ExerciseProgressPoint {
  const ExerciseProgressPoint({
    required this.sessionId,
    required this.sessionTitle,
    required this.sessionDate,
    required this.exerciseName,
    required this.muscleGroup,
    required this.setsCount,
    required this.totalReps,
    required this.totalVolume,
    required this.bestWeight,
    required this.setSummary,
  });

  final String sessionId;
  final String sessionTitle;
  final DateTime sessionDate;
  final String exerciseName;
  final String muscleGroup;
  final int setsCount;
  final int totalReps;
  final double totalVolume;
  final double bestWeight;
  final List<String> setSummary;
}
