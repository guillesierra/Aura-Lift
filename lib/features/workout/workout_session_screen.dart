import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audio/voice_coach.dart';
import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/muscle_group_icon.dart';
import '../../core/design_system/widgets/primary_button.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/health/apple_health_heart_rate_service.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/exercise_history_snapshot.dart';
import '../../core/models/heart_rate_coach_cue.dart';
import '../../core/models/heart_rate_status.dart';
import '../../core/models/session_exercise.dart';
import '../../core/state/app_state.dart';

class WorkoutSessionScreen extends StatefulWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WorkoutSessionScreen> createState() => _WorkoutSessionScreenState();
}

class _WorkoutSessionScreenState extends State<WorkoutSessionScreen> {
  late final VoiceCoach _voiceCoach;

  @override
  void initState() {
    super.initState();
    _voiceCoach = VoiceCoach();
    widget.appState.addListener(_handleAppStateChanged);
  }

  @override
  void didUpdateWidget(covariant WorkoutSessionScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.appState == widget.appState) {
      return;
    }

    oldWidget.appState.removeListener(_handleAppStateChanged);
    widget.appState.addListener(_handleAppStateChanged);
  }

  @override
  void dispose() {
    widget.appState.removeListener(_handleAppStateChanged);
    unawaited(_voiceCoach.dispose());
    super.dispose();
  }

  void _handleAppStateChanged() {
    final cue = widget.appState.consumePendingHeartRateCoachCue();
    if (cue == null) {
      return;
    }

    unawaited(_voiceCoach.speak(cue.audioMessageFor(widget.appState.languageCode)));
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final session = appState.activeSession;
    final theme = Theme.of(context);
    final strings = AppStrings.of(appState.languageCode);

    return Scaffold(
      body: TintedBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final active = appState.activeSession;
              if (active == null) {
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

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: _WorkoutHeader(
                        title: active.title,
                        startedAt: active.startedAt,
                        totalExercises: active.exercises.length,
                        totalSets: active.totalSets,
                        onRename: (title) {
                          return appState.renameWorkoutSession(
                            sessionId: active.id,
                            title: title,
                          );
                        },
                        onBack: () => Navigator.of(context).pop(),
                        onFinish: () async {
                          await appState.finishActiveWorkoutSession();
                          unawaited(_voiceCoach.stop());
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                      child: _HeartRatePanel(appState: appState),
                    ),
                  ),
                  if (active.exercises.isEmpty)
                    SliverToBoxAdapter(
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
                    ),
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
                    sliver: SliverList.separated(
                      itemBuilder: (context, index) {
                        final exercise = active.exercises[index];
                        final lastSnapshot = appState.lastPerformanceForExercise(
                          exercise.exerciseId,
                          excludingSessionId: active.id,
                        );
                        return _SessionExerciseCard(
                          exercise: exercise,
                          isSelected:
                              active.selectedExerciseId == exercise.exerciseId,
                          lastSnapshot: lastSnapshot,
                          onSelect: () {
                            return appState.selectHeartRateExercise(
                              exercise.exerciseId,
                            );
                          },
                          onAddSet: () async {
                            await _showAddSetDialog(
                              context,
                              onSubmitted: (reps, weightKg) {
                                return appState.addSetToExercise(
                                  sessionExerciseId: exercise.id,
                                  reps: reps,
                                  weightKg: weightKg,
                                );
                              },
                            );
                          },
                          onDeleteExercise: () async {
                            final confirmed = await _confirmDelete(
                              context,
                              title: strings.deleteExerciseTitle,
                              message: strings.deleteExerciseMessage(
                                exercise.exerciseName,
                              ),
                            );
                            if (confirmed == true) {
                              await appState.deleteExerciseFromActiveSession(
                                exercise.id,
                              );
                            }
                          },
                          onDeleteSet: (setId) async {
                            final confirmed = await _confirmDelete(
                              context,
                              title: strings.deleteSetTitle,
                              message: strings.deleteSetMessage(
                                exercise.exerciseName,
                              ),
                            );
                            if (confirmed == true) {
                              await appState.deleteSetFromExercise(
                                sessionExerciseId: exercise.id,
                                setId: setId,
                              );
                            }
                          },
                        );
                      },
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemCount: active.exercises.length,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          _showExercisePickerSheet(
            context,
            appState: appState,
            activeSessionId: session?.id,
          );
        },
        label: Text(strings.addExercise),
        icon: const Icon(Icons.add),
      ),
    );
  }
}

class _HeartRatePanel extends StatefulWidget {
  const _HeartRatePanel({
    required this.appState,
  });

  final AppState appState;

  @override
  State<_HeartRatePanel> createState() => _HeartRatePanelState();
}

class _HeartRatePanelState extends State<_HeartRatePanel> {
  final AppleHealthHeartRateService _appleHealthHeartRateService =
      AppleHealthHeartRateService();
  bool _isSyncingAppleHealth = false;
  String? _appleHealthMessage;

  Future<void> _syncAppleHealthHeartRate() async {
    final activeSession = widget.appState.activeSession;
    if (_isSyncingAppleHealth || activeSession == null) {
      return;
    }

    setState(() {
      _isSyncingAppleHealth = true;
      _appleHealthMessage = null;
    });

    final strings = AppStrings.of(widget.appState.languageCode);
    final result = await _appleHealthHeartRateService.fetchHeartRateReadings(
      startTime: activeSession.startedAt.toLocal(),
      endTime: DateTime.now(),
    );
    if (!mounted) {
      return;
    }

    var message = switch (result.status) {
      AppleHealthHeartRateStatus.unsupported => strings.appleHealthUnsupported,
      AppleHealthHeartRateStatus.denied => strings.appleHealthDenied,
      AppleHealthHeartRateStatus.failed => strings.appleHealthSyncFailed,
      AppleHealthHeartRateStatus.success => null,
    };

    if (result.status == AppleHealthHeartRateStatus.success) {
      final imported = await widget.appState.importHeartRateReadings(
        readings: result.readings,
        exerciseId: widget.appState.currentHeartRateExerciseId(),
      );
      message = imported == 0
          ? strings.appleHealthNoSamples
          : strings.appleHealthImported(imported);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSyncingAppleHealth = false;
      _appleHealthMessage = message;
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    final theme = Theme.of(context);
    final strings = AppStrings.of(appState.languageCode);
    final samples = appState.recentHeartRateSamples();
    final currentStatus = appState.currentHeartRateStatus();
    final currentBpm = samples.isEmpty ? null : samples.last.bpm;
    final baseline = appState.currentHeartRateBaseline();
    final threshold = baseline == null ? null : (baseline * 1.15).round();
    final trackedExerciseName = appState.currentHeartRateExerciseName();
    final trackedExerciseId = appState.currentHeartRateExerciseId();

    return AuraCard(
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
                      strings.heartRate,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      currentBpm == null
                          ? strings.noHeartRateSamplesYet
                          : '$currentBpm ${strings.heartRateUnit} · ${currentStatus.titleFor(appState.languageCode)}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Text(
                  currentBpm == null ? '--' : '$currentBpm',
                  style: theme.textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            currentStatus.descriptionFor(appState.languageCode),
            style: theme.textTheme.bodyMedium,
          ),
          if (trackedExerciseName != null) ...[
            const SizedBox(height: 12),
            Text(
              strings.selectedExerciseForHeartRate(trackedExerciseName),
              style: theme.textTheme.bodySmall,
            ),
          ],
          if (baseline != null) ...[
            const SizedBox(height: 12),
            Text(
              strings.heartRateBaseline(baseline, threshold ?? baseline),
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Text(
            strings.appleHealthHeartRateCopy,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed:
                _isSyncingAppleHealth ? null : _syncAppleHealthHeartRate,
            icon: _isSyncingAppleHealth
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.watch_outlined),
            label: Text(
              _isSyncingAppleHealth
                  ? strings.appleHealthSyncing
                  : strings.syncAppleHealth,
            ),
          ),
          if (_appleHealthMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _appleHealthMessage!,
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _HeartRateQuickButton(
                label: '95',
                onTap: () => appState.recordHeartRateSample(
                  bpm: 95,
                  exerciseId: trackedExerciseId,
                ),
              ),
              _HeartRateQuickButton(
                label: '110',
                onTap: () => appState.recordHeartRateSample(
                  bpm: 110,
                  exerciseId: trackedExerciseId,
                ),
              ),
              _HeartRateQuickButton(
                label: '130',
                onTap: () => appState.recordHeartRateSample(
                  bpm: 130,
                  exerciseId: trackedExerciseId,
                ),
              ),
              _HeartRateQuickButton(
                label: '150',
                onTap: () => appState.recordHeartRateSample(
                  bpm: 150,
                  exerciseId: trackedExerciseId,
                ),
              ),
            ],
          ),
          if (samples.isNotEmpty) ...[
            const SizedBox(height: 16),
            Text(strings.recentSamples, style: theme.textTheme.titleMedium),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: samples
                  .map(
                    (sample) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Text(
                        '${sample.bpm} ${strings.heartRateUnit}',
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ),
    );
  }
}

class _HeartRateQuickButton extends StatelessWidget {
  const _HeartRateQuickButton({
    required this.label,
    required this.onTap,
  });

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    return ActionChip(
      label: Text('$label ${strings.heartRateUnit}'),
      onPressed: onTap,
    );
  }
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({
    required this.title,
    required this.startedAt,
    required this.totalExercises,
    required this.totalSets,
    required this.onRename,
    required this.onBack,
    required this.onFinish,
  });

  final String title;
  final DateTime startedAt;
  final int totalExercises;
  final int totalSets;
  final Future<void> Function(String title) onRename;
  final VoidCallback onBack;
  final Future<void> Function() onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 2),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        alignment: Alignment.centerLeft,
                      ),
                      onPressed: () async {
                        await _showRenameWorkoutDialog(
                          context,
                          initialTitle: title,
                          onSave: onRename,
                        );
                      },
                      icon: const Icon(Icons.edit_outlined, size: 16),
                      label: Text(strings.editName),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await onFinish();
                },
                child: Text(strings.finish),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            strings.workoutStartTime(_formatTime(startedAt)),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: strings.exercisesLabel,
                  value: '$totalExercises',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderMetric(
                  label: strings.sets,
                  value: '$totalSets',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static String _formatTime(DateTime value) {
    final hour = value.toLocal().hour.toString().padLeft(2, '0');
    final minute = value.toLocal().minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

Future<void> _showRenameWorkoutDialog(
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
        title: Text(strings.workoutName),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            labelText: strings.title,
          ),
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

class _HeaderMetric extends StatelessWidget {
  const _HeaderMetric({
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
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 6),
          Text(value, style: theme.textTheme.headlineMedium),
        ],
      ),
    );
  }
}

class _SessionExerciseCard extends StatelessWidget {
  const _SessionExerciseCard({
    required this.exercise,
    required this.isSelected,
    required this.lastSnapshot,
    required this.onSelect,
    required this.onAddSet,
    required this.onDeleteExercise,
    required this.onDeleteSet,
  });

  final SessionExercise exercise;
  final bool isSelected;
  final ExerciseHistorySnapshot? lastSnapshot;
  final Future<void> Function() onSelect;
  final Future<void> Function() onAddSet;
  final Future<void> Function() onDeleteExercise;
  final Future<void> Function(String setId) onDeleteSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    return InkWell(
      borderRadius: BorderRadius.circular(28),
      onTap: () async {
        await onSelect();
      },
      child: AuraCard(
        borderColor: isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.4),
        borderWidth: isSelected ? 2 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MuscleGroupIcon(muscleGroup: exercise.muscleGroup, size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exercise.exerciseName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        exercise.muscleGroup,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (isSelected) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            strings.selectedExerciseForHeartRateBadge,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: strings.deleteExercise,
                  onPressed: () async {
                    await onDeleteExercise();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
                FilledButton.tonalIcon(
                  onPressed: onAddSet,
                  icon: const Icon(Icons.add),
                  label: Text(strings.set),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _LastTimeStrip(snapshot: lastSnapshot),
            const SizedBox(height: 18),
            if (exercise.sets.isEmpty)
              Text(
                strings.noSetsYet,
                style: theme.textTheme.bodyMedium,
              )
            else
              ...exercise.sets.asMap().entries.map(
                (entry) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _SetRow(
                    setId: entry.value.id,
                    index: entry.key + 1,
                    reps: entry.value.reps,
                    weightKg: entry.value.weightKg,
                    onDelete: onDeleteSet,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _LastTimeStrip extends StatelessWidget {
  const _LastTimeStrip({required this.snapshot});

  final ExerciseHistorySnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    final hasData = snapshot != null;
    final dateText = hasData
        ? _formatDate(snapshot!.sessionDate)
        : strings.noHistoryForExercise;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.lastTime,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(dateText, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            hasData ? snapshot!.summary : strings.noRecordsForExercise,
            style: theme.textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }

  static String _formatDate(DateTime value) {
    final local = value.toLocal();
    final day = local.day.toString().padLeft(2, '0');
    final month = local.month.toString().padLeft(2, '0');
    final year = local.year.toString();
    return '$day/$month/$year';
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.setId,
    required this.index,
    required this.reps,
    required this.weightKg,
    required this.onDelete,
  });

  final String setId;
  final int index;
  final int reps;
  final double weightKg;
  final Future<void> Function(String setId) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    final weight = weightKg % 1 == 0
        ? weightKg.toStringAsFixed(0)
        : weightKg.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Text(strings.setLabel(index), style: theme.textTheme.titleMedium),
          const Spacer(),
          Text(strings.repsLabel(reps), style: theme.textTheme.bodyLarge),
          const SizedBox(width: 16),
          Text('$weight kg', style: theme.textTheme.bodyLarge),
          const SizedBox(width: 8),
          IconButton(
            tooltip: strings.deleteSet,
            visualDensity: VisualDensity.compact,
            onPressed: () async {
              await onDelete(setId);
            },
            icon: Icon(
              Icons.close,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> _confirmDelete(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
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

Future<void> _showAddSetDialog(
  BuildContext context, {
  required Future<void> Function(int reps, double weightKg) onSubmitted,
}) async {
  final repsController = TextEditingController();
  final weightController = TextEditingController();
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(strings.logSet),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: strings.reps),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(labelText: strings.weightKgLabel),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () async {
              final reps = int.tryParse(repsController.text);
              final weight = double.tryParse(weightController.text);
              if (reps == null || weight == null) {
                return;
              }
              await onSubmitted(reps, weight);
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

Future<void> _showExercisePickerSheet(
  BuildContext context, {
  required AppState appState,
  required String? activeSessionId,
}) async {
  final searchController = TextEditingController();
  final nameController = TextEditingController();
  final muscleController = TextEditingController();
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      return StatefulBuilder(
        builder: (context, setModalState) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              12,
              20,
              20 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: AnimatedBuilder(
              animation: appState,
              builder: (context, _) {
                final activeIds = appState.activeSession?.exercises
                        .map((item) => item.exerciseId)
                        .toSet() ??
                    <String>{};
                final query = searchController.text.trim().toLowerCase();
                final filteredExercises = appState.exercises.where((exercise) {
                  if (query.isEmpty) {
                    return true;
                  }
                  return exercise.name.toLowerCase().contains(query) ||
                      exercise.muscleGroup.toLowerCase().contains(query);
                }).toList(growable: false);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.pickExercise, style: theme.textTheme.headlineMedium),
                      const SizedBox(height: 8),
                      Text(
                        strings.pickExerciseCopy,
                        style: theme.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 18),
                      TextField(
                        controller: searchController,
                        onChanged: (_) {
                          setModalState(() {});
                        },
                        decoration: InputDecoration(
                          labelText: strings.searchExercise,
                          prefixIcon: const Icon(Icons.search),
                        ),
                      ),
                      const SizedBox(height: 14),
                      if (filteredExercises.isEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            strings.noExerciseMatches,
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      ...filteredExercises.map(
                        (exercise) {
                          final disabled = activeIds.contains(exercise.id);
                          final lastSnapshot = appState.lastPerformanceForExercise(
                            exercise.id,
                            excludingSessionId: activeSessionId,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(color: theme.colorScheme.outline),
                              ),
                              tileColor: theme.colorScheme.surface,
                              leading: MuscleGroupIcon(
                                muscleGroup: exercise.muscleGroup,
                                size: 50,
                              ),
                              title: Text(exercise.name),
                              subtitle: Text(
                                lastSnapshot == null
                                    ? exercise.muscleGroup
                                    : '${exercise.muscleGroup} · ${lastSnapshot.summaryFor(appState.languageCode)}',
                              ),
                              trailing: Icon(
                                disabled ? Icons.check_circle : Icons.add_circle,
                              ),
                              onTap: disabled
                                  ? null
                                  : () async {
                                      await appState.addExerciseToActiveSession(
                                        exercise,
                                      );
                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 18),
                      Text(strings.customExercise, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: strings.exerciseName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: muscleController,
                        decoration: InputDecoration(
                          labelText: strings.muscleGroup,
                        ),
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: strings.createExercise,
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              muscleController.text.trim().isEmpty) {
                            return;
                          }
                          await appState.addCustomExercise(
                            name: nameController.text,
                            muscleGroup: muscleController.text,
                          );
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          );
        },
      );
    },
  );
}
