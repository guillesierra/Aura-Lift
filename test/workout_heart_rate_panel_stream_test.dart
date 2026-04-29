import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/auth/social_auth_service.dart';
import 'package:aura_lift/core/health/wearable_heart_rate_stream_service.dart';
import 'package:aura_lift/core/localization/app_strings.dart';
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
import 'package:aura_lift/features/workout/widgets/workout_heart_rate_panel.dart';

void main() {
  testWidgets('starts wearable stream and imports live sample',
      (tester) async {
    final appState = _buildAppState();
    await appState.bootstrap();
    await appState.startWorkoutSession();
    await appState.addExerciseToActiveSession(appState.exercises.first);

    final fakeWearableService = _FakeWearableHeartRateStreamService();
    final strings = AppStrings.of(appState.languageCode);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: WorkoutHeartRatePanel(
            appState: appState,
            wearableStreamService: fakeWearableService,
          ),
        ),
      ),
    );

    await tester.tap(find.text(strings.startWearableStream));
    await tester.pump();

    expect(fakeWearableService.started, isTrue);
    expect(find.text(strings.wearableStreamStarted), findsOneWidget);

    fakeWearableService.emit(
      ExternalHeartRateReading(
        bpm: 137,
        timestamp: DateTime.utc(2026, 1, 1, 10, 10),
        source: 'test_wearable',
      ),
    );
    await tester.pump();

    expect(appState.activeSession!.heartRateSamples, hasLength(1));
    expect(appState.activeSession!.heartRateSamples.single.bpm, 137);
  });
}

AppState _buildAppState() {
  final exercise = Exercise(
    id: 'exercise-stream-test',
    name: 'Press militar',
    muscleGroup: 'Hombros',
    isCustom: false,
    createdAt: DateTime.utc(2026, 1, 1),
  );

  return AppState(
    profileRepository: _MemoryProfileRepository(),
    exerciseRepository: _MemoryExerciseRepository([exercise]),
    workoutRepository: _MemoryWorkoutRepository(),
    settingsRepository: _MemorySettingsRepository(),
    socialRepository: _MemorySocialRepository(),
    socialAuthService: _MemorySocialAuthService(),
  );
}

class _FakeWearableHeartRateStreamService extends WearableHeartRateStreamService {
  final _controller = StreamController<ExternalHeartRateReading>.broadcast();
  bool started = false;

  @override
  bool get isSupported => true;

  @override
  Future<WearableHeartRateStartResult> start({
    required DateTime startedAt,
  }) async {
    started = true;
    return const WearableHeartRateStartResult.success();
  }

  @override
  Stream<ExternalHeartRateReading> stream({required DateTime startedAt}) {
    return _controller.stream;
  }

  @override
  Future<void> stop() async {
    return;
  }

  void emit(ExternalHeartRateReading reading) {
    _controller.add(reading);
  }
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
  @override
  Future<Map<String, String>> loadAvatarOverrides() async => const {};

  @override
  Future<Set<String>> loadDismissedIncomingRequestIds() async => const {};

  @override
  Future<Set<String>> loadFollowingIds() async => const {};

  @override
  Future<void> saveAvatarOverrides(Map<String, String> overrides) async {}

  @override
  Future<void> saveDismissedIncomingRequestIds(Set<String> ids) async {}

  @override
  Future<void> saveFollowingIds(Set<String> ids) async {}
}

class _MemorySocialAuthService implements SocialAuthService {
  @override
  Future<SocialAuthAccount?> restoreSession() async => null;

  @override
  Future<SocialAuthResult> signInWithApple() async =>
      SocialAuthResult.unsupported();

  @override
  Future<SocialAuthResult> signInWithGoogle() async =>
      SocialAuthResult.unsupported();

  @override
  Future<void> signOut() async {}
}
