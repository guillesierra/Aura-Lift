import 'package:flutter/material.dart';

import '../auth/social_auth_service.dart';
import '../audio/exercise_technique_tip_builder.dart';
import '../catalog/exercise_taxonomy.dart';
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
import '../models/social_profile.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/social_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/workout_repository.dart';
import '../social/social_seed.dart';
import '../metrics/aura_points_estimator.dart';
import '../workout/workout_csv_codec.dart';

class AppState extends ChangeNotifier {
  AppState({
    required ProfileRepository profileRepository,
    required ExerciseRepository exerciseRepository,
    required WorkoutRepository workoutRepository,
    required SettingsRepository settingsRepository,
    required SocialRepository socialRepository,
    required SocialAuthService socialAuthService,
  })  : _profileRepository = profileRepository,
        _exerciseRepository = exerciseRepository,
        _workoutRepository = workoutRepository,
        _settingsRepository = settingsRepository,
        _socialRepository = socialRepository,
        _socialAuthService = socialAuthService;

  final ProfileRepository _profileRepository;
  final ExerciseRepository _exerciseRepository;
  final WorkoutRepository _workoutRepository;
  final SettingsRepository _settingsRepository;
  final SocialRepository _socialRepository;
  final SocialAuthService _socialAuthService;

  UserProfile? _profile;
  List<Exercise> _exercises = const [];
  List<WorkoutSession> _sessions = const [];
  AppSettings _settings = AppSettings.defaults;
  bool _isBootstrapped = false;
  HeartRateCoachCue? _pendingHeartRateCoachCue;
  String? _pendingExerciseTechniqueTip;
  bool _effortCueTriggered = false;
  final Map<String, DateTime> _lastTechniqueTipAtByExerciseId = {};
  List<SocialProfile> _communityProfiles = const [];
  Map<String, List<WorkoutSession>> _communitySessionsByProfileId = const {};
  Set<String> _followingProfileIds = <String>{};
  Map<String, String> _communityAvatarOverrides = const {};
  Set<String> _dismissedIncomingRequestIds = <String>{};
  SocialAuthAccount? _authAccount;

  UserProfile? get profile => _profile;
  List<Exercise> get exercises => _exercises;
  List<WorkoutSession> get sessions => _sessions;
  AppSettings get settings => _settings;
  ThemeMode get themeMode => _settings.themeMode;
  String get languageCode => _settings.languageCode;
  bool get menuAnimationsEnabled => _settings.enableMenuAnimations;
  bool get isBootstrapped => _isBootstrapped;
  SocialAuthAccount? get authAccount => _authAccount;
  HeartRateCoachCue? get pendingHeartRateCoachCue => _pendingHeartRateCoachCue;
  String? get pendingExerciseTechniqueTip => _pendingExerciseTechniqueTip;
  List<SocialProfile> get communityProfiles => _resolvedCommunityProfiles();
  List<SocialProfile> get followingProfiles => _resolvedCommunityProfiles()
      .where((profile) => _followingProfileIds.contains(profile.id))
      .toList(growable: false);
  List<SocialProfile> get friendProfiles => _resolvedCommunityProfiles()
      .where(
        (profile) =>
            _followingProfileIds.contains(profile.id) && profile.followsMe,
      )
      .toList(growable: false);
  List<SocialProfile> get incomingRequestProfiles =>
      _resolvedCommunityProfiles()
          .where(
            (profile) =>
                profile.followsMe &&
                !_followingProfileIds.contains(profile.id) &&
                !_dismissedIncomingRequestIds.contains(profile.id),
          )
          .toList(growable: false);
  List<SocialProfile> get outgoingRequestProfiles =>
      _resolvedCommunityProfiles()
          .where(
            (profile) =>
                _followingProfileIds.contains(profile.id) && !profile.followsMe,
          )
          .toList(growable: false);
  int get pendingIncomingRequestsCount => incomingRequestProfiles.length;
  List<String> get availableMuscleGroups {
    final groups = _exercises.map((item) => item.muscleGroup).toSet().toList();
    groups.sort();
    return groups;
  }

  List<String> get availableEquipment {
    final equipment = _exercises.map((item) => item.equipment).toSet().toList();
    equipment.sort();
    return equipment;
  }

  List<String> get canonicalMuscleGroups => ExerciseTaxonomy.muscleGroups;
  List<String> get canonicalEquipmentTypes => ExerciseTaxonomy.equipmentTypes;
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
    _communityProfiles = SocialSeed.profiles;
    _communitySessionsByProfileId = SocialSeed.sessionsByProfileId();
    _authAccount = await _socialAuthService.restoreSession();
    if (_authAccount != null) {
      await _applyAuthAccountToProfile(_authAccount!);
    }
    final persistedFollowing = await _socialRepository.loadFollowingIds();
    _communityAvatarOverrides = await _socialRepository.loadAvatarOverrides();
    _dismissedIncomingRequestIds =
        await _socialRepository.loadDismissedIncomingRequestIds();
    _followingProfileIds = persistedFollowing.isEmpty
        ? Set<String>.from(SocialSeed.initialFollowingIds)
        : persistedFollowing;
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
    required String presentation,
    required String city,
    required String gym,
    String? avatarUrl,
    bool keepAvatarUrl = true,
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
      avatarUrl: keepAvatarUrl ? (avatarUrl ?? current.avatarUrl) : null,
      presentation: presentation.trim(),
      city: city.trim(),
      gym: gym.trim(),
      createdAt: current.createdAt,
      updatedAt: DateTime.now().toUtc(),
    );
    await _profileRepository.save(updated);
    _profile = updated;
    notifyListeners();
  }

  Future<void> updateProfileAvatar(String? avatarUrl) async {
    final current = _profile;
    if (current == null) {
      return;
    }

    await updateProfile(
      name: current.name,
      heightCm: current.heightCm,
      weightKg: current.weightKg,
      bodyType: current.bodyType,
      presentation: current.presentation,
      city: current.city,
      gym: current.gym,
      avatarUrl: avatarUrl,
      keepAvatarUrl: avatarUrl != null,
    );
  }

  Future<SocialAuthResult> signInWithGoogle() async {
    final result = await _socialAuthService.signInWithGoogle();
    if (result.account != null) {
      _authAccount = result.account;
      await _applyAuthAccountToProfile(result.account!);
      notifyListeners();
    }
    return result;
  }

  Future<SocialAuthResult> signInWithApple() async {
    final result = await _socialAuthService.signInWithApple();
    if (result.account != null) {
      _authAccount = result.account;
      await _applyAuthAccountToProfile(result.account!);
      notifyListeners();
    }
    return result;
  }

  Future<void> signOutSocialAuth() async {
    await _socialAuthService.signOut();
    _authAccount = null;
    notifyListeners();
  }

  String exportWorkoutsAsCsv() {
    final finished = _sessions.where((session) => !session.isActive).toList(
          growable: false,
        )..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return WorkoutCsvCodec.encode(finished);
  }

  Future<WorkoutCsvImportReport> importWorkoutsFromCsv(
    String rawCsv, {
    bool replaceExisting = false,
  }) async {
    final decoded = WorkoutCsvCodec.decode(rawCsv);
    if (decoded.sessions.isEmpty) {
      return decoded.report;
    }

    final incomingIds = decoded.sessions.map((session) => session.id).toSet();
    final keptSessions = replaceExisting
        ? <WorkoutSession>[]
        : _sessions
            .where((session) => !incomingIds.contains(session.id))
            .toList(growable: false);

    _sessions = [...keptSessions, ...decoded.sessions]
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
    await _persistSessions();
    return decoded.report;
  }

  bool isFollowingProfile(String profileId) {
    return _followingProfileIds.contains(profileId);
  }

  SocialConnectionStatus connectionStatusFor(String profileId) {
    final profile = socialProfileById(profileId);
    if (profile == null) {
      return SocialConnectionStatus.notFollowing;
    }
    final following = _followingProfileIds.contains(profileId);
    if (following && profile.followsMe) {
      return SocialConnectionStatus.friends;
    }
    if (following && !profile.followsMe) {
      return SocialConnectionStatus.requestSent;
    }
    if (!following && profile.followsMe) {
      return SocialConnectionStatus.requestReceived;
    }
    return SocialConnectionStatus.notFollowing;
  }

  Future<void> followProfile(String profileId) async {
    if (_followingProfileIds.contains(profileId)) {
      return;
    }
    _followingProfileIds = {..._followingProfileIds, profileId};
    if (_dismissedIncomingRequestIds.contains(profileId)) {
      _dismissedIncomingRequestIds = {..._dismissedIncomingRequestIds}
        ..remove(profileId);
      await _socialRepository.saveDismissedIncomingRequestIds(
        _dismissedIncomingRequestIds,
      );
    }
    await _socialRepository.saveFollowingIds(_followingProfileIds);
    notifyListeners();
  }

  Future<void> unfollowProfile(String profileId) async {
    if (!_followingProfileIds.contains(profileId)) {
      return;
    }
    _followingProfileIds = {..._followingProfileIds}..remove(profileId);
    await _socialRepository.saveFollowingIds(_followingProfileIds);
    notifyListeners();
  }

  Future<void> declineIncomingRequest(String profileId) async {
    if (_dismissedIncomingRequestIds.contains(profileId)) {
      return;
    }
    _dismissedIncomingRequestIds = {..._dismissedIncomingRequestIds, profileId};
    await _socialRepository.saveDismissedIncomingRequestIds(
      _dismissedIncomingRequestIds,
    );
    notifyListeners();
  }

  Future<void> acceptIncomingRequest(String profileId) async {
    await followProfile(profileId);
  }

  Future<void> toggleFollowProfile(String profileId) async {
    if (_followingProfileIds.contains(profileId)) {
      await unfollowProfile(profileId);
      return;
    }
    await followProfile(profileId);
  }

  List<SocialProfile> searchCommunityProfiles(String query) {
    final normalized = query.trim().toLowerCase();
    final profiles = _resolvedCommunityProfiles();
    if (normalized.isEmpty) {
      return profiles;
    }
    return profiles.where((profile) {
      return profile.name.toLowerCase().contains(normalized) ||
          profile.handle.toLowerCase().contains(normalized) ||
          (profile.bio?.toLowerCase().contains(normalized) ?? false);
    }).toList(growable: false);
  }

  SocialProfile? socialProfileById(String profileId) {
    for (final profile in _resolvedCommunityProfiles()) {
      if (profile.id == profileId) {
        return profile;
      }
    }
    return null;
  }

  Future<void> updateCommunityProfileAvatar({
    required String profileId,
    required String avatarUrl,
  }) async {
    final updated = Map<String, String>.from(_communityAvatarOverrides)
      ..[profileId] = avatarUrl;
    _communityAvatarOverrides = updated;
    await _socialRepository.saveAvatarOverrides(updated);
    notifyListeners();
  }

  Future<void> clearCommunityProfileAvatar(String profileId) async {
    if (!_communityAvatarOverrides.containsKey(profileId)) {
      return;
    }
    final updated = Map<String, String>.from(_communityAvatarOverrides)
      ..remove(profileId);
    _communityAvatarOverrides = updated;
    await _socialRepository.saveAvatarOverrides(updated);
    notifyListeners();
  }

  List<WorkoutSession> socialCompletedSessionsFor(String profileId) {
    final sessions = _communitySessionsByProfileId[profileId] ?? const [];
    return sessions
        .where((session) => !session.isActive)
        .toList(growable: false)
      ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
  }

  List<SocialFeedItem> homeFeedItems() {
    final myProfile = _profile;
    final items = <SocialFeedItem>[];
    if (myProfile != null) {
      final mine = _sessions.where((session) => !session.isActive);
      for (final session in mine) {
        items.add(
          SocialFeedItem(
            profileId: myProfile.id,
            authorName: myProfile.name,
            authorHandle: myProfile.name.toLowerCase().replaceAll(' ', '_'),
            authorAvatarUrl: myProfile.avatarUrl,
            isCurrentUser: true,
            session: session,
          ),
        );
      }
    }

    for (final profileId in _followingProfileIds) {
      final profile = socialProfileById(profileId);
      if (profile == null) {
        continue;
      }
      final sessions = _communitySessionsByProfileId[profileId] ?? const [];
      for (final session in sessions.where((entry) => !entry.isActive)) {
        items.add(
          SocialFeedItem(
            profileId: profile.id,
            authorName: profile.name,
            authorHandle: profile.handle,
            authorAvatarUrl: profile.avatarUrl,
            isCurrentUser: false,
            session: session,
          ),
        );
      }
    }

    items.sort((a, b) => b.session.startedAt.compareTo(a.session.startedAt));
    return items;
  }

  ProfileComparison? compareWithProfile(String profileId) {
    final myProfile = _profile;
    final other = socialProfileById(profileId);
    if (myProfile == null || other == null) {
      return null;
    }

    final mySessions =
        _sessions.where((session) => !session.isActive).toList(growable: false);
    final otherSessions = socialCompletedSessionsFor(profileId);

    final myStats = _statsFromSessions(mySessions);
    final otherStats = _statsFromSessions(otherSessions);
    final myBestByExercise = _bestWeightByExerciseName(mySessions);
    final otherBestByExercise = _bestWeightByExerciseName(otherSessions);
    final sharedExerciseNames = myBestByExercise.keys
        .where((name) => otherBestByExercise.containsKey(name))
        .toList(growable: false)
      ..sort();

    final shared = sharedExerciseNames.map((name) {
      return SharedExerciseRecord(
        exerciseName: name,
        myBestWeight: myBestByExercise[name] ?? 0,
        otherBestWeight: otherBestByExercise[name] ?? 0,
      );
    }).toList(growable: false);

    return ProfileComparison(
      myProfile: myProfile,
      otherProfile: other,
      myStats: myStats,
      otherStats: otherStats,
      sharedExerciseRecords: shared,
    );
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

    _queueTechniqueTipForExercise(
      sessionExercise,
      force: true,
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

      final remainingSets =
          exercise.sets.where((set) => set.id != setId).toList(growable: false);
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
        selectedExerciseId:
            current.selectedExerciseId == deletedExercise.exerciseId
                ? null
                : current.selectedExerciseId,
        keepSelectedExerciseId:
            current.selectedExerciseId != deletedExercise.exerciseId,
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

    if (current.selectedExerciseId == exerciseId) {
      return;
    }

    final selectedExercise = current.exercises.firstWhere(
      (exercise) => exercise.exerciseId == exerciseId,
    );
    _queueTechniqueTipForExercise(selectedExercise);

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
    String? equipment,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    String? difficulty,
    String? imageAssetPath,
    String? imagePrompt,
  }) async {
    await _exerciseRepository.addCustomExercise(
      name: name,
      muscleGroup: muscleGroup,
      equipment: equipment,
      primaryMuscles: primaryMuscles,
      secondaryMuscles: secondaryMuscles,
      difficulty: difficulty,
      imageAssetPath: imageAssetPath,
      imagePrompt: imagePrompt,
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

  String? consumePendingExerciseTechniqueTip() {
    final tip = _pendingExerciseTechniqueTip;
    _pendingExerciseTechniqueTip = null;
    return tip;
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

  Future<void> updateMenuAnimationsEnabled(bool enabled) async {
    _settings = _settings.copyWith(enableMenuAnimations: enabled);
    await _settingsRepository.save(_settings);
    notifyListeners();
  }

  int auraPointsForSession(
    WorkoutSession session, {
    double? bodyWeightKg,
  }) {
    final resolvedBodyWeight = bodyWeightKg ?? _profile?.weightKg ?? 70;
    return AuraPointsEstimator.estimateWorkoutPoints(
      session: session,
      bodyWeightKg: resolvedBodyWeight,
    );
  }

  int totalAuraPoints({
    double? bodyWeightKg,
  }) {
    final completed = _sessions.where((session) => !session.isActive);
    return completed.fold<int>(
      0,
      (sum, session) =>
          sum +
          auraPointsForSession(
            session,
            bodyWeightKg: bodyWeightKg,
          ),
    );
  }

  int annualAuraPoints({
    required int year,
    double? bodyWeightKg,
  }) {
    final completed = _sessions.where(
      (session) =>
          !session.isActive && session.startedAt.toLocal().year == year,
    );
    return completed.fold<int>(
      0,
      (sum, session) =>
          sum +
          auraPointsForSession(
            session,
            bodyWeightKg: bodyWeightKg,
          ),
    );
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
          bestWeight:
              bestWeight > current.bestWeight ? bestWeight : current.bestWeight,
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
    _sessions = _sessions.map((session) {
      if (session.id == updatedSession.id) {
        return updatedSession;
      }
      return session;
    }).toList(growable: false);
    await _persistSessions();
  }

  Future<void> _persistSessions() async {
    await _workoutRepository.saveSessions(_sessions);
    notifyListeners();
  }

  Future<void> _applyAuthAccountToProfile(SocialAuthAccount account) async {
    final current = _profile;
    if (current == null) {
      return;
    }

    final nextName = (account.displayName ?? '').trim().isEmpty
        ? current.name
        : account.displayName!.trim();
    final nextAvatar = (account.photoUrl ?? '').trim().isEmpty
        ? current.avatarUrl
        : account.photoUrl!.trim();

    await updateProfile(
      name: nextName,
      heightCm: current.heightCm,
      weightKg: current.weightKg,
      bodyType: current.bodyType,
      presentation: current.presentation,
      city: current.city,
      gym: current.gym,
      avatarUrl: nextAvatar,
    );
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
    return (baseline * 1.05).round();
  }

  void _resetHeartRateCoaching() {
    _pendingHeartRateCoachCue = null;
    _pendingExerciseTechniqueTip = null;
    _lastTechniqueTipAtByExerciseId.clear();
    _effortCueTriggered = false;
  }

  void _queueTechniqueTipForExercise(
    SessionExercise exercise, {
    bool force = false,
  }) {
    final now = DateTime.now().toUtc();
    if (!force) {
      final lastTipAt = _lastTechniqueTipAtByExerciseId[exercise.exerciseId];
      if (lastTipAt != null) {
        final elapsed = now.difference(lastTipAt);
        if (elapsed < const Duration(seconds: 75)) {
          return;
        }
      }
    }

    _pendingExerciseTechniqueTip = ExerciseTechniqueTipBuilder.tipFor(
      exerciseName: exercise.exerciseName,
      muscleGroup: exercise.muscleGroup,
      languageCode: _settings.languageCode,
    );
    _lastTechniqueTipAtByExerciseId[exercise.exerciseId] = now;
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

  TrainingStats _statsFromSessions(List<WorkoutSession> sessions) {
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration.inMinutes,
    );
    final totalVolume = sessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );

    double topSingleLift = 0;
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        for (final set in exercise.sets) {
          if (set.weightKg > topSingleLift) {
            topSingleLift = set.weightKg;
          }
        }
      }
    }

    return TrainingStats(
      sessionsCount: sessions.length,
      totalMinutes: totalMinutes,
      totalVolume: totalVolume,
      topSingleLift: topSingleLift,
    );
  }

  Map<String, double> _bestWeightByExerciseName(List<WorkoutSession> sessions) {
    final map = <String, double>{};
    for (final session in sessions) {
      for (final exercise in session.exercises) {
        final key = exercise.exerciseName.trim().toLowerCase();
        final currentBest = map[key] ?? 0;
        final exerciseBest = exercise.sets.fold<double>(
          0,
          (maxValue, set) => set.weightKg > maxValue ? set.weightKg : maxValue,
        );
        if (exerciseBest > currentBest) {
          map[key] = exerciseBest;
        }
      }
    }
    return map;
  }

  List<SocialProfile> _resolvedCommunityProfiles() {
    return _communityProfiles.map((profile) {
      final override = _communityAvatarOverrides[profile.id];
      if (override == null || override.isEmpty) {
        return profile;
      }
      return profile.copyWith(avatarUrl: override);
    }).toList(growable: false);
  }
}

enum SocialConnectionStatus {
  notFollowing,
  requestSent,
  requestReceived,
  friends,
}

class SocialFeedItem {
  const SocialFeedItem({
    required this.profileId,
    required this.authorName,
    required this.authorHandle,
    required this.authorAvatarUrl,
    required this.isCurrentUser,
    required this.session,
  });

  final String profileId;
  final String authorName;
  final String authorHandle;
  final String? authorAvatarUrl;
  final bool isCurrentUser;
  final WorkoutSession session;
}

class ProfileComparison {
  const ProfileComparison({
    required this.myProfile,
    required this.otherProfile,
    required this.myStats,
    required this.otherStats,
    required this.sharedExerciseRecords,
  });

  final UserProfile myProfile;
  final SocialProfile otherProfile;
  final TrainingStats myStats;
  final TrainingStats otherStats;
  final List<SharedExerciseRecord> sharedExerciseRecords;
}

class TrainingStats {
  const TrainingStats({
    required this.sessionsCount,
    required this.totalMinutes,
    required this.totalVolume,
    required this.topSingleLift,
  });

  final int sessionsCount;
  final int totalMinutes;
  final double totalVolume;
  final double topSingleLift;
}

class SharedExerciseRecord {
  const SharedExerciseRecord({
    required this.exerciseName,
    required this.myBestWeight,
    required this.otherBestWeight,
  });

  final String exerciseName;
  final double myBestWeight;
  final double otherBestWeight;
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
