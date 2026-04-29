// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../catalog/exercise_taxonomy.dart';
import '../models/app_settings.dart';
import '../models/body_type.dart';
import '../models/exercise.dart';
import '../models/exercise_set.dart';
import '../models/heart_rate_sample.dart';
import '../models/session_exercise.dart';
import '../models/user_profile.dart';
import '../models/workout_session.dart';
import '../repositories/exercise_repository.dart';
import '../repositories/profile_repository.dart';
import '../repositories/settings_repository.dart';
import '../repositories/social_repository.dart';
import '../repositories/workout_repository.dart';
import '../social/social_seed.dart';

class DemoProfileRepository implements ProfileRepository {
  UserProfile _profile = DemoData.profile;

  @override
  Future<UserProfile?> load() async => _profile;

  @override
  Future<void> save(UserProfile profile) async {
    _profile = profile;
  }
}

class DemoWorkoutRepository implements WorkoutRepository {
  DemoWorkoutRepository() : _sessions = DemoData.sessions();

  List<WorkoutSession> _sessions;

  @override
  Future<List<WorkoutSession>> loadSessions() async => _sessions;

  @override
  Future<void> saveSessions(List<WorkoutSession> sessions) async {
    _sessions = sessions;
  }
}

class DemoSettingsRepository implements SettingsRepository {
  AppSettings _settings = const AppSettings(
    themeMode: ThemeMode.light,
    languageCode: 'es',
    enableMenuAnimations: true,
    appearance: AppAppearance.classic,
  );

  @override
  Future<AppSettings> load() async => _settings;

  @override
  Future<void> save(AppSettings settings) async {
    _settings = settings;
  }
}

class DemoSocialRepository implements SocialRepository {
  Set<String> _following = Set<String>.from(SocialSeed.initialFollowingIds);
  Map<String, String> _avatarOverrides = {};
  Set<String> _dismissedIncoming = <String>{};

  @override
  Future<Set<String>> loadFollowingIds() async => _following;

  @override
  Future<void> saveFollowingIds(Set<String> ids) async {
    _following = Set<String>.from(ids);
  }

  @override
  Future<Map<String, String>> loadAvatarOverrides() async {
    return _avatarOverrides;
  }

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

class DemoExerciseRepository implements ExerciseRepository {
  List<Exercise>? _exercises;

  @override
  Future<List<Exercise>> loadExercises() async {
    final cached = _exercises;
    if (cached != null) {
      return cached;
    }

    final seed = await rootBundle.loadString('assets/seed/exercises_seed.json');
    final parsed = jsonDecode(seed) as List<dynamic>;
    _exercises = parsed
        .map((item) => Exercise.fromMap(item as Map<String, dynamic>))
        .toList(growable: false);
    return _exercises!;
  }

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
  }) async {
    final current = await loadExercises();
    final normalizedMuscleGroup =
        ExerciseTaxonomy.canonicalMuscleGroup(muscleGroup);
    final normalizedEquipment = ExerciseTaxonomy.canonicalEquipment(
      equipment ?? ExerciseTaxonomy.inferEquipmentFromName(name),
    );
    final normalizedPrimary = primaryMuscles == null || primaryMuscles.isEmpty
        ? ExerciseTaxonomy.inferPrimaryMuscles(normalizedMuscleGroup)
        : primaryMuscles;
    _exercises = [
      ...current,
      Exercise(
        id: 'demo-custom-${DateTime.now().microsecondsSinceEpoch}',
        name: name.trim(),
        muscleGroup: normalizedMuscleGroup,
        equipment: normalizedEquipment,
        primaryMuscles: normalizedPrimary,
        secondaryMuscles: secondaryMuscles ?? const [],
        difficulty: difficulty ?? ExerciseTaxonomy.inferDifficulty(name),
        imageAssetPath: imageAssetPath,
        imagePrompt: imagePrompt ??
            ExerciseTaxonomy.imagePrompt(
              name: name,
              muscleGroup: normalizedMuscleGroup,
              equipment: normalizedEquipment,
              primaryMuscles: normalizedPrimary,
            ),
        isCustom: true,
        createdAt: DateTime.now().toUtc(),
      ),
    ];
  }
}

class DemoData {
  const DemoData._();

  static UserProfile get profile {
    final now = DateTime.now().toUtc();
    return UserProfile(
      id: 'demo-profile',
      name: 'Guille',
      heightCm: 178,
      weightKg: 78,
      bodyType: BodyType.athletic,
      avatarUrl: 'https://i.pravatar.cc/200?img=12',
      presentation:
          'Entreno 5 dias por semana, priorizo tecnica, control de cargas y progresion limpia.',
      city: 'Valencia',
      gym: 'Athletica Club',
      createdAt: now.subtract(const Duration(days: 90)),
      updatedAt: now,
    );
  }

  static List<WorkoutSession> sessions() {
    final now = DateTime.now().toUtc();
    final blueprints = <_WorkoutBlueprint>[
      _WorkoutBlueprint(
        title: 'Push fuerza',
        daysAgo: 1,
        durationMinutes: 72,
        bpmBase: 94,
        bpmPeak: 166,
        exercises: [
          _ExercisePlan(
              _ExerciseRef.benchPress, [8, 6, 6, 5], [82.5, 87.5, 90, 92.5]),
          _ExercisePlan(
              _ExerciseRef.inclineDumbbell, [10, 9, 8], [30, 32.5, 32.5]),
          _ExercisePlan(_ExerciseRef.lateralRaise, [14, 13, 12], [10, 10, 12]),
          _ExercisePlan(_ExerciseRef.tricepsRope, [12, 11, 10], [30, 32.5, 35]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Full body tecnico',
        daysAgo: 2,
        durationMinutes: 56,
        bpmBase: 88,
        bpmPeak: 152,
        exercises: [
          _ExercisePlan(_ExerciseRef.benchPress, [10, 9, 8], [65, 70, 72.5]),
          _ExercisePlan(_ExerciseRef.frontSquat, [8, 8, 6], [75, 80, 82.5]),
          _ExercisePlan(_ExerciseRef.latPulldown, [12, 10, 10], [60, 65, 65]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Condicionamiento corto',
        daysAgo: 4,
        durationMinutes: 34,
        bpmBase: 96,
        bpmPeak: 164,
        exercises: [
          _ExercisePlan(_ExerciseRef.bike, [1, 1, 1], [0, 0, 0]),
          _ExercisePlan(_ExerciseRef.walkingLunge, [14, 14, 12], [18, 20, 20]),
          _ExercisePlan(_ExerciseRef.plank, [1, 1, 1], [0, 0, 0]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Pierna volumen',
        daysAgo: 3,
        durationMinutes: 86,
        bpmBase: 98,
        bpmPeak: 174,
        exercises: [
          _ExercisePlan(
              _ExerciseRef.backSquat, [8, 8, 6, 6], [105, 110, 115, 117.5]),
          _ExercisePlan(_ExerciseRef.legPress, [12, 11, 10], [210, 230, 240]),
          _ExercisePlan(
              _ExerciseRef.romanianDeadlift, [10, 9, 8], [95, 100, 105]),
          _ExercisePlan(_ExerciseRef.calfRaise, [16, 15, 14], [75, 80, 82.5]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Pull hipertrofia',
        daysAgo: 6,
        durationMinutes: 69,
        bpmBase: 89,
        bpmPeak: 154,
        exercises: [
          _ExercisePlan(_ExerciseRef.pullUps, [8, 7, 6], [0, 0, 0]),
          _ExercisePlan(
              _ExerciseRef.barbellRow, [10, 9, 8, 8], [70, 72.5, 75, 75]),
          _ExercisePlan(
              _ExerciseRef.lowCableRow, [12, 11, 10], [62.5, 65, 67.5]),
          _ExercisePlan(_ExerciseRef.hammerCurl, [12, 11, 10], [16, 18, 18]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Cardio controlado',
        daysAgo: 8,
        durationMinutes: 42,
        bpmBase: 102,
        bpmPeak: 148,
        exercises: [
          _ExercisePlan(_ExerciseRef.treadmill, [1, 1, 1], [0, 0, 0]),
          _ExercisePlan(_ExerciseRef.bike, [1, 1], [0, 0]),
          _ExercisePlan(_ExerciseRef.plank, [1, 1, 1], [0, 0, 0]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Torso mixto',
        daysAgo: 10,
        durationMinutes: 75,
        bpmBase: 92,
        bpmPeak: 159,
        exercises: [
          _ExercisePlan(
              _ExerciseRef.inclineDumbbell, [10, 10, 8], [30, 30, 32.5]),
          _ExercisePlan(_ExerciseRef.latPulldown, [12, 10, 10], [65, 70, 70]),
          _ExercisePlan(_ExerciseRef.shoulderPress, [9, 8, 7], [45, 47.5, 50]),
          _ExercisePlan(_ExerciseRef.ezCurl, [12, 11, 10], [30, 32.5, 32.5]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Pierna tecnico',
        daysAgo: 13,
        durationMinutes: 64,
        bpmBase: 90,
        bpmPeak: 151,
        exercises: [
          _ExercisePlan(_ExerciseRef.frontSquat, [8, 8, 8], [80, 82.5, 85]),
          _ExercisePlan(
              _ExerciseRef.bulgarianSplitSquat, [10, 9, 8], [24, 26, 26]),
          _ExercisePlan(
              _ExerciseRef.legExtension, [14, 13, 12], [55, 57.5, 60]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Full body denso',
        daysAgo: 16,
        durationMinutes: 78,
        bpmBase: 96,
        bpmPeak: 168,
        exercises: [
          _ExercisePlan(_ExerciseRef.deadlift, [5, 5, 4], [135, 142.5, 150]),
          _ExercisePlan(_ExerciseRef.benchPress, [8, 7, 6], [80, 82.5, 85]),
          _ExercisePlan(_ExerciseRef.pullUps, [8, 7, 6], [0, 0, 0]),
          _ExercisePlan(_ExerciseRef.walkingLunge, [12, 12, 10], [22, 24, 24]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Hombro y brazos',
        daysAgo: 20,
        durationMinutes: 58,
        bpmBase: 86,
        bpmPeak: 142,
        exercises: [
          _ExercisePlan(
              _ExerciseRef.shoulderPress, [10, 9, 8], [42.5, 45, 47.5]),
          _ExercisePlan(
              _ExerciseRef.lateralRaise, [15, 14, 12, 12], [8, 10, 10, 10]),
          _ExercisePlan(_ExerciseRef.ezCurl, [12, 10, 9], [30, 32.5, 35]),
          _ExercisePlan(
              _ExerciseRef.tricepsRope, [13, 12, 11], [27.5, 30, 32.5]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Espalda pesado',
        daysAgo: 24,
        durationMinutes: 82,
        bpmBase: 93,
        bpmPeak: 162,
        exercises: [
          _ExercisePlan(_ExerciseRef.deadlift, [5, 4, 3], [130, 140, 147.5]),
          _ExercisePlan(_ExerciseRef.barbellRow, [8, 8, 7], [70, 72.5, 75]),
          _ExercisePlan(
              _ExerciseRef.latPulldown, [10, 10, 9], [67.5, 70, 72.5]),
          _ExercisePlan(_ExerciseRef.hammerCurl, [12, 10, 10], [16, 18, 18]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Core y movilidad',
        daysAgo: 28,
        durationMinutes: 38,
        bpmBase: 82,
        bpmPeak: 128,
        exercises: [
          _ExercisePlan(_ExerciseRef.plank, [1, 1, 1], [0, 0, 0]),
          _ExercisePlan(_ExerciseRef.hangingLegRaise, [12, 10, 10], [0, 0, 0]),
          _ExercisePlan(
              _ExerciseRef.pallofPress, [12, 12, 12], [17.5, 17.5, 20]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Push base',
        daysAgo: 32,
        durationMinutes: 66,
        bpmBase: 90,
        bpmPeak: 150,
        exercises: [
          _ExercisePlan(_ExerciseRef.benchPress, [8, 8, 7], [75, 77.5, 80]),
          _ExercisePlan(_ExerciseRef.inclineDumbbell, [10, 9, 8], [28, 30, 30]),
          _ExercisePlan(_ExerciseRef.tricepsRope, [12, 12, 10], [27.5, 30, 30]),
        ],
      ),
      _WorkoutBlueprint(
        title: 'Pierna base',
        daysAgo: 36,
        durationMinutes: 73,
        bpmBase: 94,
        bpmPeak: 160,
        exercises: [
          _ExercisePlan(_ExerciseRef.backSquat, [8, 7, 6], [95, 100, 105]),
          _ExercisePlan(_ExerciseRef.legPress, [12, 10, 10], [200, 220, 230]),
          _ExercisePlan(_ExerciseRef.calfRaise, [15, 14, 12], [70, 75, 75]),
        ],
      ),
    ];

    final completed = <WorkoutSession>[];
    var sessionIndex = 0;
    for (var cycle = 0; cycle < 4; cycle += 1) {
      for (final entry in blueprints.asMap().entries) {
        final base = entry.value;
        final blueprint = _scaledBlueprint(base, cycle);
        final startedAt = DateTime.utc(
          now.year,
          now.month,
          now.day,
          18 - ((entry.key + cycle) % 3),
          15 + ((entry.key + cycle) * 7) % 35,
        ).subtract(Duration(days: base.daysAgo + cycle * 42 + entry.key));
        completed.add(
          _sessionFromBlueprint(
            index: sessionIndex,
            blueprint: blueprint,
            startedAt: startedAt,
            isActive: false,
          ),
        );
        sessionIndex += 1;
      }
    }

    final activeStart = now.subtract(const Duration(minutes: 38));
    final active = _sessionFromBlueprint(
      index: sessionIndex,
      blueprint: _WorkoutBlueprint(
        title: 'Sesion activa demo',
        daysAgo: 0,
        durationMinutes: 55,
        bpmBase: 92,
        bpmPeak: 152,
        exercises: [
          _ExercisePlan(
              _ExerciseRef.latPulldown, [12, 10, 0], [67.5, 70, 72.5]),
          _ExercisePlan(_ExerciseRef.lowCableRow, [11, 10], [65, 67.5]),
          _ExercisePlan(_ExerciseRef.hammerCurl, [12], [18]),
        ],
      ),
      startedAt: activeStart,
      isActive: true,
    );

    return [...completed, active];
  }

  static _WorkoutBlueprint _scaledBlueprint(
    _WorkoutBlueprint base,
    int cycle,
  ) {
    if (cycle == 0) {
      return base;
    }

    return _WorkoutBlueprint(
      title: '${base.title} · B${cycle + 1}',
      daysAgo: base.daysAgo,
      durationMinutes: base.durationMinutes + cycle,
      bpmBase: base.bpmBase + cycle,
      bpmPeak: base.bpmPeak + cycle,
      exercises: base.exercises
          .map(
            (plan) => _ExercisePlan(
              plan.ref,
              plan.reps,
              plan.weightsKg
                  .map((weight) => weight + (cycle * 2.5))
                  .toList(growable: false),
            ),
          )
          .toList(growable: false),
    );
  }

  static WorkoutSession _sessionFromBlueprint({
    required int index,
    required _WorkoutBlueprint blueprint,
    required DateTime startedAt,
    required bool isActive,
  }) {
    final exercises = blueprint.exercises.asMap().entries.map((entry) {
      final plan = entry.value;
      final exerciseStartedAt =
          startedAt.add(Duration(minutes: 8 + entry.key * 13));
      return SessionExercise(
        id: 'demo-session-$index-exercise-${entry.key}',
        exerciseId: plan.ref.id,
        exerciseName: plan.ref.name,
        muscleGroup: plan.ref.muscleGroup,
        orderIndex: entry.key,
        startedAt: exerciseStartedAt,
        sets: plan.reps.asMap().entries.where((setEntry) {
          return setEntry.value > 0;
        }).map((setEntry) {
          final setIndex = setEntry.key;
          return ExerciseSet(
            id: 'demo-session-$index-exercise-${entry.key}-set-$setIndex',
            reps: setEntry.value,
            weightKg: plan.weightsKg[setIndex],
            completedAt:
                exerciseStartedAt.add(Duration(minutes: 4 + setIndex * 4)),
          );
        }).toList(growable: false),
      );
    }).toList(growable: false);

    return WorkoutSession(
      id: 'demo-session-$index',
      title: blueprint.title,
      startedAt: startedAt,
      endedAt: isActive
          ? null
          : startedAt.add(Duration(minutes: blueprint.durationMinutes)),
      selectedExerciseId: exercises.isEmpty ? null : exercises.first.exerciseId,
      exercises: exercises,
      heartRateSamples: _heartRateSamples(
        sessionIndex: index,
        startedAt: startedAt,
        durationMinutes: blueprint.durationMinutes,
        bpmBase: blueprint.bpmBase,
        bpmPeak: blueprint.bpmPeak,
        exercises: exercises,
      ),
    );
  }

  static List<HeartRateSample> _heartRateSamples({
    required int sessionIndex,
    required DateTime startedAt,
    required int durationMinutes,
    required int bpmBase,
    required int bpmPeak,
    required List<SessionExercise> exercises,
  }) {
    if (exercises.isEmpty) {
      return const [];
    }

    const count = 12;
    final samples = <HeartRateSample>[];
    for (var i = 0; i < count; i += 1) {
      final phase = i / (count - 1);
      final effortWave = phase <= 0.55 ? phase / 0.55 : (1 - phase) / 0.45;
      final bpm =
          bpmBase + ((bpmPeak - bpmBase) * effortWave).round() + (i % 3) * 2;
      final exercise = exercises[i % exercises.length];
      samples.add(
        HeartRateSample(
          id: 'demo-session-$sessionIndex-hr-$i',
          bpm: bpm,
          timestamp: startedAt.add(
            Duration(minutes: 3 + ((durationMinutes - 6) * phase).round()),
          ),
          exerciseId: exercise.exerciseId,
          source: i.isEven ? 'demo-apple-watch' : 'demo-manual',
        ),
      );
    }
    return samples;
  }
}

class _WorkoutBlueprint {
  const _WorkoutBlueprint({
    required this.title,
    required this.daysAgo,
    required this.durationMinutes,
    required this.bpmBase,
    required this.bpmPeak,
    required this.exercises,
  });

  final String title;
  final int daysAgo;
  final int durationMinutes;
  final int bpmBase;
  final int bpmPeak;
  final List<_ExercisePlan> exercises;
}

class _ExercisePlan {
  const _ExercisePlan(this.ref, this.reps, this.weightsKg);

  final _ExerciseRef ref;
  final List<int> reps;
  final List<double> weightsKg;
}

class _ExerciseRef {
  const _ExerciseRef(this.id, this.name, this.muscleGroup);

  final String id;
  final String name;
  final String muscleGroup;

  static const benchPress = _ExerciseRef(
    '11111111-1111-1111-1111-111111111001',
    'Press de banca con barra',
    'Pecho',
  );
  static const inclineDumbbell = _ExerciseRef(
    '11111111-1111-1111-1111-111111111002',
    'Press inclinado con mancuernas',
    'Pecho',
  );
  static const pullUps = _ExerciseRef(
    '11111111-1111-1111-1111-111111111011',
    'Dominadas',
    'Espalda',
  );
  static const latPulldown = _ExerciseRef(
    '11111111-1111-1111-1111-111111111012',
    'Jalon al pecho',
    'Espalda',
  );
  static const barbellRow = _ExerciseRef(
    '11111111-1111-1111-1111-111111111013',
    'Remo con barra',
    'Espalda',
  );
  static const lowCableRow = _ExerciseRef(
    '11111111-1111-1111-1111-111111111015',
    'Remo en polea baja',
    'Espalda',
  );
  static const deadlift = _ExerciseRef(
    '11111111-1111-1111-1111-111111111016',
    'Peso muerto convencional',
    'Espalda',
  );
  static const romanianDeadlift = _ExerciseRef(
    '11111111-1111-1111-1111-111111111017',
    'Peso muerto rumano',
    'Espalda',
  );
  static const shoulderPress = _ExerciseRef(
    '11111111-1111-1111-1111-111111111021',
    'Press militar con barra',
    'Hombros',
  );
  static const lateralRaise = _ExerciseRef(
    '11111111-1111-1111-1111-111111111023',
    'Elevaciones laterales',
    'Hombros',
  );
  static const hammerCurl = _ExerciseRef(
    '11111111-1111-1111-1111-111111111033',
    'Curl martillo',
    'Biceps',
  );
  static const ezCurl = _ExerciseRef(
    '11111111-1111-1111-1111-111111111040',
    'Curl con barra Z',
    'Biceps',
  );
  static const tricepsRope = _ExerciseRef(
    '11111111-1111-1111-1111-111111111050',
    'Press de triceps con cuerda',
    'Triceps',
  );
  static const backSquat = _ExerciseRef(
    '11111111-1111-1111-1111-111111111051',
    'Sentadilla trasera',
    'Piernas',
  );
  static const frontSquat = _ExerciseRef(
    '11111111-1111-1111-1111-111111111052',
    'Sentadilla frontal',
    'Piernas',
  );
  static const legPress = _ExerciseRef(
    '11111111-1111-1111-1111-111111111053',
    'Prensa de piernas',
    'Piernas',
  );
  static const walkingLunge = _ExerciseRef(
    '11111111-1111-1111-1111-111111111054',
    'Zancadas con mancuernas',
    'Piernas',
  );
  static const calfRaise = _ExerciseRef(
    '11111111-1111-1111-1111-111111111061',
    'Elevacion de talones de pie',
    'Gemelos',
  );
  static const legExtension = _ExerciseRef(
    '11111111-1111-1111-1111-111111111058',
    'Extension de cuadriceps',
    'Piernas',
  );
  static const bulgarianSplitSquat = _ExerciseRef(
    '11111111-1111-1111-1111-111111111059',
    'Sentadilla bulgara',
    'Piernas',
  );
  static const plank = _ExerciseRef(
    '11111111-1111-1111-1111-111111111069',
    'Plancha frontal',
    'Core',
  );
  static const hangingLegRaise = _ExerciseRef(
    '11111111-1111-1111-1111-111111111068',
    'Elevaciones de piernas colgado',
    'Core',
  );
  static const pallofPress = _ExerciseRef(
    '11111111-1111-1111-1111-111111111075',
    'Pallof press',
    'Core',
  );
  static const treadmill = _ExerciseRef(
    '11111111-1111-1111-1111-111111111077',
    'Cinta de correr',
    'Cardio',
  );
  static const bike = _ExerciseRef(
    '11111111-1111-1111-1111-111111111078',
    'Bicicleta estatica',
    'Cardio',
  );
}
