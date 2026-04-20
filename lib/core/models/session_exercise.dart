import 'exercise_set.dart';

class SessionExercise {
  const SessionExercise({
    required this.id,
    required this.exerciseId,
    required this.exerciseName,
    required this.muscleGroup,
    required this.orderIndex,
    required this.startedAt,
    required this.sets,
  });

  final String id;
  final String exerciseId;
  final String exerciseName;
  final String muscleGroup;
  final int orderIndex;
  final DateTime startedAt;
  final List<ExerciseSet> sets;

  SessionExercise copyWith({
    List<ExerciseSet>? sets,
  }) {
    return SessionExercise(
      id: id,
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      orderIndex: orderIndex,
      startedAt: startedAt,
      sets: sets ?? this.sets,
    );
  }

  double get totalVolume => sets.fold<double>(
        0,
        (total, current) => total + (current.reps * current.weightKg),
      );

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'exerciseId': exerciseId,
      'exerciseName': exerciseName,
      'muscleGroup': muscleGroup,
      'orderIndex': orderIndex,
      'startedAt': startedAt.toIso8601String(),
      'sets': sets.map((set) => set.toMap()).toList(growable: false),
    };
  }

  factory SessionExercise.fromMap(Map<String, dynamic> map) {
    final rawSets = map['sets'] as List<dynamic>? ?? const [];
    return SessionExercise(
      id: map['id'] as String,
      exerciseId: map['exerciseId'] as String,
      exerciseName: map['exerciseName'] as String,
      muscleGroup: map['muscleGroup'] as String,
      orderIndex: map['orderIndex'] as int,
      startedAt: DateTime.parse(map['startedAt'] as String),
      sets: rawSets
          .map((item) => ExerciseSet.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
