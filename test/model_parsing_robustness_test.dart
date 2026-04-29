import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/models/exercise_set.dart';
import 'package:aura_lift/core/models/heart_rate_sample.dart';
import 'package:aura_lift/core/models/session_exercise.dart';
import 'package:aura_lift/core/models/workout_session.dart';

void main() {
  test('ExerciseSet.fromMap applies defaults on malformed payload', () {
    final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
    final set = ExerciseSet.fromMap({});
    final after = DateTime.now().toUtc().add(const Duration(seconds: 1));

    expect(set.id, '');
    expect(set.reps, 0);
    expect(set.weightKg, 0);
    expect(set.completedAt.isAfter(before), isTrue);
    expect(set.completedAt.isBefore(after), isTrue);
  });

  test('HeartRateSample.fromMap clamps bpm and falls back timestamp/source',
      () {
    final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
    final sample = HeartRateSample.fromMap({
      'id': 'hr-1',
      'bpm': 999,
      'timestamp': 'invalid-date',
    });
    final after = DateTime.now().toUtc().add(const Duration(seconds: 1));

    expect(sample.id, 'hr-1');
    expect(sample.bpm, 250);
    expect(sample.source, 'manual');
    expect(sample.timestamp.isAfter(before), isTrue);
    expect(sample.timestamp.isBefore(after), isTrue);
  });

  test('SessionExercise.fromMap tolerates invalid sets list items', () {
    final exercise = SessionExercise.fromMap({
      'id': 'sx-1',
      'exerciseId': 'ex-1',
      'exerciseName': 'Press',
      'muscleGroup': 'Pecho',
      'orderIndex': 1,
      'startedAt': '2026-01-01T00:00:00Z',
      'sets': [
        {
          'id': 's1',
          'reps': 8,
          'weightKg': 60,
          'completedAt': '2026-01-01T00:10:00Z',
        },
        'bad-item',
        123,
      ],
    });

    expect(exercise.id, 'sx-1');
    expect(exercise.sets.length, 1);
    expect(exercise.sets.first.reps, 8);
  });

  test('WorkoutSession.fromMap tolerates malformed nested lists and dates', () {
    final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
    final session = WorkoutSession.fromMap({
      'id': 'w-1',
      'title': 'Test',
      'startedAt': 'invalid',
      'endedAt': 'invalid',
      'exercises': [
        {
          'id': 'sx-1',
          'exerciseId': 'ex-1',
          'exerciseName': 'Deadlift',
          'muscleGroup': 'Espalda',
          'orderIndex': 0,
          'startedAt': '2026-01-01T00:00:00Z',
          'sets': const [],
        },
        'bad-exercise',
      ],
      'heartRateSamples': [
        {
          'id': 'hr-1',
          'bpm': 90,
          'timestamp': '2026-01-01T00:05:00Z',
          'source': 'manual',
        },
        'bad-sample',
      ],
    });
    final after = DateTime.now().toUtc().add(const Duration(seconds: 1));

    expect(session.id, 'w-1');
    expect(session.exercises.length, 1);
    expect(session.heartRateSamples.length, 1);
    expect(session.endedAt, isNull);
    expect(session.startedAt.isAfter(before), isTrue);
    expect(session.startedAt.isBefore(after), isTrue);
  });
}
