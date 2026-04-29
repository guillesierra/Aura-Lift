import 'package:csv/csv.dart';

import '../models/exercise_set.dart';
import '../models/session_exercise.dart';
import '../models/workout_session.dart';

class WorkoutCsvImportReport {
  const WorkoutCsvImportReport({
    required this.sessions,
    required this.exercises,
    required this.sets,
  });

  final int sessions;
  final int exercises;
  final int sets;
}

class WorkoutCsvCodec {
  const WorkoutCsvCodec._();

  static const _bom = '\ufeff';

  static const List<String> exportHeaders = [
    'title',
    'start_time',
    'end_time',
    'exercise_title',
    'muscle_group',
    'set_index',
    'weight_kg',
    'reps',
    'set_completed_at',
    'session_id',
    'exercise_id',
    'set_id',
  ];

  static String encode(List<WorkoutSession> sessions) {
    final rows = <List<dynamic>>[exportHeaders];

    for (final session in sessions) {
      for (final exercise in session.exercises) {
        for (var i = 0; i < exercise.sets.length; i++) {
          final set = exercise.sets[i];
          rows.add([
            session.title,
            session.startedAt.toIso8601String(),
            session.endedAt?.toIso8601String() ?? '',
            exercise.exerciseName,
            exercise.muscleGroup,
            i,
            set.weightKg,
            set.reps,
            set.completedAt.toIso8601String(),
            session.id,
            exercise.exerciseId,
            set.id,
          ]);
        }
      }
    }

    return const ListToCsvConverter().convert(rows);
  }

  static ({List<WorkoutSession> sessions, WorkoutCsvImportReport report})
      decode(
    String raw,
  ) {
    final parsed = const CsvToListConverter(
      shouldParseNumbers: false,
      eol: '\n',
    ).convert(raw).where((row) => row.isNotEmpty).toList(growable: false);
    if (parsed.length <= 1) {
      return (
        sessions: const [],
        report:
            const WorkoutCsvImportReport(sessions: 0, exercises: 0, sets: 0),
      );
    }

    final header = parsed.first
        .map((item) => _normalizeHeader(item.toString()))
        .toList(growable: false);
    final indexByName = <String, int>{
      for (var i = 0; i < header.length; i++) header[i]: i,
    };

    final bucketBySession = <String, _SessionBucket>{};

    for (final row in parsed.skip(1)) {
      final title =
          _readCell(indexByName, row, const ['title', 'workout_title']) ??
              _readCellAtIndex(row, 0);
      final exerciseTitle = _readCell(
            indexByName,
            row,
            const ['exercise_title', 'exercise', 'exercise_name', 'name'],
          ) ??
          _readCellAtIndex(row, 4);
      if (title == null ||
          title.isEmpty ||
          exerciseTitle == null ||
          exerciseTitle.isEmpty) {
        continue;
      }

      final startedAt = _parseDate(_readCell(
              indexByName, row, const ['start_time', 'started_at', 'date'])) ??
          _parseDate(_readCellAtIndex(row, 1)) ??
          _parseDate(
              _readCell(indexByName, row, const ['end_time', 'ended_at'])) ??
          _parseDate(_readCellAtIndex(row, 2)) ??
          DateTime.now().toUtc();
      final endedAt = _parseDate(
            _readCell(indexByName, row, const ['end_time', 'ended_at']),
          ) ??
          _parseDate(_readCellAtIndex(row, 2));

      final sessionId =
          _readCell(indexByName, row, const ['session_id', 'workout_id']) ??
              'csv-${startedAt.microsecondsSinceEpoch}-${title.hashCode}';
      final sessionKey = '$sessionId|${startedAt.toIso8601String()}';
      final bucket = bucketBySession.putIfAbsent(
        sessionKey,
        () => _SessionBucket(
          id: sessionId,
          title: title,
          startedAt: startedAt,
          endedAt: endedAt,
        ),
      );

      final exerciseId = _readCell(indexByName, row, const ['exercise_id']) ??
          'csv-ex-${exerciseTitle.trim().toLowerCase().replaceAll(' ', '-')}-${bucket.exerciseBuckets.length + 1}';
      final muscleGroup =
          _readCell(indexByName, row, const ['muscle_group', 'muscle']) ??
              'General';
      final exerciseBucket = bucket.exerciseBuckets.putIfAbsent(
        exerciseTitle,
        () => _ExerciseBucket(
          id: exerciseId,
          name: exerciseTitle,
          muscleGroup: muscleGroup,
          orderIndex: bucket.exerciseBuckets.length,
        ),
      );

      final reps = _toInt(_readCell(indexByName, row, const ['reps'])) ?? 1;
      final weight = _toDouble(
              _readCell(indexByName, row, const ['weight_kg', 'weight'])) ??
          0;
      final setTime = _parseDate(
            _readCell(
                indexByName, row, const ['set_completed_at', 'completed_at']),
          ) ??
          bucket.startedAt;
      final setIndex =
          _toInt(_readCell(indexByName, row, const ['set_index', 'set'])) ??
              exerciseBucket.rawSets.length;

      final setId = _readCell(indexByName, row, const ['set_id']) ??
          'csv-set-${setTime.microsecondsSinceEpoch}-${exerciseBucket.rawSets.length}';
      exerciseBucket.rawSets.add(
        _RawSet(
          setIndex: setIndex,
          set: ExerciseSet(
            id: setId,
            reps: reps < 1 ? 1 : reps,
            weightKg: weight < 0 ? 0 : weight,
            completedAt: setTime,
          ),
        ),
      );
    }

    final sessions = bucketBySession.values
        .map((bucket) {
          final exercises = bucket.exerciseBuckets.values
              .map((exerciseBucket) {
                final sortedSets = exerciseBucket.rawSets
                    .toList(growable: false)
                  ..sort((a, b) => a.setIndex.compareTo(b.setIndex));

                return SessionExercise(
                  id: '${bucket.id}-${exerciseBucket.id}',
                  exerciseId: exerciseBucket.id,
                  exerciseName: exerciseBucket.name,
                  muscleGroup: exerciseBucket.muscleGroup,
                  orderIndex: exerciseBucket.orderIndex,
                  startedAt: bucket.startedAt,
                  sets: sortedSets
                      .map((item) => item.set)
                      .toList(growable: false),
                );
              })
              .where((exercise) => exercise.sets.isNotEmpty)
              .toList(growable: false)
            ..sort((a, b) => a.orderIndex.compareTo(b.orderIndex));

          return WorkoutSession(
            id: bucket.id,
            title: bucket.title,
            startedAt: bucket.startedAt,
            endedAt: bucket.endedAt,
            selectedExerciseId:
                exercises.isEmpty ? null : exercises.first.exerciseId,
            exercises: exercises,
            heartRateSamples: const [],
          );
        })
        .where((session) => session.exercises.isNotEmpty)
        .toList(growable: false)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final exerciseCount = sessions.fold<int>(
      0,
      (sum, session) => sum + session.exercises.length,
    );
    final setCount = sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalSets,
    );

    return (
      sessions: sessions,
      report: WorkoutCsvImportReport(
        sessions: sessions.length,
        exercises: exerciseCount,
        sets: setCount,
      ),
    );
  }

  static String _normalizeHeader(String value) {
    return _cleanCell(value)
        .trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');
  }

  static String _cleanCell(String value) {
    var cleaned = value.replaceFirst(_bom, '').trim();
    if (cleaned.length >= 2 &&
        cleaned.startsWith('"') &&
        cleaned.endsWith('"')) {
      cleaned = cleaned.substring(1, cleaned.length - 1).trim();
    }
    return cleaned;
  }

  static String? _readCell(
    Map<String, int> indexByName,
    List<dynamic> row,
    List<String> keys,
  ) {
    for (final key in keys) {
      final index = indexByName[_normalizeHeader(key)];
      if (index == null || index >= row.length) {
        continue;
      }
      final value = _cleanCell(row[index].toString());
      if (value.isNotEmpty) {
        return value;
      }
    }
    return null;
  }

  static String? _readCellAtIndex(List<dynamic> row, int index) {
    if (index < 0 || index >= row.length) {
      return null;
    }
    final value = _cleanCell(row[index].toString());
    return value.isEmpty ? null : value;
  }

  static int? _toInt(String? raw) {
    if (raw == null) {
      return null;
    }
    return int.tryParse(raw);
  }

  static double? _toDouble(String? raw) {
    if (raw == null) {
      return null;
    }
    return double.tryParse(raw.replaceAll(',', '.'));
  }

  static DateTime? _parseDate(String? raw) {
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final normalizedRaw = _cleanCell(raw).replaceAll('\u00a0', ' ');

    final iso = DateTime.tryParse(normalizedRaw);
    if (iso != null) {
      return iso.toUtc();
    }

    final commaParts = normalizedRaw.split(',');
    if (commaParts.length < 2) {
      return null;
    }

    final datePart = commaParts[0].trim();
    final timePart = commaParts[1].trim();
    final dateTokens = datePart.split(RegExp(r'\s+'));
    if (dateTokens.length < 3) {
      return null;
    }

    final day = int.tryParse(dateTokens[0]);
    final month = _monthFromToken(dateTokens[1]);
    final year = int.tryParse(dateTokens[2]);

    final timeTokens = timePart.split(':');
    if (day == null || month == null || year == null || timeTokens.length < 2) {
      return null;
    }

    final hour = int.tryParse(timeTokens[0]);
    final minute = int.tryParse(timeTokens[1]);
    if (hour == null || minute == null) {
      return null;
    }

    return DateTime(year, month, day, hour, minute).toUtc();
  }

  static int? _monthFromToken(String token) {
    final normalized = token.toLowerCase().replaceAll('.', '');
    const monthMap = {
      'jan': 1,
      'ene': 1,
      'feb': 2,
      'mar': 3,
      'apr': 4,
      'abr': 4,
      'may': 5,
      'jun': 6,
      'jul': 7,
      'aug': 8,
      'ago': 8,
      'sep': 9,
      'sept': 9,
      'oct': 10,
      'nov': 11,
      'dec': 12,
      'dic': 12,
    };
    return monthMap[normalized];
  }
}

class _SessionBucket {
  _SessionBucket({
    required this.id,
    required this.title,
    required this.startedAt,
    required this.endedAt,
  });

  final String id;
  final String title;
  final DateTime startedAt;
  final DateTime? endedAt;
  final Map<String, _ExerciseBucket> exerciseBuckets = {};
}

class _ExerciseBucket {
  _ExerciseBucket({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.orderIndex,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final int orderIndex;
  final List<_RawSet> rawSets = [];
}

class _RawSet {
  const _RawSet({
    required this.setIndex,
    required this.set,
  });

  final int setIndex;
  final ExerciseSet set;
}
