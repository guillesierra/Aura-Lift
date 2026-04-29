import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/auth/social_auth_service.dart';
import 'package:aura_lift/core/models/app_settings.dart';
import 'package:aura_lift/core/models/body_type.dart';
import 'package:aura_lift/core/models/exercise.dart';
import 'package:aura_lift/core/models/external_heart_rate_reading.dart';
import 'package:aura_lift/core/models/user_profile.dart';
import 'package:aura_lift/core/models/workout_session.dart';
import 'package:aura_lift/core/repositories/exercise_repository.dart';
import 'package:aura_lift/core/repositories/profile_repository.dart';
import 'package:aura_lift/core/repositories/settings_repository.dart';
import 'package:aura_lift/core/repositories/social_repository.dart';
import 'package:aura_lift/core/repositories/workout_repository.dart';
import 'package:aura_lift/core/state/app_state.dart';

void main() {
  group('Critical integration flows (AppState)', () {
    test('workout flow: start, add exercise/set, finish and persist', () async {
      final appState = _buildAppState(
        exercises: [
          Exercise(
            id: 'exercise-bench',
            name: 'Press de banca',
            muscleGroup: 'Pecho',
            isCustom: false,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      await appState.bootstrap();
      await appState.startWorkoutSession();
      expect(appState.activeSession, isNotNull);

      final exercise = appState.exercises.first;
      await appState.addExerciseToActiveSession(exercise);

      final sessionExercise = appState.activeSession!.exercises.single;
      await appState.addSetToExercise(
        sessionExerciseId: sessionExercise.id,
        reps: 8,
        weightKg: 80,
      );

      expect(appState.activeSession!.totalSets, 1);
      expect(appState.activeSession!.totalVolume, 640);

      await appState.finishActiveWorkoutSession();
      expect(appState.activeSession, isNull);

      final finished = appState.sessions.last;
      expect(finished.endedAt, isNotNull);
      expect(finished.exercises.single.sets.single.weightKg, 80);
    });

    test('health flow: import deduplicated heart-rate readings', () async {
      final appState = _buildAppState(
        exercises: [
          Exercise(
            id: 'exercise-squat',
            name: 'Sentadilla',
            muscleGroup: 'Piernas',
            isCustom: false,
            createdAt: DateTime.utc(2026, 1, 1),
          ),
        ],
      );

      await appState.bootstrap();
      await appState.startWorkoutSession();
      await appState.addExerciseToActiveSession(appState.exercises.first);

      final selectedExerciseId = appState.currentHeartRateExerciseId();
      expect(selectedExerciseId, 'exercise-squat');

      final readings = [
        ExternalHeartRateReading(
          bpm: 132,
          timestamp: DateTime.utc(2026, 1, 1, 10, 0),
          source: 'android_health_connect:PixelWatch',
        ),
        ExternalHeartRateReading(
          bpm: 132,
          timestamp: DateTime.utc(2026, 1, 1, 10, 0),
          source: 'android_health_connect:PixelWatch',
        ),
      ];

      final first = await appState.importHeartRateReadings(
        readings: readings,
        exerciseId: selectedExerciseId,
      );
      final second = await appState.importHeartRateReadings(
        readings: readings,
        exerciseId: selectedExerciseId,
      );

      expect(first, 1);
      expect(second, 0);
      expect(appState.activeSession!.heartRateSamples, hasLength(1));
      expect(
        appState.activeSession!.heartRateSamples.single.exerciseId,
        'exercise-squat',
      );
      expect(
        appState.activeSession!.heartRateSamples.single.source,
        'android_health_connect:PixelWatch',
      );
    });

    test('social flow: incoming request, accept and toggle follow', () async {
      final socialRepository = _MemorySocialRepository();
      final appState = _buildAppState(
        exercises: const [],
        socialRepository: socialRepository,
      );

      await appState.bootstrap();

      expect(
        appState.connectionStatusFor('social-lucia'),
        SocialConnectionStatus.requestReceived,
      );

      await appState.acceptIncomingRequest('social-lucia');

      expect(
        appState.connectionStatusFor('social-lucia'),
        SocialConnectionStatus.friends,
      );
      expect(
          appState.friendProfiles.any((p) => p.id == 'social-lucia'), isTrue);
      expect(
          socialRepository.savedFollowingIds.contains('social-lucia'), isTrue);

      expect(
        appState.connectionStatusFor('social-marcos'),
        SocialConnectionStatus.notFollowing,
      );

      await appState.toggleFollowProfile('social-marcos');

      expect(
        appState.connectionStatusFor('social-marcos'),
        SocialConnectionStatus.requestSent,
      );
      expect(
        appState.outgoingRequestProfiles.any((p) => p.id == 'social-marcos'),
        isTrue,
      );
    });
  });
}

AppState _buildAppState({
  required List<Exercise> exercises,
  _MemorySocialRepository? socialRepository,
}) {
  return AppState(
    profileRepository: _MemoryProfileRepository(),
    exerciseRepository: _MemoryExerciseRepository(exercises),
    workoutRepository: _MemoryWorkoutRepository(),
    settingsRepository: _MemorySettingsRepository(),
    socialRepository: socialRepository ?? _MemorySocialRepository(),
    socialAuthService: _MemorySocialAuthService(),
  );
}

class _MemoryProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> load() async {
    return UserProfile(
      id: 'profile-1',
      name: 'Guillermo',
      heightCm: 180,
      weightKg: 80,
      bodyType: BodyType.mesomorph,
      presentation: '',
      city: '',
      gym: '',
      createdAt: DateTime.utc(2026, 1, 1),
      updatedAt: DateTime.utc(2026, 1, 1),
    );
  }

  @override
  Future<void> save(UserProfile profile) async {}
}

class _MemoryExerciseRepository implements ExerciseRepository {
  _MemoryExerciseRepository(this._exercises);

  final List<Exercise> _exercises;

  @override
  Future<void> addCustomExercise({
    required String name,
    required String muscleGroup,
    String? equipment,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    String? difficulty,
    String? imageAssetPath,
    String? imagePrompt,
  }) async {}

  @override
  Future<List<Exercise>> loadExercises() async => _exercises;
}

class _MemoryWorkoutRepository implements WorkoutRepository {
  List<WorkoutSession> savedSessions = const [];

  @override
  Future<List<WorkoutSession>> loadSessions() async => savedSessions;

  @override
  Future<void> saveSessions(List<WorkoutSession> sessions) async {
    savedSessions = sessions;
  }
}

class _MemorySettingsRepository implements SettingsRepository {
  @override
  Future<AppSettings> load() async => AppSettings.defaults;

  @override
  Future<void> save(AppSettings settings) async {}
}

class _MemorySocialRepository implements SocialRepository {
  Set<String> savedFollowingIds = <String>{};
  Map<String, String> _avatarOverrides = <String, String>{};
  Set<String> _dismissedIncoming = <String>{};

  @override
  Future<Set<String>> loadFollowingIds() async => savedFollowingIds;

  @override
  Future<void> saveFollowingIds(Set<String> ids) async {
    savedFollowingIds = Set<String>.from(ids);
  }

  @override
  Future<Map<String, String>> loadAvatarOverrides() async => _avatarOverrides;

  @override
  Future<void> saveAvatarOverrides(Map<String, String> overrides) async {
    _avatarOverrides = Map<String, String>.from(overrides);
  }

  @override
  Future<Set<String>> loadDismissedIncomingRequestIds() async {
    return _dismissedIncoming;
  }

  @override
  Future<void> saveDismissedIncomingRequestIds(Set<String> ids) async {
    _dismissedIncoming = Set<String>.from(ids);
  }
}

class _MemorySocialAuthService implements SocialAuthService {
  @override
  Future<SocialAuthAccount?> restoreSession() async => null;

  @override
  Future<SocialAuthResult> signInWithApple() async {
    return SocialAuthResult.unsupported();
  }

  @override
  Future<SocialAuthResult> signInWithGoogle() async {
    return SocialAuthResult.unsupported();
  }

  @override
  Future<void> signOut() async {}
}
