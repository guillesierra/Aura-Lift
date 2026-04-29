import 'package:flutter/material.dart';

import '../../../core/design_system/widgets/aura_card.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/state/app_state.dart';
import 'workout_heart_rate_panel.dart';

class WorkoutSessionGlobalEmptyState extends StatelessWidget {
  const WorkoutSessionGlobalEmptyState({
    super.key,
    required this.strings,
  });

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AuraCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                strings.workoutSessionEmptyTitle,
                style: theme.textTheme.headlineMedium,
              ),
              const SizedBox(height: 12),
              Text(
                strings.workoutSessionEmptyCopy,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class WorkoutSessionHeartRateSliver extends StatelessWidget {
  const WorkoutSessionHeartRateSliver({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: WorkoutHeartRatePanel(appState: appState),
      ),
    );
  }
}

class WorkoutSessionEmptyExerciseSliver extends StatelessWidget {
  const WorkoutSessionEmptyExerciseSliver({
    super.key,
    required this.strings,
  });

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: AuraCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                strings.startWithExercise,
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Text(
                strings.startWithExerciseCopy,
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
