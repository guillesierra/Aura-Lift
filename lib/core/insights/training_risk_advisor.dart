import '../models/workout_session.dart';
import '../localization/app_strings.dart';

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
    final strings = AppStrings.of(languageCode);
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
          message: strings.minimumWorkoutsForRecommendations,
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
            message: strings.muscleLoadConcentrationWarning(
              top.key,
              (ratio * 100).round(),
            ),
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
          message: strings.highJointStressWarning(
            strings.jointName(topJoint.first.key),
          ),
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
          message: strings.consecutiveDaysTrainingWarning,
        ),
      );
    }

    if (recommendations.isEmpty) {
      recommendations.add(
        TrainingRecommendation(
          severity: RecommendationSeverity.low,
          message: strings.balancedLoadMessage,
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
