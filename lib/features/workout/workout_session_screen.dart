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
    final techniqueTip = widget.appState.consumePendingExerciseTechniqueTip();
    if (cue == null && techniqueTip == null) {
      return;
    }

    unawaited(
      () async {
        if (cue != null) {
          await _voiceCoach.speakCue(
            cue,
            languageCode: widget.appState.languageCode,
          );
        }
        if (techniqueTip != null) {
          await _voiceCoach.speak(techniqueTip);
        }
      }(),
    );
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
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _WorkoutHeaderDelegate(
                      child: _WorkoutHeader(
                        title: active.title,
                        duration: active.duration,
                        totalVolume: active.totalVolume,
                        totalSets: active.totalSets,
                        onRename: (title) {
                          return appState.renameWorkoutSession(
                            sessionId: active.id,
                            title: title,
                          );
                        },
                        onBack: () => Navigator.of(context).pop(),
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
                        final lastSnapshot =
                            appState.lastPerformanceForExercise(
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
                          onAddSet: (reps, weightKg) async {
                            await appState.addSetToExercise(
                              sessionExerciseId: exercise.id,
                              reps: reps,
                              weightKg: weightKg,
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
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compactActions = constraints.maxWidth < 420;
            Future<void> finishAction() async {
              final confirmed = await _confirmFinishWorkout(context);
              if (confirmed != true) {
                return;
              }
              await appState.finishActiveWorkoutSession();
              unawaited(_voiceCoach.stop());
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            }

            void addExerciseAction() {
              _showExercisePickerSheet(
                context,
                appState: appState,
                activeSessionId: session?.id,
              );
            }

            return Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: FloatingActionButton(
                    heroTag: 'finish_workout_fab',
                    onPressed: finishAction,
                    backgroundColor: const Color(0xFFC62828),
                    foregroundColor: Colors.white,
                    tooltip: strings.finish,
                    child: const Icon(Icons.flag_outlined),
                  ),
                ),
                compactActions
                    ? FloatingActionButton(
                        heroTag: 'add_exercise_fab',
                        onPressed: addExerciseAction,
                        tooltip: strings.addExercise,
                        child: const Icon(Icons.add),
                      )
                    : FloatingActionButton.extended(
                        heroTag: 'add_exercise_fab',
                        onPressed: addExerciseAction,
                        label: Text(strings.addExercise),
                        icon: const Icon(Icons.add),
                      ),
              ],
            );
          },
        ),
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
  final HealthHeartRateService _heartRateService = HealthHeartRateService();
  bool _isSyncingHealth = false;
  String? _healthMessage;

  Future<void> _syncHeartRateFromHealth() async {
    final activeSession = widget.appState.activeSession;
    if (_isSyncingHealth || activeSession == null) {
      return;
    }

    setState(() {
      _isSyncingHealth = true;
      _healthMessage = null;
    });

    final strings = AppStrings.of(widget.appState.languageCode);
    final result = await _heartRateService.fetchHeartRateReadings(
      startTime: activeSession.startedAt.toLocal(),
      endTime: DateTime.now(),
    );
    if (!mounted) {
      return;
    }

    var message = switch (result.status) {
      HealthHeartRateStatus.unsupported => strings.heartHealthUnsupported,
      HealthHeartRateStatus.denied => strings.heartHealthDenied,
      HealthHeartRateStatus.failed => strings.heartHealthSyncFailed,
      HealthHeartRateStatus.success => null,
    };

    if (result.status == HealthHeartRateStatus.success) {
      final imported = await widget.appState.importHeartRateReadings(
        readings: result.readings,
        exerciseId: widget.appState.currentHeartRateExerciseId(),
      );
      message = imported == 0
          ? strings.heartHealthNoSamples
          : strings.heartHealthImported(imported);
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _isSyncingHealth = false;
      _healthMessage = message;
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
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
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
            strings.heartHealthCopy,
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: _isSyncingHealth ? null : _syncHeartRateFromHealth,
            icon: _isSyncingHealth
                ? SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: theme.colorScheme.primary,
                    ),
                  )
                : const Icon(Icons.favorite_outline),
            label: Text(
              _isSyncingHealth
                  ? strings.heartHealthSyncing
                  : strings.syncHeartHealth,
            ),
          ),
          if (_healthMessage != null) ...[
            const SizedBox(height: 8),
            Text(
              _healthMessage!,
              style: theme.textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

class _WorkoutHeaderDelegate extends SliverPersistentHeaderDelegate {
  const _WorkoutHeaderDelegate({
    required this.child,
  });

  static const _height = 148.0;

  final Widget child;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _WorkoutHeaderDelegate oldDelegate) {
    return oldDelegate.child != child;
  }
}

class _WorkoutHeader extends StatelessWidget {
  const _WorkoutHeader({
    required this.title,
    required this.duration,
    required this.totalVolume,
    required this.totalSets,
    required this.onRename,
    required this.onBack,
  });

  final String title;
  final Duration duration;
  final double totalVolume;
  final int totalSets;
  final Future<void> Function(String title) onRename;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    return AuraCard(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onBack,
                iconSize: 22,
                icon: const Icon(Icons.arrow_back_ios_new),
              ),
              Expanded(
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () async {
                    await _showRenameWorkoutDialog(
                      context,
                      initialTitle: title,
                      onSave: onRename,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleLarge,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: strings.duration,
                  value: _formatDuration(duration),
                  emphasized: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderMetric(
                  label: strings.volume,
                  value: '${totalVolume.toStringAsFixed(0)} kg',
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

  static String _formatDuration(Duration value) {
    final minutes = value.inMinutes;
    final seconds = value.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (minutes < 60) {
      return '${minutes}m ${seconds}s';
    }
    final hours = value.inHours;
    final remainingMinutes = minutes.remainder(60).toString().padLeft(2, '0');
    return '${hours}h ${remainingMinutes}m';
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
    this.emphasized = false,
  });

  final String label;
  final String value;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.44),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 3),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                color: emphasized ? theme.colorScheme.primary : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SessionExerciseCard extends StatefulWidget {
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
  final Future<void> Function(int reps, double weightKg) onAddSet;
  final Future<void> Function() onDeleteExercise;
  final Future<void> Function(String setId) onDeleteSet;

  @override
  State<_SessionExerciseCard> createState() => _SessionExerciseCardState();
}

class _SessionExerciseCardState extends State<_SessionExerciseCard> {
  static const _showHeartRateExerciseSelector = false;

  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightFocus = FocusNode();
  bool _isAddingSet = false;
  bool _isSavingSet = false;
  bool _isDraftSuggested = false;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_onDraftChanged);
    _repsController.addListener(_onDraftChanged);
  }

  void _onDraftChanged() {
    if (!_isDraftSuggested) {
      return;
    }
    setState(() {
      _isDraftSuggested = false;
    });
  }

  @override
  void dispose() {
    _weightController.removeListener(_onDraftChanged);
    _repsController.removeListener(_onDraftChanged);
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  void _startAddingSet() {
    final defaults = _defaultDraftValues();
    _weightController.text = defaults.weight;
    _repsController.text = defaults.reps;
    setState(() {
      _isAddingSet = true;
      _isDraftSuggested = defaults.isSuggestion;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _weightFocus.requestFocus();
      }
    });
  }

  Future<void> _saveDraftSet() async {
    final reps = int.tryParse(_repsController.text.trim());
    final normalizedWeight = _weightController.text.trim().replaceAll(',', '.');
    final weight = double.tryParse(normalizedWeight);
    if (reps == null || weight == null || reps <= 0 || weight < 0) {
      return;
    }

    setState(() => _isSavingSet = true);
    await widget.onAddSet(reps, weight);
    if (!mounted) {
      return;
    }

    _weightController.clear();
    _repsController.clear();
    setState(() {
      _isAddingSet = false;
      _isSavingSet = false;
      _isDraftSuggested = false;
    });
  }

  _DraftSetDefaults _defaultDraftValues() {
    final targetSetIndex = widget.exercise.sets.length;
    final previousSets = widget.lastSnapshot?.sets ?? const [];
    if (targetSetIndex >= 0 && targetSetIndex < previousSets.length) {
      final suggested = previousSets[targetSetIndex];
      return _DraftSetDefaults(
        weight: _formatNumber(suggested.weightKg),
        reps: suggested.reps.toString(),
        isSuggestion: true,
      );
    }

    if (widget.exercise.sets.isNotEmpty) {
      final last = widget.exercise.sets.last;
      return _DraftSetDefaults(
        weight: _formatNumber(last.weightKg),
        reps: last.reps.toString(),
        isSuggestion: false,
      );
    }

    if (previousSets.isNotEmpty) {
      final firstPrevious = previousSets.first;
      return _DraftSetDefaults(
        weight: _formatNumber(firstPrevious.weightKg),
        reps: firstPrevious.reps.toString(),
        isSuggestion: true,
      );
    }

    return const _DraftSetDefaults(weight: '', reps: '', isSuggestion: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    const showSelector = _showHeartRateExerciseSelector;
    return InkWell(
      borderRadius: BorderRadius.circular(AuraCard.radius),
      onTap: showSelector
          ? () async {
              await widget.onSelect();
            }
          : null,
      child: AuraCard(
        borderColor: showSelector && widget.isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.4),
        borderWidth: showSelector && widget.isSelected ? 2 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MuscleGroupIcon(
                    muscleGroup: widget.exercise.muscleGroup, size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.exerciseName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.exercise.muscleGroup,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (showSelector && widget.isSelected) ...[
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
                    await widget.onDeleteExercise();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SetTableHeader(strings: strings),
            const SizedBox(height: 8),
            ...widget.exercise.sets.asMap().entries.map(
                  (entry) => _SetRow(
                    setId: entry.value.id,
                    index: entry.key + 1,
                    previousSet: _previousSetText(entry.key),
                    reps: entry.value.reps,
                    weightKg: entry.value.weightKg,
                    onDelete: widget.onDeleteSet,
                  ),
                ),
            if (_isAddingSet)
              _DraftSetRow(
                index: widget.exercise.sets.length + 1,
                previousSet: _previousSetText(widget.exercise.sets.length),
                weightController: _weightController,
                repsController: _repsController,
                weightFocus: _weightFocus,
                isSuggested: _isDraftSuggested,
                isSaving: _isSavingSet,
                onSave: _saveDraftSet,
              )
            else if (widget.exercise.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  strings.noSetsYet,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _isAddingSet ? null : _startAddingSet,
                icon: const Icon(Icons.add),
                label: Text(
                  strings.isEnglish ? 'Add set' : 'Agregar serie',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _previousSetText(int index) {
    final sets = widget.lastSnapshot?.sets ?? const [];
    if (index < 0 || index >= sets.length) {
      return '-';
    }
    final set = sets[index];
    return '${_formatNumber(set.weightKg)}kg x ${set.reps}';
  }
}

class _DraftSetDefaults {
  const _DraftSetDefaults({
    required this.weight,
    required this.reps,
    required this.isSuggestion,
  });

  final String weight;
  final String reps;
  final bool isSuggestion;
}

String _formatNumber(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader({
    required this.strings,
  });

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        SizedBox(
            width: 42, child: Text(strings.set.toUpperCase(), style: style)),
        Expanded(
          flex: 3,
          child: Text(
            strings.isEnglish ? 'PREVIOUS' : 'ANTERIOR',
            style: style,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            'KG',
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            strings.reps.toUpperCase(),
            textAlign: TextAlign.center,
            style: style,
          ),
        ),
        const SizedBox(width: 46),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.setId,
    required this.index,
    required this.previousSet,
    required this.reps,
    required this.weightKg,
    required this.onDelete,
  });

  final String setId;
  final int index;
  final String previousSet;
  final int reps;
  final double weightKg;
  final Future<void> Function(String setId) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text('$index', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(previousSet, style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatNumber(weightKg),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$reps',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: 52,
            child: IconButton.filled(
              tooltip: strings.deleteSet,
              onPressed: () async {
                await onDelete(setId);
              },
              icon: const Icon(Icons.check_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftSetRow extends StatelessWidget {
  const _DraftSetRow({
    required this.index,
    required this.previousSet,
    required this.weightController,
    required this.repsController,
    required this.weightFocus,
    required this.isSuggested,
    required this.isSaving,
    required this.onSave,
  });

  final int index;
  final String previousSet;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final FocusNode weightFocus;
  final bool isSuggested;
  final bool isSaving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.48),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text('$index', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(previousSet, style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            flex: 2,
            child: _InlineNumberField(
              controller: weightController,
              focusNode: weightFocus,
              isSuggested: isSuggested,
              onSubmitted: (_) => onSave(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _InlineNumberField(
              controller: repsController,
              isSuggested: isSuggested,
              onSubmitted: (_) => onSave(),
            ),
          ),
          SizedBox(
            width: 52,
            child: IconButton.filledTonal(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNumberField extends StatelessWidget {
  const _InlineNumberField({
    required this.controller,
    required this.onSubmitted,
    required this.isSuggested,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onSubmitted;
  final bool isSuggested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: theme.textTheme.titleMedium?.copyWith(
        color: isSuggested
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurface,
      ),
      onSubmitted: onSubmitted,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
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

Future<bool?> _confirmFinishWorkout(BuildContext context) {
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(strings.finishWorkoutTitle),
        content: Text(strings.finishWorkoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.finish),
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
  String? selectedMuscleGroup;
  String? selectedEquipment;
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
                final muscleGroups = appState.canonicalMuscleGroups;
                final equipmentTypes = appState.canonicalEquipmentTypes;
                final filteredExercises = appState.exercises.where((exercise) {
                  final matchesGroup = selectedMuscleGroup == null ||
                      exercise.muscleGroup == selectedMuscleGroup;
                  final matchesEquipment = selectedEquipment == null ||
                      exercise.equipment == selectedEquipment;
                  if (query.isEmpty) {
                    return matchesGroup && matchesEquipment;
                  }
                  final matchesQuery =
                      exercise.name.toLowerCase().contains(query) ||
                          exercise.muscleGroup.toLowerCase().contains(query) ||
                          exercise.equipment.toLowerCase().contains(query);
                  return matchesQuery && matchesGroup && matchesEquipment;
                }).toList(growable: false);

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(strings.pickExercise,
                          style: theme.textTheme.headlineMedium),
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
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              initialValue: selectedMuscleGroup,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Grupo',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Todos los grupos'),
                                ),
                                ...muscleGroups.map(
                                  (group) => DropdownMenuItem<String?>(
                                    value: group,
                                    child: Text(group),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setModalState(() {
                                  selectedMuscleGroup = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String?>(
                              initialValue: selectedEquipment,
                              isExpanded: true,
                              decoration: const InputDecoration(
                                labelText: 'Equipamiento',
                              ),
                              items: [
                                const DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text('Todo'),
                                ),
                                ...equipmentTypes.map(
                                  (equipment) => DropdownMenuItem<String?>(
                                    value: equipment,
                                    child: Text(equipment),
                                  ),
                                ),
                              ],
                              onChanged: (value) {
                                setModalState(() {
                                  selectedEquipment = value;
                                });
                              },
                            ),
                          ),
                        ],
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
                          final lastSnapshot =
                              appState.lastPerformanceForExercise(
                            exercise.id,
                            excludingSessionId: activeSessionId,
                          );
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                                side: BorderSide(
                                    color: theme.colorScheme.outline),
                              ),
                              tileColor: theme.colorScheme.surface,
                              leading: MuscleGroupIcon(
                                muscleGroup: exercise.muscleGroup,
                                size: 50,
                              ),
                              title: Text(exercise.name),
                              subtitle: Text(
                                lastSnapshot == null
                                    ? '${exercise.muscleGroup} · ${exercise.equipment}'
                                    : '${exercise.muscleGroup} · ${exercise.equipment} · ${lastSnapshot.summaryFor(appState.languageCode)}',
                              ),
                              trailing: Icon(
                                disabled
                                    ? Icons.check_circle
                                    : Icons.add_circle,
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
                      Text(strings.customExercise,
                          style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      TextField(
                        controller: nameController,
                        decoration: InputDecoration(
                          labelText: strings.exerciseName,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedMuscleGroup,
                        isExpanded: true,
                        decoration:
                            InputDecoration(labelText: strings.muscleGroup),
                        items: muscleGroups
                            .map(
                              (group) => DropdownMenuItem<String>(
                                value: group,
                                child: Text(group),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setModalState(() {
                            selectedMuscleGroup = value;
                          });
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: selectedEquipment,
                        isExpanded: true,
                        decoration:
                            const InputDecoration(labelText: 'Equipamiento'),
                        items: equipmentTypes
                            .map(
                              (equipment) => DropdownMenuItem<String>(
                                value: equipment,
                                child: Text(equipment),
                              ),
                            )
                            .toList(growable: false),
                        onChanged: (value) {
                          setModalState(() {
                            selectedEquipment = value;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      PrimaryButton(
                        label: strings.createExercise,
                        onPressed: () async {
                          if (nameController.text.trim().isEmpty ||
                              selectedMuscleGroup == null ||
                              selectedEquipment == null) {
                            return;
                          }
                          await appState.addCustomExercise(
                            name: nameController.text,
                            muscleGroup: selectedMuscleGroup!,
                            equipment: selectedEquipment!,
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
