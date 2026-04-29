import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/metrics/calorie_estimator.dart';
import '../../core/models/exercise_progress_summary.dart';
import '../../core/models/workout_session.dart';
import '../../core/state/app_state.dart';

class PersonalStatsScreen extends StatelessWidget {
  const PersonalStatsScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final theme = Theme.of(context);
        final strings = AppStrings.of(appState.languageCode);
        final completedSessions = appState.sessions
            .where((session) => !session.isActive)
            .toList(growable: false)
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final stats = _PersonalStats.fromSessions(
          completedSessions,
          appState.exerciseProgressSummaries(),
          appState.profile!.weightKg,
        );

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      Expanded(
                        child: Text(
                          strings.personalStatsTitle,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    completedSessions.isEmpty
                        ? strings.personalStatsEmpty
                        : strings.personalStatsCopy(completedSessions.length),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (completedSessions.isEmpty)
                    AuraCard(
                      child: Text(
                        strings.personalStatsEmpty,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else ...[
                    _StatsHeroCard(stats: stats),
                    const SizedBox(height: 14),
                    _StatsGrid(stats: stats),
                    const SizedBox(height: 20),
                    Text(strings.topExercise,
                        style: theme.textTheme.titleLarge),
                    const SizedBox(height: 12),
                    _ExerciseHighlightCard(
                      title: strings.topExercise,
                      emptyText: strings.noExerciseData,
                      exerciseName: stats.topVolumeExercise?.exerciseName,
                      detail: stats.topVolumeExercise == null
                          ? null
                          : '${stats.topVolumeExercise!.totalVolume.toStringAsFixed(0)} kg',
                      subtitle: stats.topVolumeExercise?.muscleGroup,
                    ),
                    const SizedBox(height: 12),
                    _ExerciseHighlightCard(
                      title: strings.heaviestLift,
                      emptyText: strings.noExerciseData,
                      exerciseName: stats.heaviestExercise?.exerciseName,
                      detail: stats.heaviestExercise == null
                          ? null
                          : '${stats.heaviestExercise!.bestWeight.toStringAsFixed(0)} kg',
                      subtitle: stats.heaviestExercise?.muscleGroup,
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _StatsHeroCard extends StatelessWidget {
  const _StatsHeroCard({
    required this.stats,
  });

  final _PersonalStats stats;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

    return AuraCard(
      padding: const EdgeInsets.all(26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(strings.totalVolume, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${stats.totalVolume.toStringAsFixed(0)} kg',
              style: theme.textTheme.displayLarge,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _InlineMetric(
                  label: strings.workouts,
                  value: '${stats.workoutsCount}',
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  label: strings.activeDays,
                  value: '${stats.activeDays}',
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  label: strings.totalCalories,
                  value: '${stats.totalCalories} ${strings.caloriesUnit}',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.stats,
  });

  final _PersonalStats stats;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

    return GridView.count(
      crossAxisCount: 2,
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      childAspectRatio: 1.45,
      children: [
        _StatTile(
          label: strings.totalCalories,
          value: '${stats.totalCalories} ${strings.caloriesUnit}',
          icon: Icons.local_fire_department_outlined,
        ),
        _StatTile(
          label: strings.duration,
          value: '${stats.totalMinutes}m',
          icon: Icons.timer_outlined,
        ),
        _StatTile(
          label: strings.averageSession,
          value: '${stats.averageSessionMinutes}m',
          icon: Icons.query_stats_outlined,
        ),
        _StatTile(
          label: strings.totalSetsLabel,
          value: '${stats.totalSets}',
          icon: Icons.format_list_numbered,
        ),
        _StatTile(
          label: strings.averageHeartRate,
          value: stats.averageHeartRate == null
              ? '--'
              : '${stats.averageHeartRate}',
          icon: Icons.favorite_outline,
          iconColor: Colors.red,
        ),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuraCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor ?? theme.colorScheme.primary),
          const Spacer(),
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleLarge),
        ],
      ),
    );
  }
}

class _InlineMetric extends StatelessWidget {
  const _InlineMetric({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _ExerciseHighlightCard extends StatelessWidget {
  const _ExerciseHighlightCard({
    required this.title,
    required this.emptyText,
    required this.exerciseName,
    required this.detail,
    required this.subtitle,
  });

  final String title;
  final String emptyText;
  final String? exerciseName;
  final String? detail;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuraCard(
      padding: const EdgeInsets.all(22),
      child: exerciseName == null
          ? Text(emptyText, style: theme.textTheme.bodyMedium)
          : Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: theme.textTheme.bodyMedium),
                      const SizedBox(height: 6),
                      Text(
                        exerciseName!,
                        style: theme.textTheme.titleLarge,
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 4),
                        Text(subtitle!, style: theme.textTheme.bodyMedium),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Text(detail ?? '--', style: theme.textTheme.titleLarge),
              ],
            ),
    );
  }
}

class _PersonalStats {
  const _PersonalStats({
    required this.workoutsCount,
    required this.activeDays,
    required this.totalMinutes,
    required this.averageSessionMinutes,
    required this.totalVolume,
    required this.totalSets,
    required this.totalCalories,
    required this.averageHeartRate,
    required this.topVolumeExercise,
    required this.heaviestExercise,
  });

  final int workoutsCount;
  final int activeDays;
  final int totalMinutes;
  final int averageSessionMinutes;
  final double totalVolume;
  final int totalSets;
  final int totalCalories;
  final int? averageHeartRate;
  final ExerciseProgressSummary? topVolumeExercise;
  final ExerciseProgressSummary? heaviestExercise;

  static _PersonalStats fromSessions(
    List<WorkoutSession> sessions,
    List<ExerciseProgressSummary> exerciseSummaries,
    double bodyWeightKg,
  ) {
    final totalMinutes = sessions.fold<int>(
      0,
      (sum, session) => sum + session.duration.inMinutes,
    );
    final totalVolume = sessions.fold<double>(
      0,
      (sum, session) => sum + session.totalVolume,
    );
    final totalSets = sessions.fold<int>(
      0,
      (sum, session) => sum + session.totalSets,
    );
    final totalCalories = sessions.fold<int>(
      0,
      (sum, session) =>
          sum +
          CalorieEstimator.estimateWorkoutCalories(
            session: session,
            bodyWeightKg: bodyWeightKg,
          ),
    );
    final heartRateSamples = sessions
        .expand((session) => session.heartRateSamples)
        .toList(growable: false);
    final activeDayKeys = sessions.map((session) {
      final local = session.startedAt.toLocal();
      return '${local.year}-${local.month}-${local.day}';
    }).toSet();

    ExerciseProgressSummary? topVolumeExercise;
    ExerciseProgressSummary? heaviestExercise;
    for (final summary in exerciseSummaries) {
      if (topVolumeExercise == null ||
          summary.totalVolume > topVolumeExercise.totalVolume) {
        topVolumeExercise = summary;
      }
      if (heaviestExercise == null ||
          summary.bestWeight > heaviestExercise.bestWeight) {
        heaviestExercise = summary;
      }
    }

    final averageHeartRate = heartRateSamples.isEmpty
        ? null
        : (heartRateSamples.fold<int>(
                  0,
                  (sum, sample) => sum + sample.bpm,
                ) /
                heartRateSamples.length)
            .round();

    return _PersonalStats(
      workoutsCount: sessions.length,
      activeDays: activeDayKeys.length,
      totalMinutes: totalMinutes,
      averageSessionMinutes:
          sessions.isEmpty ? 0 : (totalMinutes / sessions.length).round(),
      totalVolume: totalVolume,
      totalSets: totalSets,
      totalCalories: totalCalories,
      averageHeartRate: averageHeartRate,
      topVolumeExercise: topVolumeExercise,
      heaviestExercise: heaviestExercise,
    );
  }
}
