import 'heart_rate_sample.dart';
import 'session_exercise.dart';

class WorkoutSession {
  const WorkoutSession({
    required this.id,
    required this.title,
    required this.startedAt,
    required this.endedAt,
    required this.selectedExerciseId,
    required this.exercises,
    required this.heartRateSamples,
  });

  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final String? selectedExerciseId;
  final List<SessionExercise> exercises;
  final List<HeartRateSample> heartRateSamples;

  bool get isActive => endedAt == null;

  int get totalSets => exercises.fold<int>(
        0,
        (total, exercise) => total + exercise.sets.length,
      );

  double get totalVolume => exercises.fold<double>(
        0,
        (total, exercise) => total + exercise.totalVolume,
      );

  int? get averageHeartRate {
    if (heartRateSamples.isEmpty) {
      return null;
    }

    final total = heartRateSamples.fold<int>(
      0,
      (sum, sample) => sum + sample.bpm,
    );
    return (total / heartRateSamples.length).round();
  }

  int? get maxHeartRate {
    if (heartRateSamples.isEmpty) {
      return null;
    }

    return heartRateSamples.fold<int>(
      heartRateSamples.first.bpm,
      (maxValue, sample) => sample.bpm > maxValue ? sample.bpm : maxValue,
    );
  }

  int? averageHeartRateForExercise(String exerciseId) {
    final samples = heartRateSamples
        .where((sample) => sample.exerciseId == exerciseId)
        .toList(growable: false);
    if (samples.isEmpty) {
      return null;
    }

    final total = samples.fold<int>(
      0,
      (sum, sample) => sum + sample.bpm,
    );
    return (total / samples.length).round();
  }

  int? maxHeartRateForExercise(String exerciseId) {
    final samples = heartRateSamples
        .where((sample) => sample.exerciseId == exerciseId)
        .toList(growable: false);
    if (samples.isEmpty) {
      return null;
    }

    return samples.fold<int>(
      samples.first.bpm,
      (maxValue, sample) => sample.bpm > maxValue ? sample.bpm : maxValue,
    );
  }

  int heartRateSampleCountForExercise(String exerciseId) {
    return heartRateSamples
        .where((sample) => sample.exerciseId == exerciseId)
        .length;
  }

  Duration get duration {
    final end = endedAt ?? DateTime.now().toUtc();
    return end.difference(startedAt);
  }

  WorkoutSession copyWith({
    String? title,
    DateTime? endedAt,
    bool keepEndedAt = true,
    String? selectedExerciseId,
    bool keepSelectedExerciseId = true,
    List<SessionExercise>? exercises,
    List<HeartRateSample>? heartRateSamples,
  }) {
    return WorkoutSession(
      id: id,
      title: title ?? this.title,
      startedAt: startedAt,
      endedAt: keepEndedAt ? endedAt ?? this.endedAt : null,
      selectedExerciseId: keepSelectedExerciseId
          ? selectedExerciseId ?? this.selectedExerciseId
          : selectedExerciseId,
      exercises: exercises ?? this.exercises,
      heartRateSamples: heartRateSamples ?? this.heartRateSamples,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'startedAt': startedAt.toIso8601String(),
      'endedAt': endedAt?.toIso8601String(),
      'selectedExerciseId': selectedExerciseId,
      'exercises':
          exercises.map((exercise) => exercise.toMap()).toList(growable: false),
      'heartRateSamples': heartRateSamples
          .map((sample) => sample.toMap())
          .toList(growable: false),
    };
  }

  factory WorkoutSession.fromMap(Map<String, dynamic> map) {
    final fallbackTime = DateTime.now().toUtc();
    final rawExercises = map['exercises'] as List<dynamic>? ?? const [];
    final rawHeartRate = map['heartRateSamples'] as List<dynamic>? ?? const [];
    return WorkoutSession(
      id: (map['id'] as String?) ?? '',
      title: map['title'] as String? ?? 'Entrenamiento',
      startedAt: DateTime.tryParse((map['startedAt'] as String?) ?? '') ??
          fallbackTime,
      endedAt: map['endedAt'] == null
          ? null
          : DateTime.tryParse((map['endedAt'] as String?) ?? ''),
      selectedExerciseId: map['selectedExerciseId'] as String?,
      exercises: rawExercises
          .whereType<Map>()
          .map(
            (item) => SessionExercise.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
      heartRateSamples: rawHeartRate
          .whereType<Map>()
          .map(
            (item) => HeartRateSample.fromMap(Map<String, dynamic>.from(item)),
          )
          .toList(growable: false),
    );
  }
}
