import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/exercise_progress_point.dart';
import '../../core/state/app_state.dart';

class ExerciseProgressDetailScreen extends StatelessWidget {
  const ExerciseProgressDetailScreen({
    super.key,
    required this.appState,
    required this.exerciseId,
  });

  final AppState appState;
  final String exerciseId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(appState.languageCode);
    final history = appState.progressHistoryForExercise(exerciseId);
    if (history.isEmpty) {
      return Scaffold(
        body: TintedBackground(
          child: SafeArea(
            child: Center(
              child: Text(
                strings.noDataForExercise,
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ),
        ),
      );
    }

    final latest = history.first;
    final bestWeight = history.fold<double>(
      0,
      (maxValue, item) => item.bestWeight > maxValue ? item.bestWeight : maxValue,
    );
    final totalVolume = history.fold<double>(
      0,
      (sum, item) => sum + item.totalVolume,
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
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          latest.exerciseName,
                          style: theme.textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 4),
                        Text(latest.muscleGroup, style: theme.textTheme.bodyMedium),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AuraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.summary, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            label: strings.sessions,
                            value: '${history.length}',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryStat(
                            label: strings.bestWeight,
                            value: '${bestWeight.toStringAsFixed(0)} kg',
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _SummaryStat(
                            label: strings.totalVolume,
                            value: '${totalVolume.toStringAsFixed(0)} kg',
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _SummaryStat(
                            label: strings.latestVolume,
                            value: '${latest.totalVolume.toStringAsFixed(0)} kg',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              AuraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(strings.volumeEvolution, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 18),
                    _VolumeBars(history: history.take(6).toList()),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              Text(strings.latestSessions, style: theme.textTheme.titleLarge),
              const SizedBox(height: 14),
              ...history.map(
                (point) => Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: _HistoryCard(point: point),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryStat extends StatelessWidget {
  const _SummaryStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _VolumeBars extends StatelessWidget {
  const _VolumeBars({required this.history});

  final List<ExerciseProgressPoint> history;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final reversed = history.reversed.toList(growable: false);
    final maxVolume = reversed.fold<double>(
      1,
      (maxValue, item) => item.totalVolume > maxValue ? item.totalVolume : maxValue,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: reversed.map((point) {
        final height = (point.totalVolume / maxVolume) * 120;
        final local = point.sessionDate.toLocal();
        final label =
            '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Container(
                  height: height.clamp(12, 120).toDouble(),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 8),
                Text(label, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        );
      }).toList(growable: false),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.point});

  final ExerciseProgressPoint point;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    final local = point.sessionDate.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';

    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(point.sessionTitle, style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(date, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _InlineMetric(
                  label: strings.sets,
                  value: '${point.setsCount}',
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  label: strings.reps,
                  value: '${point.totalReps}',
                ),
              ),
              Expanded(
                child: _InlineMetric(
                  label: strings.volume,
                  value: '${point.totalVolume.toStringAsFixed(0)} kg',
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...point.setSummary.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text(item, style: theme.textTheme.bodyLarge),
            ),
          ),
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
