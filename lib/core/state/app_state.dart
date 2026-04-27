import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/body_type.dart';
import '../models/exercise_history_snapshot.dart';
import '../models/exercise_progress_point.dart';
import '../models/exercise_progress_summary.dart';
import '../models/exercise_set.dart';
import '../models/exercise.dart';
import '../models/external_heart_rate_reading.dart';
import '../models/heart_rate_coach_cue.dart';
import '../models/heart_rate_sample.dart';
import '../models/heart_rate_status.dart';
import '../models/session_exercise.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/workout_repository.dart';

class AppState extends ChangeNotifier {
  AppState({
    required ProfileRepository profileRepository,
    required ExerciseRepository exerciseRepository,
    required WorkoutRepository workoutRepository,
    required SettingsRepository settingsRepository,
  })  : _profileRepository = profileRepository,
        _exerciseRepository = exerciseRepository,
        _workoutRepository = workoutRepository,
        _settingsRepository = settingsRepository;

  final ProfileRepository _profileRepository;
  final ExerciseRepository _exerciseRepository;
  final WorkoutRepository _workoutRepository;
  final SettingsRepository _settingsRepository;

  UserProfile? _profile;
  List<Exercise> _exercises = const [];
  List<WorkoutSession> _sessions = const [];
  AppSettings _settings = AppSettings.defaults;
  bool _isBootstrapped = false;
  HeartRateCoachCue? _pendingHeartRateCoachCue;
  bool _effortCueTriggered = false;

  UserProfile? get profile => _profile;
  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get sessions => _sessions;
  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  String get languageCode => _settings.languageCode;
  bool get isBootstrapped => _isBootstrapped;
  HeartRateCoachCue? get pendingHeartRateCoachCue => _pendingHeartRateCoachCue;
  WorkoutSession? get activeSession {
    for (final session in _sessions.reversed) {
      if (session.isActive) {
        return session;
      }
    }
    return null;
  }

  Future<void> bootstrap() async {
    _profile = await _profileRepository.load();
    _exercises = await _exerciseRepository.loadExercises();
    _sessions = await _workoutRepository.loadSessions();
    _settings = await _settingsRepository.load();
    _isBootstrapped = true;
    notifyListeners();
  }

  Future<void> completeOnboarding(UserProfile profile) async {
    await _profileRepository.save(profile);
    _profile = profile;
    notifyListeners();
  }

  Future<void> updateProfile({
    required String name,
    required double heightCm,
    required double weightKg,
    required BodyType bodyType,
  }) async {
    final current = _profile;
    if (current == null) {
      return;
    }

    final updated = UserProfile(
      id: current.id,
      name: name.trim(),
      heightCm: heightCm,
      weightKg: weightKg,
      bodyType: bodyType,
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    await _profileRepository.save(updated);
    _profile = updated;
    notifyListeners();
  }

  Future<void> startWorkoutSession() async {
    if (activeSession != null) {
      return;
    }

    final session = WorkoutSession(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      title: _settings.languageCode == 'en'
          ? 'Workout ${_sessions.where((item) => !item.isActive).length + 1}'
          : 'Entrenamiento ${_sessions.where((item) => !item.isActive).length + 1}',
      startedAt: DateTime.now().toUtc(),
      endedAt: null,
      selectedExerciseId: null,
      exercises: const [],
      heartRateSamples: const [],
    );
    _resetHeartRateCoaching();
    _sessions = [..._sessions, session];
    await _persistSessions();
  }

  Future<void> finishActiveWorkoutSession() async {
    final current = activeSession;
    if (current == null) {
      return;
    }

    _sessions = _sessions
        .map(
          (session) => session.id == current.id
              ? session.copyWith(endedAt: DateTime.now().toUtc())
              : session,
        )
        .toList(growable: false);
    _resetHeartRateCoaching();
    await _persistSessions();
  }

  Future<void> addExerciseToActiveSession(Exercise exercise) async {
    final current = activeSession;
    if (current == null) {
      return;
    }

    final alreadyAdded = current.exercises.any(
      (item) => item.exerciseId == exercise.id,
    );
    if (alreadyAdded) {
      return;
    }

    final sessionExercise = SessionExercise(
      id: '${DateTime.now().microsecondsSinceEpoch}-${exercise.id}',
      exerciseId: exercise.id,
      exerciseName: exercise.name,
      muscleGroup: exercise.muscleGroup,
      orderIndex: current.exercises.length,
      startedAt: DateTime.now().toUtc(),
      sets: const [],
    );

    await _updateSession(
      current.copyWith(
        exercises: [...current.exercises, sessionExercise],
        selectedExerciseId: exercise.id,
      ),
    );
  }

  Future<void> addSetToExercise({
    required String sessionExerciseId,
    required int reps,
    required double weightKg,
  }) async {
    final current = activeSession;
    if (current == null) {
      return;
    }

    final updatedExercises = current.exercises.map((exercise) {
      if (exercise.id != sessionExerciseId) {
        return exercise;
      }

      final newSet = ExerciseSet(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        reps: reps,
        weightKg: weightKg,
        completedAt: DateTime.now().toUtc(),
      );

      return exercise.copyWith(sets: [...exercise.sets, newSet]);
    }).toList(growable: false);

    await _updateSession(current.copyWith(exercises: updatedExercises));
  }

  Future<void> renameWorkoutSession({
    required String sessionId,
    required String title,
  }) async {
    final normalized = title.trim();
    if (normalized.isEmpty) {
      return;
    }

    _sessions = _sessions
        .map(
          (session) => session.id == sessionId
              ? session.copyWith(title: normalized)
              : session,
        )
        .toList(growable: false);
    await _persistSessions();
  }

  Future<void> deleteWorkoutSession(String sessionId) async {
    _sessions = _sessions
        .where((session) => session.id != sessionId)
        .toList(growable: false);
    await _persistSessions();
  }

  Future<void> deleteSetFromExercise({
    required String sessionExerciseId,
    required String setId,
  }) async {
    final current = activeSession;
    if (current == null) {
      return;
    }

    final updatedExercises = current.exercises.map((exercise) {
      if (exercise.id != sessionExerciseId) {
        return exercise;
      }

      final remainingSets = exercise.sets
          .where((set) => set.id != setId)
          .toList(growable: false);
      return exercise.copyWith(sets: remainingSets);
    }).toList(growable: false);

    await _updateSession(current.copyWith(exercises: updatedExercises));
  }

  Future<void> deleteExerciseFromActiveSession(String sessionExerciseId) async {
    final current = activeSession;
    if (current == null) {
      return;
    }

    final filteredExercises = current.exercises
        .where((exercise) => exercise.id != sessionExerciseId)
        .toList(growable: false);

    final reorderedExercises = filteredExercises.asMap().entries.map((entry) {
      final exercise = entry.value;
      return SessionExercise(
        id: exercise.id,
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.exerciseName,
        muscleGroup: exercise.muscleGroup,
        orderIndex: entry.key,
        startedAt: exercise.startedAt,
        sets: exercise.sets,
      );
    }).toList(growable: false);

    final deletedExercise = current.exercises.firstWhere(
      (exercise) => exercise.id == sessionExerciseId,
    );

    await _updateSession(
      current.copyWith(
        exercises: reorderedExercises,
        selectedExerciseId: current.selectedExerciseId ==
                deletedExercise.exerciseId
            ? null
            : current.selectedExerciseId,
        keepSelectedExerciseId: current.selectedExerciseId !=
            deletedExercise.exerciseId,
      ),
    );
  }

  Future<void> selectHeartRateExercise(String exerciseId) async {
    final current = activeSession;
    if (current == null) {
      return;
    }

    final exists = current.exercises.any(
      (exercise) => exercise.exerciseId == exerciseId,
    );
    if (!exists) {
      return;
    }

    await _updateSession(
      current.copyWith(
        selectedExerciseId: exerciseId,
        keepSelectedExerciseId: true,
      ),
    );
  }

  Future<void> addCustomExercise({
    required String name,
    required String muscleGroup,
  }) async {
    await _exerciseRepository.addCustomExercise(
      name: name,
      muscleGroup: muscleGroup,
    );
    _exercises = await _exerciseRepository.loadExercises();
    notifyListeners();
  }

  Future<void> recordHeartRateSample({
    required int bpm,
    String source = 'manual',
    String? exerciseId,
    DateTime? timestamp,
  }) async {
    final current = activeSession;
    if (current == null) {
      return;
    }

    final sampleTimestamp = (timestamp ?? DateTime.now()).toUtc();
    final targetExerciseId = exerciseId ?? current.selectedExerciseId;
    final sampleKey = _heartRateSampleKey(
      bpm: bpm,
      timestamp: sampleTimestamp,
      source: source,
      exerciseId: targetExerciseId,
    );
    final alreadyRecorded = current.heartRateSamples.any(
      (sample) =>
          _heartRateSampleKey(
            bpm: sample.bpm,
            timestamp: sample.timestamp,
            source: sample.source,
            exerciseId: sample.exerciseId,
          ) ==
          sampleKey,
    );
    if (alreadyRecorded) {
      return;
    }

    final sample = HeartRateSample(
      id: sampleTimestamp.microsecondsSinceEpoch.toString(),
      bpm: bpm,
      timestamp: sampleTimestamp,
      exerciseId: targetExerciseId,
      source: source,
    );
    final samples = [...current.heartRateSamples, sample]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    final updatedSession = current.copyWith(
      heartRateSamples: samples,
    );
    _evaluateHeartRateCoaching(updatedSession);
    await _updateSession(updatedSession);
  }

  Future<int> importHeartRateReadings({
    required List<ExternalHeartRateReading> readings,
    String? exerciseId,
  }) async {
    final current = activeSession;
    if (current == null || readings.isEmpty) {
      return 0;
    }

    final targetExerciseId = exerciseId ?? current.selectedExerciseId;
    final existingKeys = current.heartRateSamples
        .map(
          (sample) => _heartRateSampleKey(
            bpm: sample.bpm,
            timestamp: sample.timestamp,
            source: sample.source,
            exerciseId: sample.exerciseId,
          ),
        )
        .toSet();
    final importedSamples = <HeartRateSample>[];

    for (final reading in readings) {
      final timestamp = reading.timestamp.toUtc();
      final source = reading.source.isEmpty ? 'external' : reading.source;
      final key = _heartRateSampleKey(
        bpm: reading.bpm,
        timestamp: timestamp,
        source: source,
        exerciseId: targetExerciseId,
      );
      if (existingKeys.contains(key)) {
        continue;
      }

      existingKeys.add(key);
      importedSamples.add(
        HeartRateSample(
          id: '${source.hashCode}-${timestamp.microsecondsSinceEpoch}',
          bpm: reading.bpm,
          timestamp: timestamp,
          exerciseId: targetExerciseId,
          source: source,
        ),
      );
    }

    if (importedSamples.isEmpty) {
      return 0;
    }

    final samples = [...current.heartRateSamples, ...importedSamples]
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    final updatedSession = current.copyWith(heartRateSamples: samples);
    _evaluateHeartRateCoaching(updatedSession);
    await _updateSession(updatedSession);
    return importedSamples.length;
  }

  List<HeartRateSample> recentHeartRateSamples({int limit = 8}) {
    final current = activeSession;
    if (current == null) {
      return const [];
    }

    final samples = current.heartRateSamples;
    if (samples.length <= limit) {
      return samples;
    }
    return samples.sublist(samples.length - limit);
  }

  String? currentHeartRateExerciseId() {
    final current = activeSession;
    return current?.selectedExerciseId;
  }

  String? currentHeartRateExerciseName() {
    final current = activeSession;
    final selectedExerciseId = current?.selectedExerciseId;
    if (current == null || selectedExerciseId == null) {
      return null;
    }

    for (final exercise in current.exercises) {
      if (exercise.exerciseId == selectedExerciseId) {
        return exercise.exerciseName;
      }
    }
    return null;
  }

  HeartRateStatus currentHeartRateStatus() {
    final samples = recentHeartRateSamples();
    if (samples.length < 3) {
      return HeartRateStatus.idle;
    }

    final baseline = currentHeartRateBaseline();
    final last = samples.last.bpm;
    final previous = samples[samples.length - 2].bpm;
    final recentPeak = samples.fold<int>(
      0,
      (maxValue, sample) => sample.bpm > maxValue ? sample.bpm : maxValue,
    );

    if (baseline != null && last >= _effortThresholdFromBaseline(baseline)) {
      return HeartRateStatus.pushing;
    }

    if (last >= 145 || (last >= previous && last >= 135)) {
      return HeartRateStatus.pushing;
    }

    final dropFromPeak = recentPeak - last;
    if (baseline != null &&
        _effortCueTriggered &&
        last <= _restReadyThresholdFromBaseline(baseline)) {
      return HeartRateStatus.readyForNextSet;
    }

    if (recentPeak >= 135 && dropFromPeak >= 12 && last > 105) {
      return HeartRateStatus.restSuggested;
    }

    if (recentPeak >= 135 && last <= 105 && (previous - last).abs() <= 4) {
      return HeartRateStatus.readyForNextSet;
    }

    return HeartRateStatus.restSuggested;
  }

  int? currentHeartRateBaseline() {
    final current = activeSession;
    if (current == null || current.heartRateSamples.length < 3) {
      return null;
    }

    final baselineWindow = current.heartRateSamples.take(3);
    final total = baselineWindow.fold<int>(
      0,
      (sum, sample) => sum + sample.bpm,
    );
    return (total / 3).round();
  }

  HeartRateCoachCue? consumePendingHeartRateCoachCue() {
    final cue = _pendingHeartRateCoachCue;
    _pendingHeartRateCoachCue = null;
    return cue;
  }

  Future<void> updateThemeMode(ThemeMode mode) async {
    _settings = _settings.copyWith(themeMode: mode);
    await _settingsRepository.save(_settings);
    notifyListeners();
  }

  Future<void> updateLanguageCode(String languageCode) async {
    _settings = _settings.copyWith(languageCode: languageCode);
    await _settingsRepository.save(_settings);
    notifyListeners();
  }

  ExerciseHistorySnapshot? lastPerformanceForExercise(
    String exerciseId, {
    String? excludingSessionId,
  }) {
    return ExerciseHistorySnapshot.fromSessions(
      sessions: _sessions,
      exerciseId: exerciseId,
      excludingSessionId: excludingSessionId,
    );
  }

  List<ExerciseProgressSummary> exerciseProgressSummaries() {
    final completedSessions = _sessions.where((session) => !session.isActive);
    final Map<String, _ExerciseAggregate> aggregates = {};

    for (final session in completedSessions) {
      for (final exercise in session.exercises) {
        final current = aggregates[exercise.exerciseId];
        final bestWeight = exercise.sets.fold<double>(
          0,
          (maxValue, set) => set.weightKg > maxValue ? set.weightKg : maxValue,
        );

        if (current == null) {
          aggregates[exercise.exerciseId] = _ExerciseAggregate(
            exerciseId: exercise.exerciseId,
            exerciseName: exercise.exerciseName,
            muscleGroup: exercise.muscleGroup,
            sessionsCount: 1,
            totalSets: exercise.sets.length,
            totalVolume: exercise.totalVolume,
            bestWeight: bestWeight,
            lastPerformedAt: session.startedAt,
          );
          continue;
        }

        aggregates[exercise.exerciseId] = current.copyWith(
          sessionsCount: current.sessionsCount + 1,
          totalSets: current.totalSets + exercise.sets.length,
          totalVolume: current.totalVolume + exercise.totalVolume,
          bestWeight: bestWeight > current.bestWeight
              ? bestWeight
              : current.bestWeight,
          lastPerformedAt: session.startedAt.isAfter(current.lastPerformedAt)
              ? session.startedAt
              : current.lastPerformedAt,
        );
      }
    }

    final list = aggregates.values
        .map(
          (item) => ExerciseProgressSummary(
            exerciseId: item.exerciseId,
            exerciseName: item.exerciseName,
            muscleGroup: item.muscleGroup,
            sessionsCount: item.sessionsCount,
            totalSets: item.totalSets,
            totalVolume: item.totalVolume,
            bestWeight: item.bestWeight,
            lastPerformedAt: item.lastPerformedAt,
          ),
        )
        .toList(growable: false);

    list.sort((a, b) => b.lastPerformedAt.compareTo(a.lastPerformedAt));
    return list;
  }

  List<ExerciseProgressPoint> progressHistoryForExercise(String exerciseId) {
    final completedSessions = _sessions
        .where((session) => !session.isActive)
        .toList(growable: false)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));

    final history = <ExerciseProgressPoint>[];
    for (final session in completedSessions) {
      for (final exercise in session.exercises) {
        if (exercise.exerciseId != exerciseId) {
          continue;
        }

        final totalReps = exercise.sets.fold<int>(
          0,
          (sum, set) => sum + set.reps,
        );
        final bestWeight = exercise.sets.fold<double>(
          0,
          (maxValue, set) => set.weightKg > maxValue ? set.weightKg : maxValue,
        );
        final setSummary = exercise.sets.asMap().entries.map((entry) {
          final set = entry.value;
          final weight = set.weightKg % 1 == 0
              ? set.weightKg.toStringAsFixed(0)
              : set.weightKg.toStringAsFixed(1);
          final setLabel = _settings.languageCode == 'en'
              ? 'Set ${entry.key + 1}'
              : 'S${entry.key + 1}';
          return '$setLabel: ${set.reps} x $weight kg';
        }).toList(growable: false);

        history.add(
          ExerciseProgressPoint(
            sessionId: session.id,
            sessionTitle: session.title,
            sessionDate: session.startedAt,
            exerciseName: exercise.exerciseName,
            muscleGroup: exercise.muscleGroup,
            setsCount: exercise.sets.length,
            totalReps: totalReps,
            totalVolume: exercise.totalVolume,
            bestWeight: bestWeight,
            setSummary: setSummary,
          ),
        );
      }
    }
    return history;
  }

  Future<void> _updateSession(WorkoutSession updatedSession) async {
    _sessions = _sessions
        .map((session) {
          if (session.id == updatedSession.id) {
            return updatedSession;
          }
          return session;
        })
        .toList(growable: false);
    await _persistSessions();
  }

  Future<void> _persistSessions() async {
    await _workoutRepository.saveSessions(_sessions);
    notifyListeners();
  }

  void _evaluateHeartRateCoaching(WorkoutSession session) {
    final baseline = _baselineFromSamples(session.heartRateSamples);
    if (baseline == null) {
      return;
    }

    final currentBpm = session.heartRateSamples.last.bpm;
    final effortThreshold = _effortThresholdFromBaseline(baseline);
    final restReadyThreshold = _restReadyThresholdFromBaseline(baseline);

    if (!_effortCueTriggered && currentBpm >= effortThreshold) {
      _effortCueTriggered = true;
      _pendingHeartRateCoachCue = HeartRateCoachCue.motivation;
      return;
    }

    if (_effortCueTriggered && currentBpm <= restReadyThreshold) {
      _effortCueTriggered = false;
      _pendingHeartRateCoachCue = HeartRateCoachCue.nextSet;
    }
  }

  int? _baselineFromSamples(List<HeartRateSample> samples) {
    if (samples.length < 3) {
      return null;
    }

    final baselineWindow = samples.take(3);
    final total = baselineWindow.fold<int>(
      0,
      (sum, sample) => sum + sample.bpm,
    );
    return (total / 3).round();
  }

  int _effortThresholdFromBaseline(int baseline) {
    return (baseline * 1.15).round();
  }

  int _restReadyThresholdFromBaseline(int baseline) {
    return (baseline * 1.15).round();
  }

  void _resetHeartRateCoaching() {
    _pendingHeartRateCoachCue = null;
    _effortCueTriggered = false;
  }

  String _heartRateSampleKey({
    required int bpm,
    required DateTime timestamp,
    required String source,
    required String? exerciseId,
  }) {
    return [
      timestamp.toUtc().toIso8601String(),
      bpm,
      source,
      exerciseId ?? '',
    ].join('|');
  }
}

class _ExerciseAggregate {
  const _ExerciseAggregate({
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

  _ExerciseAggregate copyWith({
    int? sessionsCount,
    int? totalSets,
    double? totalVolume,
    double? bestWeight,
    DateTime? lastPerformedAt,
  }) {
    return _ExerciseAggregate(
      exerciseId: exerciseId,
      exerciseName: exerciseName,
      muscleGroup: muscleGroup,
      sessionsCount: sessionsCount ?? this.sessionsCount,
      totalSets: totalSets ?? this.totalSets,
      totalVolume: totalVolume ?? this.totalVolume,
      bestWeight: bestWeight ?? this.bestWeight,
      lastPerformedAt: lastPerformedAt ?? this.lastPerformedAt,
    );
  }
}
