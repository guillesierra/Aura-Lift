import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/primary_button.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/metrics/calorie_estimator.dart';
import '../../core/models/body_type.dart';
import '../../core/models/workout_session.dart';
import '../../core/state/app_state.dart';
import '../workout/workout_summary_detail_screen.dart';
import '../workout/workout_session_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
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
        final activeSession = appState.activeSession;
        final completedSessions = appState.sessions
            .where((item) => !item.isActive)
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final homeInsight = _HomeInsight.fromSessions(completedSessions);

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(strings.home, style: theme.textTheme.bodyMedium),
                              const SizedBox(height: 10),
                              Text(
                                strings.hello(profile.name),
                                style: theme.textTheme.displayLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                activeSession == null
                                    ? strings.homeOverview
                                    : strings.homeOverviewActive,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        ),
                        IconButton.filledTonal(
                          tooltip: strings.settings,
                          onPressed: () {
                            _showSettingsSheet(context, appState);
                          },
                          icon: const Icon(Icons.settings_outlined),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    AuraCard(
                      padding: const EdgeInsets.all(28),
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
                                      activeSession == null
                                          ? strings.readyToTrain
                                          : strings.activeSession,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 12),
                                    Text(
                                      activeSession == null
                                          ? strings.quickStartCopy
                                          : strings.sessionSummary(
                                              activeSession.exercises.length,
                                              activeSession.totalSets,
                                            ),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                width: 56,
                                height: 56,
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primaryContainer,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Icon(
                                  activeSession == null
                                      ? Icons.play_arrow_rounded
                                      : Icons.bolt_rounded,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          PrimaryButton(
                            label: activeSession == null
                                ? strings.startWorkout
                                : strings.resumeWorkout,
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
                    const SizedBox(height: 18),
                    Text(
                      completedSessions.isEmpty
                          ? strings.recentHistory
                          : '${strings.recentHistory} · ${completedSessions.length}',
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 14),
                    if (completedSessions.isEmpty)
                      AuraCard(
                        child: Text(
                          strings.noClosedSessions,
                          style: theme.textTheme.bodyMedium,
                        ),
                      )
                    else
                      ...completedSessions.take(10).map(
                            (session) => Padding(
                              padding: const EdgeInsets.only(bottom: 14),
                              child: WorkoutSummaryCard(
                                session: session,
                                authorName: profile.name,
                                authorHandle: profile.name.toLowerCase(),
                                highlightColor: theme.colorScheme.primary,
                                estimatedCalories:
                                    CalorieEstimator.estimateWorkoutCalories(
                                  session: session,
                                  bodyWeightKg: profile.weightKg,
                                ),
                                onTap: () async {
                                  await Navigator.of(context).push(
                                    MaterialPageRoute<void>(
                                      builder: (_) => WorkoutSummaryDetailScreen(
                                        session: session,
                                        authorName: profile.name,
                                        bodyWeightKg: profile.weightKg,
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
                    if (completedSessions.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Text(
                        strings.homeInsights,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 14),
                      _HomeInsightCard(insight: homeInsight),
                    ],
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

class _HomeInsightCard extends StatelessWidget {
  const _HomeInsightCard({
    required this.insight,
  });

  final _HomeInsight insight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

    return AuraCard(
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(insight.lastTitle, style: theme.textTheme.headlineMedium),
          const SizedBox(height: 6),
          Text(strings.lastSession, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _WorkoutMetric(
                  label: strings.averageSession,
                  value: '${insight.averageSessionMinutes}m',
                ),
              ),
              Expanded(
                child: _WorkoutMetric(
                  label: strings.totalVolume,
                  value: '${insight.totalVolume.toStringAsFixed(0)} kg',
                ),
              ),
              Expanded(
                child: _WorkoutMetric(
                  label: strings.sets,
                  value: '${insight.totalSets}',
                ),
              ),
              Expanded(
                child: _WorkoutMetric(
                  label: strings.averageHeartRate,
                  value: insight.averageHeartRate == null
                      ? '--'
                      : '${insight.averageHeartRate}',
                  trailingIcon: Icons.favorite,
                  trailingColor: Colors.red,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeInsight {
  const _HomeInsight({
    required this.lastTitle,
    required this.averageSessionMinutes,
    required this.totalVolume,
    required this.totalSets,
    required this.averageHeartRate,
  });

  final String lastTitle;
  final int averageSessionMinutes;
  final double totalVolume;
  final int totalSets;
  final int? averageHeartRate;

  static _HomeInsight fromSessions(List<WorkoutSession> sessions) {
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
    final heartRateSamples = sessions
        .expand((session) => session.heartRateSamples)
        .toList(growable: false);
    final averageHeartRate = heartRateSamples.isEmpty
        ? null
        : (heartRateSamples.fold<int>(
                  0,
                  (sum, sample) => sum + sample.bpm,
                ) /
                heartRateSamples.length)
            .round();

    return _HomeInsight(
      lastTitle: sessions.isEmpty ? '' : sessions.first.title,
      averageSessionMinutes:
          sessions.isEmpty ? 0 : (totalMinutes / sessions.length).round(),
      totalVolume: totalVolume,
      totalSets: totalSets,
      averageHeartRate: averageHeartRate,
    );
  }
}

class WorkoutSummaryCard extends StatelessWidget {
  const WorkoutSummaryCard({
    super.key,
    required this.session,
    required this.authorName,
    required this.authorHandle,
    required this.highlightColor,
    this.estimatedCalories,
    this.onRename,
    this.onDelete,
    this.onTap,
  });

  final WorkoutSession session;
  final String authorName;
  final String authorHandle;
  final Color highlightColor;
  final int? estimatedCalories;
  final Future<void> Function(String title)? onRename;
  final Future<void> Function()? onDelete;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    final local = session.startedAt.toLocal();
    final date =
        '${local.day.toString().padLeft(2, '0')}/${local.month.toString().padLeft(2, '0')}/${local.year}';
    final durationMinutes = session.duration.inMinutes;
    final volume = session.totalVolume.toStringAsFixed(0);
    final averageHeartRate = session.averageHeartRate;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(28),
      child: AuraCard(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: highlightColor.withValues(alpha: 0.18),
                  child: Text(
                    authorName.isNotEmpty ? authorName[0].toUpperCase() : 'A',
                    style: theme.textTheme.titleMedium,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(authorHandle, style: theme.textTheme.titleMedium),
                      const SizedBox(height: 2),
                      Text(date, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  onSelected: (value) async {
                    if (value == 'rename' && onRename != null) {
                      await _showRenameSummaryDialog(
                        context,
                        initialTitle: session.title,
                        onSave: onRename!,
                      );
                      return;
                    }

                    if (value == 'delete' && onDelete != null) {
                      final confirmed = await _showDeleteSummaryDialog(
                        context,
                        title: session.title,
                      );
                      if (confirmed == true) {
                        await onDelete!();
                      }
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem<String>(
                      value: 'rename',
                      child: Text(strings.rename),
                    ),
                    PopupMenuItem<String>(
                      value: 'delete',
                      child: Text(strings.deleteWorkout),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              session.title,
              style: theme.textTheme.headlineMedium,
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: _WorkoutMetric(
                    label: strings.time,
                    value: '${durationMinutes}min',
                  ),
                ),
                Expanded(
                  child: _WorkoutMetric(
                    label: strings.volume,
                    value: '$volume kg',
                  ),
                ),
                Expanded(
                  child: _WorkoutMetric(
                    label: strings.sets,
                    value: '${session.totalSets}',
                  ),
                ),
                Expanded(
                  child: _WorkoutMetric(
                    label: strings.heartRateShort,
                    value: averageHeartRate == null ? '--' : '$averageHeartRate',
                    trailingIcon: Icons.favorite,
                    trailingColor: Colors.red,
                  ),
                ),
              ],
            ),
            if (estimatedCalories != null) ...[
              const SizedBox(height: 14),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withValues(alpha: 0.09),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department_rounded,
                      size: 18,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        strings.estimatedCalories,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      '$estimatedCalories ${strings.caloriesUnit}',
                      style: theme.textTheme.titleMedium,
                    ),
                  ],
                ),
              ),
            ],
            if (session.exercises.isNotEmpty) ...[
              const SizedBox(height: 16),
              ...session.exercises.take(3).map(
                (exercise) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    '${exercise.sets.length} ${strings.sets.toLowerCase()} · ${exercise.exerciseName}',
                    style: theme.textTheme.bodyLarge,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _WorkoutMetric extends StatelessWidget {
  const _WorkoutMetric({
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

Future<void> _showRenameSummaryDialog(
  BuildContext context, {
  required String initialTitle,
  required Future<void> Function(String title) onSave,
}) async {
  final controller = TextEditingController(text: initialTitle);
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(strings.renameWorkout),
        content: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: strings.title),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              await onSave(controller.text);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: Text(strings.save),
          ),
        ],
      );
    },
  );
}

Future<bool?> _showDeleteSummaryDialog(
  BuildContext context, {
  required String title,
}) {
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(strings.deleteWorkout),
        content: Text(strings.deleteWorkoutMessage(title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.delete),
          ),
        ],
      );
    },
  );
}

Future<void> _showSettingsSheet(BuildContext context, AppState appState) async {
  final profile = appState.profile!;
  final nameController = TextEditingController(text: profile.name);
  final heightController =
      TextEditingController(text: profile.heightCm.toStringAsFixed(0));
  final weightController =
      TextEditingController(text: profile.weightKg.toStringAsFixed(0));
  var selectedBodyType = profile.bodyType;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      final strings = AppStrings.of(appState.languageCode);
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.settings, style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 18),
                  Text(strings.profile, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: strings.name),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(labelText: strings.height),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration: InputDecoration(labelText: strings.weight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BodyType>(
                    initialValue: selectedBodyType,
                    items: BodyType.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.titleFor(appState.languageCode)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setModalState(() => selectedBodyType = value);
                    },
                    decoration: InputDecoration(labelText: strings.bodyType),
                  ),
                  const SizedBox(height: 20),
                  Text(strings.appearance, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: ThemeMode.values.map((mode) {
                      return ChoiceChip(
                        label: Text(mode.localizedLabel(strings)),
                        selected: appState.themeMode == mode,
                        onSelected: (_) async {
                          await appState.updateThemeMode(mode);
                        },
                      );
                    }).toList(growable: false),
                  ),
                  const SizedBox(height: 20),
                  Text(strings.language, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: Text(strings.spanish),
                        selected: appState.languageCode == 'es',
                        onSelected: (_) async {
                          await appState.updateLanguageCode('es');
                        },
                      ),
                      ChoiceChip(
                        label: Text(strings.english),
                        selected: appState.languageCode == 'en',
                        onSelected: (_) async {
                          await appState.updateLanguageCode('en');
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  PrimaryButton(
                    label: strings.saveChanges,
                    onPressed: () async {
                      final height = double.tryParse(heightController.text);
                      final weight = double.tryParse(weightController.text);
                      if (height == null || weight == null) {
                        return;
                      }
                      await appState.updateProfile(
                        name: nameController.text,
                        heightCm: height,
                        weightKg: weight,
                        bodyType: selectedBodyType,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}
