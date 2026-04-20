import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/app_settings.dart';
import '../models/body_type.dart';
import '../models/exercise_history_snapshot.dart';
import '../models/exercise_set.dart';
import '../models/exercise.dart';
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

  UserProfile? get profile => _profile;
  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get sessions => _sessions;
  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  String get languageCode => _settings.languageCode;
  bool get isBootstrapped => _isBootstrapped;
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
      title: 'Entrenamiento ${_sessions.where((item) => !item.isActive).length + 1}',
      startedAt: DateTime.now().toUtc(),
      endedAt: null,
      exercises: const [],
    );
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
      current.copyWith(exercises: [...current.exercises, sessionExercise]),
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

    await _updateSession(current.copyWith(exercises: reorderedExercises));
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
}
