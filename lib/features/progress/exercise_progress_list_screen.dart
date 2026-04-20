import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/exercise_progress_summary.dart';
import '../../core/state/app_state.dart';
import 'exercise_progress_detail_screen.dart';

class ExerciseProgressListScreen extends StatelessWidget {
  const ExerciseProgressListScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(appState.languageCode);
    final progress = appState.exerciseProgressSummaries();

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
                      strings.exerciseProgress,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                progress.isEmpty
                    ? strings.notEnoughExerciseHistory
                    : strings.exerciseHistoryCount(progress.length),
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 20),
              if (progress.isEmpty)
                AuraCard(
                  child: Text(
                    strings.progressEmptyCopy,
                    style: theme.textTheme.bodyMedium,
                  ),
                )
              else
                ...progress.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _ProgressExerciseCard(
                      entry: entry,
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => ExerciseProgressDetailScreen(
                              appState: appState,
                              exerciseId: entry.exerciseId,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProgressExerciseCard extends StatelessWidget {
  const _ProgressExerciseCard({
    required this.entry,
    required this.onTap,
  });

  final ExerciseProgressSummary entry;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: onTap,
      child: AuraCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.exerciseName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(entry.muscleGroup, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                const Icon(Icons.arrow_forward_ios, size: 18),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _MetricChip(
                    label: strings.sessions,
                    value: '${entry.sessionsCount}',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricChip(
                    label: strings.bestWeight,
                    value: '${entry.bestWeight.toStringAsFixed(0)} kg',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _MetricChip(
                    label: strings.volume,
                    value: '${entry.totalVolume.toStringAsFixed(0)} kg',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricChip(
                    label: strings.lastTime,
                    value: _formatDate(entry.lastPerformedAt),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    return '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}';
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(14),
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
