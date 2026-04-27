import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/muscle_group_icon.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/metrics/calorie_estimator.dart';
import '../../core/models/workout_session.dart';

class WorkoutSummaryDetailScreen extends StatelessWidget {
  const WorkoutSummaryDetailScreen({
    super.key,
    required this.session,
    required this.authorName,
    required this.bodyWeightKg,
  });

  final WorkoutSession session;
  final String authorName;
  final double bodyWeightKg;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    final local = session.startedAt.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final time =
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
    final averageHeartRate = session.averageHeartRate;
    final maxHeartRate = session.maxHeartRate;
    final estimatedCalories = CalorieEstimator.estimateWorkoutCalories(
      session: session,
      bodyWeightKg: bodyWeightKg,
    );

    return Scaffold(
      body: TintedBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              authorName,
                              style: theme.textTheme.titleMedium,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '$date · $time',
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: AuraCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          session.title,
                          style: theme.textTheme.displayMedium,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            Expanded(
                              child: _DetailMetric(
                                label: strings.time,
                                value: '${session.duration.inMinutes} min',
                              ),
                            ),
                            Expanded(
                              child: _DetailMetric(
                                label: strings.estimatedCalories,
                                value:
                                    '$estimatedCalories ${strings.caloriesUnit}',
                                trailingIcon:
                                    Icons.local_fire_department_rounded,
                                trailingColor: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _DetailMetric(
                                label: strings.volume,
                                value:
                                    '${session.totalVolume.toStringAsFixed(0)} kg',
                              ),
                            ),
                            Expanded(
                              child: _DetailMetric(
                                label: strings.sets,
                                value: '${session.totalSets}',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _DetailMetric(
                                label: strings.exercisesLabel,
                                value: '${session.exercises.length}',
                              ),
                            ),
                            const Spacer(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: AuraCard(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.heartRate,
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 18),
                        Row(
                          children: [
                            Expanded(
                              child: _DetailMetric(
                                label: strings.average,
                                value: averageHeartRate == null
                                    ? '--'
                                    : '$averageHeartRate',
                                trailingIcon: Icons.favorite,
                                trailingColor: Colors.red,
                              ),
                            ),
                            Expanded(
                              child: _DetailMetric(
                                label: strings.maximum,
                                value: maxHeartRate == null ? '--' : '$maxHeartRate',
                                trailingIcon: Icons.favorite,
                                trailingColor: Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Text(
                          session.heartRateSamples.isEmpty
                              ? strings.noHeartRateSamplesInWorkout
                              : strings.heartRateSampleCount(
                                  session.heartRateSamples.length,
                                ),
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                  child: Text(
                    strings.exercisesLabelShort,
                    style: theme.textTheme.titleLarge,
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
                sliver: SliverList.separated(
                  itemBuilder: (context, index) {
                    final exercise = session.exercises[index];
                    final bestWeight = exercise.sets.fold<double>(
                      0,
                      (maxValue, set) =>
                          set.weightKg > maxValue ? set.weightKg : maxValue,
                    );
                    final averageHeartRate = session.averageHeartRateForExercise(
                      exercise.exerciseId,
                    );
                    final maxHeartRate = session.maxHeartRateForExercise(
                      exercise.exerciseId,
                    );
                    final sampleCount = session.heartRateSampleCountForExercise(
                      exercise.exerciseId,
                    );
                    final estimatedCalories =
                        CalorieEstimator.estimateExerciseCalories(
                      session: session,
                      exercise: exercise,
                      bodyWeightKg: bodyWeightKg,
                    );

                    return AuraCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              MuscleGroupIcon(
                                muscleGroup: exercise.muscleGroup,
                                size: 58,
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.exerciseName,
                                      style: theme.textTheme.titleLarge,
                                    ),
                                    const SizedBox(height: 6),
                                    Text(
                                      exercise.muscleGroup,
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _DetailMetric(
                                  label: strings.sets,
                                  value: '${exercise.sets.length}',
                                ),
                              ),
                              Expanded(
                                child: _DetailMetric(
                                  label: strings.volume,
                                  value:
                                      '${exercise.totalVolume.toStringAsFixed(0)} kg',
                                ),
                              ),
                              Expanded(
                                child: _DetailMetric(
                                  label: strings.maxWeightShort,
                                  value: '${bestWeight.toStringAsFixed(0)} kg',
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          _DetailMetric(
                            label: strings.estimatedCalories,
                            value: '$estimatedCalories ${strings.caloriesUnit}',
                            trailingIcon: Icons.local_fire_department_rounded,
                            trailingColor: theme.colorScheme.primary,
                          ),
                          const SizedBox(height: 14),
                          Row(
                            children: [
                              Expanded(
                                child: _DetailMetric(
                                  label: strings.averageHeartRateLabel,
                                  value: averageHeartRate == null
                                      ? '--'
                                      : '$averageHeartRate',
                                  trailingIcon: Icons.favorite,
                                  trailingColor: Colors.red,
                                ),
                              ),
                              Expanded(
                                child: _DetailMetric(
                                  label: strings.maxHeartRateLabel,
                                  value: maxHeartRate == null
                                      ? '--'
                                      : '$maxHeartRate',
                                  trailingIcon: Icons.favorite,
                                  trailingColor: Colors.red,
                                ),
                              ),
                              Expanded(
                                child: _DetailMetric(
                                  label: strings.samples,
                                  value: '$sampleCount',
                                ),
                              ),
                            ],
                          ),
                          if (exercise.sets.isNotEmpty) ...[
                            const SizedBox(height: 14),
                            ...exercise.sets.asMap().entries.map((entry) {
                              final set = entry.value;
                              final weight = set.weightKg % 1 == 0
                                  ? set.weightKg.toStringAsFixed(0)
                                  : set.weightKg.toStringAsFixed(1);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Text(
                                  strings.exerciseSetDetail(
                                    entry.key + 1,
                                    set.reps,
                                    weight,
                                  ),
                                  style: theme.textTheme.bodyLarge,
                                ),
                              );
                            }),
                          ],
                        ],
                      ),
                    );
                  },
                  separatorBuilder: (context, index) => const SizedBox(height: 12),
                  itemCount: session.exercises.length,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DetailMetric extends StatelessWidget {
  const _DetailMetric({
    required this.label,
    required this.value,
    this.trailingIcon,
    this.trailingColor,
  });

  final String label;
  final String value;
  final IconData? trailingIcon;
  final Color? trailingColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.bodyMedium),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(value, style: theme.textTheme.titleMedium),
            if (trailingIcon != null) ...[
              const SizedBox(width: 4),
              Icon(
                trailingIcon,
                size: 16,
                color: trailingColor ?? theme.colorScheme.primary,
              ),
            ],
          ],
        ),
      ],
    );
  }
}
