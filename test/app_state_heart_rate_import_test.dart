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
  test('imports external heart-rate readings once for selected exercise', () async {
    final exercise = Exercise(
      id: 'exercise-1',
      name: 'Press de banca',
      muscleGroup: 'Pecho',
      isCustom: false,
      createdAt: DateTime.utc(2026, 1, 1),
    );
    final workoutRepository = _MemoryWorkoutRepository();
    final appState = AppState(
      profileRepository: _MemoryProfileRepository(),
      exerciseRepository: _MemoryExerciseRepository([exercise]),
      workoutRepository: workoutRepository,
      settingsRepository: _MemorySettingsRepository(),
      socialRepository: _MemorySocialRepository(),
      socialAuthService: _MemorySocialAuthService(),
    );

    await appState.bootstrap();
    await appState.startWorkoutSession();
    await appState.addExerciseToActiveSession(exercise);

    final timestamp = DateTime.utc(2026, 1, 1, 10, 5);
    final readings = [
      ExternalHeartRateReading(
        bpm: 123,
        timestamp: timestamp,
        source: 'apple_health:Apple Watch',
      ),
      ExternalHeartRateReading(
        bpm: 123,
        timestamp: timestamp,
        source: 'apple_health:Apple Watch',
      ),
    ];

    final firstImport = await appState.importHeartRateReadings(
      readings: readings,
      exerciseId: appState.currentHeartRateExerciseId(),
    );
    final secondImport = await appState.importHeartRateReadings(
      readings: readings,
      exerciseId: appState.currentHeartRateExerciseId(),
    );

    expect(firstImport, 1);
    expect(secondImport, 0);
    expect(appState.activeSession!.heartRateSamples, hasLength(1));
    expect(appState.activeSession!.heartRateSamples.single.bpm, 123);
    expect(
      appState.activeSession!.heartRateSamples.single.exerciseId,
      'exercise-1',
    );
    expect(
      workoutRepository.savedSessions.last.heartRateSamples.single.source,
      'apple_health:Apple Watch',
    );
  });
}

class _MemoryProfileRepository implements ProfileRepository {
  @override
  Future<UserProfile?> load() async {
    return UserProfile(
      id: 'profile-1',
      name: 'G',
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
  Set<String> _following = <String>{};
  Map<String, String> _avatarOverrides = <String, String>{};
  Set<String> _dismissedIncoming = <String>{};

  @override
  Future<Set<String>> loadFollowingIds() async => _following;

  @override
  Future<void> saveFollowingIds(Set<String> ids) async {
    _following = Set<String>.from(ids);
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
