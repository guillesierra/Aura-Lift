import '../models/workout_session.dart';

enum RecommendationSeverity {
  high,
  medium,
  low,
}

class TrainingRecommendation {
  const TrainingRecommendation({
    required this.severity,
    required this.message,
  });

  final RecommendationSeverity severity;
  final String message;
}

class TrainingRiskAdvisor {
  const TrainingRiskAdvisor._();

  static List<TrainingRecommendation> build({
    required List<WorkoutSession> sessions,
    required String languageCode,
    DateTime? now,
  }) {
    final isEnglish = languageCode == 'en';
    final anchor = (now ?? DateTime.now()).toUtc();
    final recent = sessions
        .where((session) => !session.isActive)
        .where(
          (session) =>
              anchor.difference(session.startedAt.toUtc()) <=
              const Duration(days: 21),
        )
        .toList(growable: false);

    if (recent.isEmpty) {
      return [
        TrainingRecommendation(
          severity: RecommendationSeverity.low,
          message: isEnglish
              ? 'Log at least three workouts to unlock personalized recommendations.'
              : 'Registra al menos tres entrenos para desbloquear recomendaciones personalizadas.',
        ),
      ];
    }

    final muscleSetLoad = <String, int>{};
    final jointStressScore = <String, int>{
      'rodilla': 0,
      'hombro': 0,
      'codo': 0,
      'lumbar': 0,
    };

    for (final session in recent) {
      for (final exercise in session.exercises) {
        final sets = exercise.sets.isEmpty ? 1 : exercise.sets.length;
        muscleSetLoad.update(
          exercise.muscleGroup,
          (value) => value + sets,
          ifAbsent: () => sets,
        );
        _applyJointStress(
          score: jointStressScore,
          exerciseName: exercise.exerciseName,
          sets: sets,
        );
      }
    }

    final recommendations = <TrainingRecommendation>[];
    final totalSets = muscleSetLoad.values.fold<int>(0, (a, b) => a + b);
    if (totalSets > 0) {
      final sortedGroups = muscleSetLoad.entries.toList(growable: false)
        ..sort((a, b) => b.value.compareTo(a.value));
      final top = sortedGroups.first;
      final ratio = top.value / totalSets;
      if (ratio >= 0.45 && top.value >= 18) {
        recommendations.add(
          TrainingRecommendation(
            severity: RecommendationSeverity.high,
            message: isEnglish
                ? 'You are concentrating too much load on ${top.key} (${(ratio * 100).round()}% of recent sets). Add 1-2 sessions for antagonist muscles to reduce overuse risk.'
                : 'Estas concentrando demasiada carga en ${top.key} (${(ratio * 100).round()}% de tus series recientes). Añade 1-2 sesiones de grupos antagonistas para reducir riesgo de sobreuso.',
          ),
        );
      }
    }

    final topJoint = jointStressScore.entries.toList(growable: false)
      ..sort((a, b) => b.value.compareTo(a.value));
    if (topJoint.isNotEmpty && topJoint.first.value >= 22) {
      recommendations.add(
        TrainingRecommendation(
          severity: RecommendationSeverity.high,
          message: isEnglish
              ? 'High repeated stress detected on ${_jointName(topJoint.first.key, isEnglish)}. Consider reducing heavy volume 20-30% this week and prioritize mobility and technique work.'
              : 'Se detecta estrés repetido alto en ${_jointName(topJoint.first.key, isEnglish)}. Considera bajar 20-30% el volumen pesado esta semana y priorizar movilidad y tecnica.',
        ),
      );
    }

    final activeDays = recent
        .map(
          (session) => DateTime(
            session.startedAt.year,
            session.startedAt.month,
            session.startedAt.day,
          ),
        )
        .toSet()
        .length;
    if (activeDays >= 6 && recent.length >= 6) {
      recommendations.add(
        TrainingRecommendation(
          severity: RecommendationSeverity.medium,
          message: isEnglish
              ? 'You are training on many consecutive days. Plan at least one full recovery day to improve adaptation and lower injury probability.'
              : 'Estas entrenando muchos dias consecutivos. Programa al menos un dia completo de recuperacion para mejorar adaptacion y bajar probabilidad de lesion.',
        ),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        TrainingRecommendation(
          severity: RecommendationSeverity.low,
          message: isEnglish
              ? 'Your recent load looks balanced. Keep progressive overload moderate and include mobility before heavy compounds.'
              : 'Tu carga reciente se ve equilibrada. Mantén una sobrecarga progresiva moderada e incluye movilidad antes de compuestos pesados.',
        ),
      );
    }

    recommendations
      .sort((a, b) => b.severity.index.compareTo(a.severity.index));
    return recommendations;
  }

  static void _applyJointStress({
    required Map<String, int> score,
    required String exerciseName,
    required int sets,
  }) {
    final key = _normalize(exerciseName);
    if (_containsAny(key, const [
      'sentadilla',
      'zancada',
      'prensa',
      'step-up',
      'extension de cuadriceps',
      'bulgara',
      'sprint',
    ])) {
      score['rodilla'] = (score['rodilla'] ?? 0) + sets;
    }
    if (_containsAny(key, const [
      'press',
      'elevaciones',
      'fondos',
      'dominadas',
      'jalon',
      'face pull',
      'remo al menton',
    ])) {
      score['hombro'] = (score['hombro'] ?? 0) + sets;
    }
    if (_containsAny(key, const [
      'curl',
      'extension de triceps',
      'rompecraneos',
      'press cerrado',
    ])) {
      score['codo'] = (score['codo'] ?? 0) + sets;
    }
    if (_containsAny(key, const [
      'peso muerto',
      'remo con barra',
      'buenos dias',
      'hiperextensiones',
      'sentadilla trasera',
      'sentadilla frontal',
    ])) {
      score['lumbar'] = (score['lumbar'] ?? 0) + sets;
    }
  }

  static bool _containsAny(String text, List<String> options) {
    for (final option in options) {
      if (text.contains(option)) {
        return true;
      }
    }
    return false;
  }

  static String _jointName(String key, bool isEnglish) {
    switch (key) {
      case 'rodilla':
        return isEnglish ? 'knee joint' : 'la rodilla';
      case 'hombro':
        return isEnglish ? 'shoulder joint' : 'el hombro';
      case 'codo':
        return isEnglish ? 'elbow joint' : 'el codo';
      case 'lumbar':
        return isEnglish ? 'lumbar zone' : 'la zona lumbar';
      default:
        return isEnglish ? 'a joint' : 'una articulacion';
    }
  }

  static String _normalize(String value) {
    return value
        .trim()
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }
}