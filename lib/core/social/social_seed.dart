import '../models/exercise_set.dart';
import '../models/heart_rate_sample.dart';
import '../models/session_exercise.dart';
import '../models/social_profile.dart';
import '../models/workout_session.dart';

class SocialSeed {
  const SocialSeed._();

  static const List<String> avatarPresets = [
    'https://i.pravatar.cc/200?img=12',
    'https://i.pravatar.cc/200?img=24',
    'https://i.pravatar.cc/200?img=31',
    'https://i.pravatar.cc/200?img=36',
    'https://i.pravatar.cc/200?img=44',
    'https://i.pravatar.cc/200?img=47',
    'https://i.pravatar.cc/200?img=52',
    'https://i.pravatar.cc/200?img=58',
    'https://i.pravatar.cc/200?img=63',
    'https://i.pravatar.cc/200?img=67',
  ];

  static final List<SocialProfile> profiles = _buildProfiles();

  static final Set<String> initialFollowingIds = _buildInitialFollowingIds();

  static Map<String, List<WorkoutSession>> sessionsByProfileId() {
    final now = DateTime.now().toUtc();
    final map = <String, List<WorkoutSession>>{};
    for (var i = 0; i < profiles.length; i += 1) {
      final profile = profiles[i];
      map[profile.id] = _sessionsForProfile(profile.id, now, i);
    }
    return map;
  }

  static List<WorkoutSession> _sessionsForProfile(
    String profileId,
    DateTime now,
    int profileIndex,
  ) {
    final templates = _sessionTemplates;
    final sessions = <WorkoutSession>[];
    for (var i = 0; i < 14; i += 1) {
      final template = templates[(profileIndex + i) % templates.length];
      final startedAt = DateTime.utc(
        now.year,
        now.month,
        now.day,
        18 - ((i + profileIndex) % 3),
        10 + (i * 8),
      ).subtract(Duration(days: 2 + i * 3 + profileIndex * 2));
      sessions.add(
        _buildSession(
          profileId: profileId,
          sessionIndex: i,
          startedAt: startedAt,
          title: template.title,
          durationMinutes: template.durationMinutes,
          effortBase: template.effortBase + profileIndex * 2,
          exercises: template.exercises,
          profileBias: profileIndex,
        ),
      );
    }
    sessions.sort((a, b) => b.startedAt.compareTo(a.startedAt));
    return sessions;
  }

  static WorkoutSession _buildSession({
    required String profileId,
    required int sessionIndex,
    required DateTime startedAt,
    required String title,
    required int durationMinutes,
    required int effortBase,
    required List<_TemplateExercise> exercises,
    required int profileBias,
  }) {
    final builtExercises = exercises.asMap().entries.map((entry) {
      final index = entry.key;
      final exercise = entry.value;
      final started = startedAt.add(Duration(minutes: 6 + index * 12));
      return SessionExercise(
        id: '$profileId-$sessionIndex-ex-$index',
        exerciseId: exercise.exerciseId,
        exerciseName: exercise.name,
        muscleGroup: exercise.muscleGroup,
        orderIndex: index,
        startedAt: started,
        sets: [
          ExerciseSet(
            id: '$profileId-$sessionIndex-ex-$index-set-0',
            reps: 12,
            weightKg: exercise.baseWeight + profileBias * 2,
            completedAt: started.add(const Duration(minutes: 4)),
          ),
          ExerciseSet(
            id: '$profileId-$sessionIndex-ex-$index-set-1',
            reps: 10,
            weightKg: exercise.baseWeight + 2.5 + profileBias * 2,
            completedAt: started.add(const Duration(minutes: 8)),
          ),
          ExerciseSet(
            id: '$profileId-$sessionIndex-ex-$index-set-2',
            reps: 8,
            weightKg: exercise.baseWeight + 5 + profileBias * 2,
            completedAt: started.add(const Duration(minutes: 12)),
          ),
        ],
      );
    }).toList(growable: false);

    final hrSamples = <HeartRateSample>[];
    for (var i = 0; i < 16; i += 1) {
      final phase = i / 15;
      final wave = phase <= 0.6 ? phase / 0.6 : (1 - phase) / 0.4;
      final bpm = effortBase + (wave * 55).round() + (i % 4);
      final exercise = builtExercises[i % builtExercises.length];
      hrSamples.add(
        HeartRateSample(
          id: '$profileId-$sessionIndex-hr-$i',
          bpm: bpm,
          timestamp: startedAt.add(
            Duration(minutes: 4 + ((durationMinutes - 8) * phase).round()),
          ),
          exerciseId: exercise.exerciseId,
          source: i.isEven ? 'community-watch' : 'community-phone',
        ),
      );
    }

    return WorkoutSession(
      id: '$profileId-session-$sessionIndex',
      title: title,
      startedAt: startedAt,
      endedAt: startedAt.add(Duration(minutes: durationMinutes)),
      selectedExerciseId: builtExercises.first.exerciseId,
      exercises: builtExercises,
      heartRateSamples: hrSamples,
    );
  }

  static final List<_SessionTemplate> _sessionTemplates = [
    const _SessionTemplate(
      title: 'Push Intenso',
      durationMinutes: 68,
      effortBase: 92,
      exercises: [
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111001',
          name: 'Press de banca con barra',
          muscleGroup: 'Pecho',
          baseWeight: 70,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111002',
          name: 'Press inclinado con mancuernas',
          muscleGroup: 'Pecho',
          baseWeight: 26,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111023',
          name: 'Elevaciones laterales',
          muscleGroup: 'Hombros',
          baseWeight: 8,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111050',
          name: 'Press de triceps con cuerda',
          muscleGroup: 'Triceps',
          baseWeight: 24,
        ),
      ],
    ),
    const _SessionTemplate(
      title: 'Pull Tecnico',
      durationMinutes: 72,
      effortBase: 90,
      exercises: [
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111011',
          name: 'Dominadas',
          muscleGroup: 'Espalda',
          baseWeight: 0,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111013',
          name: 'Remo con barra',
          muscleGroup: 'Espalda',
          baseWeight: 58,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111012',
          name: 'Jalon al pecho',
          muscleGroup: 'Espalda',
          baseWeight: 54,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111033',
          name: 'Curl martillo',
          muscleGroup: 'Biceps',
          baseWeight: 14,
        ),
      ],
    ),
    const _SessionTemplate(
      title: 'Pierna Volumen',
      durationMinutes: 82,
      effortBase: 96,
      exercises: [
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111051',
          name: 'Sentadilla trasera',
          muscleGroup: 'Piernas',
          baseWeight: 88,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111053',
          name: 'Prensa de piernas',
          muscleGroup: 'Piernas',
          baseWeight: 180,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111017',
          name: 'Peso muerto rumano',
          muscleGroup: 'Espalda',
          baseWeight: 82,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111061',
          name: 'Elevacion de talones de pie',
          muscleGroup: 'Gemelos',
          baseWeight: 62,
        ),
      ],
    ),
    const _SessionTemplate(
      title: 'Full Body Denso',
      durationMinutes: 76,
      effortBase: 94,
      exercises: [
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111016',
          name: 'Peso muerto convencional',
          muscleGroup: 'Espalda',
          baseWeight: 112,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111001',
          name: 'Press de banca con barra',
          muscleGroup: 'Pecho',
          baseWeight: 68,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111021',
          name: 'Press militar con barra',
          muscleGroup: 'Hombros',
          baseWeight: 38,
        ),
        _TemplateExercise(
          exerciseId: '11111111-1111-1111-1111-111111111075',
          name: 'Pallof press',
          muscleGroup: 'Core',
          baseWeight: 15,
        ),
      ],
    ),
  ];

  static List<SocialProfile> _buildProfiles() {
    final seeded = <SocialProfile>[
      const SocialProfile(
        id: 'social-alex',
        name: 'Alex Costa',
        handle: '@alexcosta',
        avatarUrl: 'https://i.pravatar.cc/200?img=24',
        bio: 'Push/Pull, progreso constante y tecnica limpia.',
        followsMe: true,
      ),
      const SocialProfile(
        id: 'social-lucia',
        name: 'Lucia Romero',
        handle: '@luciaromero',
        avatarUrl: 'https://i.pravatar.cc/200?img=47',
        bio: 'Pierna fuerte, movilidad y constancia semanal.',
        followsMe: true,
      ),
      const SocialProfile(
        id: 'social-marcos',
        name: 'Marcos Vega',
        handle: '@marcosvega',
        avatarUrl: 'https://i.pravatar.cc/200?img=31',
        bio: 'Hipertrofia de torso + cardio inteligente.',
        followsMe: false,
      ),
      const SocialProfile(
        id: 'social-irene',
        name: 'Irene Solis',
        handle: '@irenesolis',
        avatarUrl: 'https://i.pravatar.cc/200?img=63',
        bio: 'Fuerza y resistencia con enfoque en espalda.',
        followsMe: true,
      ),
      const SocialProfile(
        id: 'social-diego',
        name: 'Diego Mora',
        handle: '@diegomora',
        avatarUrl: 'https://i.pravatar.cc/200?img=58',
        bio: 'Entrenos full body y marcas personales.',
        followsMe: false,
      ),
    ];

    const extraNames = [
      'Carla Nuñez',
      'Pablo Reyes',
      'Marta Ibarra',
      'Sergio Vidal',
      'Nadia Pons',
      'Hector Luna',
      'Elena Rios',
      'Ruben Gil',
      'Noa Martin',
      'Javier Leon',
      'Aitana Crespo',
      'Oscar Arias',
      'Paula Salas',
      'Raul Soto',
      'Valeria Cruz',
      'Daniel Roca',
      'Silvia Mora',
      'Kevin Serra',
      'Julia Peña',
      'Adrian Vives',
    ];
    const bios = [
      'Foco en hipertrofia progresiva y volumen semanal.',
      'Fuerza base, tecnica cuidada y sesiones eficientes.',
      'Combinando torso, pierna y cardio sin saltos.',
      'Objetivo: mejorar marcas y recuperacion.',
      'Entrenos funcionales con registro detallado.',
    ];

    for (var i = 0; i < extraNames.length; i += 1) {
      final name = extraNames[i];
      final handle = name.toLowerCase().replaceAll(' ', '').replaceAll('ñ', 'n');
      seeded.add(
        SocialProfile(
          id: 'social-auto-${i + 1}',
          name: name,
          handle: '@$handle',
          avatarUrl: avatarPresets[(i + 3) % avatarPresets.length],
          bio: bios[i % bios.length],
          followsMe: i % 3 != 0,
        ),
      );
    }

    return seeded;
  }

  static Set<String> _buildInitialFollowingIds() {
    final ids = <String>{};
    for (final entry in profiles.asMap().entries) {
      final index = entry.key;
      final profile = entry.value;
      final shouldFollowFriend = profile.followsMe && index.isEven;
      final shouldFollowOutgoing = !profile.followsMe && index % 5 == 0;
      if (shouldFollowFriend || shouldFollowOutgoing) {
        ids.add(profile.id);
      }
    }
    return ids;
  }
}

class _SessionTemplate {
  const _SessionTemplate({
    required this.title,
    required this.durationMinutes,
    required this.effortBase,
    required this.exercises,
  });

  final String title;
  final int durationMinutes;
  final int effortBase;
  final List<_TemplateExercise> exercises;
}

class _TemplateExercise {
  const _TemplateExercise({
    required this.exerciseId,
    required this.name,
    required this.muscleGroup,
    required this.baseWeight,
  });

  final String exerciseId;
  final String name;
  final String muscleGroup;
  final double baseWeight;
}
