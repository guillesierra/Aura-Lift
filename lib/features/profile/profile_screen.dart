import 'package:flutter/material.dart';

import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/body_type.dart';
import '../../core/state/app_state.dart';
import '../progress/exercise_progress_list_screen.dart';
import 'measurements_screen.dart';
import '../home/home_screen.dart';
import '../workout/workout_summary_detail_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
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
        final profile = appState.profile!;
        final completedSessions = appState.sessions
            .where((item) => !item.isActive)
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final totalVolume = completedSessions.fold<double>(
          0,
          (sum, session) => sum + session.totalVolume,
        );
        final totalMinutes = completedSessions.fold<int>(
          0,
          (sum, session) => sum + session.duration.inMinutes,
        );

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name.toLowerCase(),
                      style: theme.textTheme.displayLarge,
                    ),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 58,
                          backgroundColor:
                              theme.colorScheme.primary.withValues(alpha: 0.18),
                          child: Text(
                            profile.name.isNotEmpty
                                ? profile.name[0].toUpperCase()
                                : 'A',
                            style: theme.textTheme.displayLarge,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(profile.name, style: theme.textTheme.headlineMedium),
                              const SizedBox(height: 8),
                              Text(
                                '${profile.heightCm.toStringAsFixed(0)} cm · ${profile.weightKg.toStringAsFixed(0)} kg · ${profile.bodyType.title}',
                                style: theme.textTheme.bodyMedium,
                              ),
                              const SizedBox(height: 18),
                              Row(
                                children: [
                                  Expanded(
                                    child: _TopStat(
                                      label: strings.workouts,
                                      value: '${completedSessions.length}',
                                    ),
                                  ),
                                  Expanded(
                                    child: _TopStat(
                                      label: strings.volume,
                                      value: totalVolume.toStringAsFixed(0),
                                    ),
                                  ),
                                  Expanded(
                                    child: _TopStat(
                                      label: strings.duration,
                                      value: '${totalMinutes}m',
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(strings.info, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      childAspectRatio: 1.55,
                      children: [
                        _ActionTile(
                          title: strings.stats,
                          icon: Icons.insights_outlined,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ExerciseProgressListScreen(
                                  appState: appState,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          title: strings.exercises,
                          icon: Icons.fitness_center_outlined,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ExerciseProgressListScreen(
                                  appState: appState,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          title: strings.measurements,
                          icon: Icons.accessibility_new_outlined,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MeasurementsScreen(
                                  profile: profile,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          title: strings.calendar,
                          icon: Icons.calendar_today_outlined,
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(strings.workouts, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 14),
                    if (completedSessions.isEmpty)
                      Text(
                        strings.noClosedSessions,
                        style: theme.textTheme.bodyMedium,
                      )
                    else
                      ...completedSessions.map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: WorkoutSummaryCard(
                            session: session,
                            authorName: profile.name,
                            authorHandle: profile.name.toLowerCase(),
                            highlightColor: theme.colorScheme.primary,
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => WorkoutSummaryDetailScreen(
                                    session: session,
                                    authorName: profile.name,
                                  ),
                                ),
                              );
                            },
                            onRename: (title) {
                              return appState.renameWorkoutSession(
                                sessionId: session.id,
                                title: title,
                              );
                            },
                            onDelete: () {
                              return appState.deleteWorkoutSession(
                                session.id,
                              );
                            },
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _TopStat extends StatelessWidget {
  const _TopStat({
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
        const SizedBox(height: 4),
        Text(value, style: theme.textTheme.titleLarge),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: theme.colorScheme.outline),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: theme.colorScheme.primary),
            const Spacer(),
            Text(title, style: theme.textTheme.titleMedium),
          ],
        ),
      ),
    );
  }
}
