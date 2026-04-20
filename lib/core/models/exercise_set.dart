class ExerciseSet {
  const ExerciseSet({
    required this.id,
    required this.reps,
    required this.weightKg,
    required this.completedAt,
  });

  final String id;
  final int reps;
  final double weightKg;
  final DateTime completedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reps': reps,
      'weightKg': weightKg,
      'completedAt': completedAt.toIso8601String(),
    };
  }

  factory ExerciseSet.fromMap(Map<String, dynamic> map) {
    return ExerciseSet(
      id: map['id'] as String,
      reps: map['reps'] as int,
      weightKg: (map['weightKg'] as num).toDouble(),
      completedAt: DateTime.parse(map['completedAt'] as String),
    );
  }
}
