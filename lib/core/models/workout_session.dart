import 'session_exercise.dart';

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.exercises,
  });

  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final List<SessionExercise> exercises;

  bool get isActive => endedAt == null;

  int get totalSets => exercises.fold<int>(
        0,
        (total, exercise) => total + exercise.sets.length,
      );

  double get totalVolume => exercises.fold<double>(
        0,
        (total, exercise) => total + exercise.totalVolume,
      );

  Duration get duration {
    final end = endedAt ?? DateTime.now().toUtc();
    return end.difference(startedAt);
  }

  WorkoutSession copyWith({
    String? title,
    DateTime? endedAt,
    bool keepEndedAt = true,
    List<SessionExercise>? exercises,
  }) {
    return WorkoutSession(
      id: id,
      title: title ?? this.title,
      startedAt: startedAt,
      endedAt: keepEndedAt ? endedAt ?? this.endedAt : null,
      exercises: exercises ?? this.exercises,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'exercises': exercises
          .map((exercise) => exercise.toMap())
          .toList(growable: false),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    final rawExercises = map['exercises'] as List<dynamic>? ?? const [];
    return WorkoutSession(
      id: map['id'] as String,
      title: map['title'] as String? ?? 'Entrenamiento',
      startedAt: DateTime.parse(map['startedAt'] as String),
      endedAt: map['endedAt'] == null
          ? null
          : DateTime.parse(map['endedAt'] as String),
      exercises: rawExercises
          .map((item) => SessionExercise.fromMap(item as Map<String, dynamic>))
          .toList(growable: false),
    );
  }
}
