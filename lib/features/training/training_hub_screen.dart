import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/primary_button.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/app_state.dart';
import 'exercise_catalog_screen.dart';
import '../workout/workout_session_screen.dart';

class TrainingHubScreen extends StatelessWidget {
  const TrainingHubScreen({
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
        final activeSession = appState.activeSession;

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                  child: ConstrainedBox(
                    constraints:
                        BoxConstraints(minHeight: constraints.maxHeight),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(strings.training,
                            style: theme.textTheme.displayLarge),
                        const SizedBox(height: 12),
                        Text(
                          activeSession == null
                              ? strings.directSessionAccess
                              : strings.activePanelCopy,
                          style: theme.textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 24),
                        AuraCard(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                activeSession == null
                                    ? strings.startEmptyWorkout
                                    : strings.activeSession,
                                style: theme.textTheme.headlineMedium,
                              ),
                              const SizedBox(height: 12),
                              if (activeSession != null) ...[
                                _HubMetricRow(
                                  label: strings.exercisesLabel,
                                  value: '${activeSession.exercises.length}',
                                ),
                                const SizedBox(height: 10),
                                _HubMetricRow(
                                  label: strings.setsLabel,
                                  value: '${activeSession.totalSets}',
                                ),
                                const SizedBox(height: 10),
                                _HubMetricRow(
                                  label: strings.volume,
                                  value:
                                      '${activeSession.totalVolume.toStringAsFixed(0)} kg',
                                ),
                                const SizedBox(height: 18),
                              ] else
                                const SizedBox(height: 4),
                              PrimaryButton(
                                label: activeSession == null
                                    ? strings.start
                                    : strings.resume,
                                icon: activeSession == null
                                    ? Icons.play_arrow_rounded
                                    : Icons.bolt_rounded,
                                onPressed: () async {
                                  if (activeSession == null) {
                                    await appState.startWorkoutSession();
                                  }
                                  if (context.mounted) {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => WorkoutSessionScreen(
                                          appState: appState,
                                        ),
                                      ),
                                    );
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(strings.quickAccess,
                            style: theme.textTheme.titleLarge),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: _QuickTile(
                                icon: Icons.add_chart_rounded,
                                title: strings.lastSession,
                                subtitle: appState.sessions
                                        .where((item) => !item.isActive)
                                        .isEmpty
                                    ? strings.noHistory
                                    : '${appState.sessions.where((item) => !item.isActive).last.totalSets} series',
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: _QuickTile(
                                icon: Icons.stacked_bar_chart_rounded,
                                title: strings.exercises,
                                subtitle: strings.loadedExercises(
                                  appState.exercises.length,
                                ),
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => ExerciseCatalogScreen(
                                        appState: appState,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _HubMetricRow extends StatelessWidget {
  const _HubMetricRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _QuickTile extends StatelessWidget {
  const _QuickTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AuraCard.radius),
      onTap: onTap,
      child: AuraCard(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 28),
            const SizedBox(height: 20),
            Text(title, style: theme.textTheme.titleMedium),
            const SizedBox(height: 6),
            Text(subtitle, style: theme.textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}
