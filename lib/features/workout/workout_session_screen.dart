import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/audio/voice_coach.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/app_state.dart';
import 'widgets/workout_session_actions.dart';
import 'widgets/workout_session_content_slivers.dart';
import 'widgets/workout_session_dialogs.dart';
import 'widgets/workout_exercise_picker_sheet.dart';
import 'widgets/workout_session_exercise_list.dart';
import 'widgets/workout_session_header.dart';

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
    final strings = AppStrings.of(appState.languageCode);

    return Scaffold(
      body: TintedBackground(
        child: SafeArea(
          child: AnimatedBuilder(
            animation: appState,
            builder: (context, _) {
              final active = appState.activeSession;
              if (active == null) {
                return WorkoutSessionGlobalEmptyState(strings: strings);
              }

              return CustomScrollView(
                slivers: [
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: WorkoutSessionHeaderDelegate(
                      child: WorkoutSessionHeaderCard(
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
                  WorkoutSessionHeartRateSliver(appState: appState),
                  if (active.exercises.isEmpty)
                    WorkoutSessionEmptyExerciseSliver(strings: strings),
                  WorkoutSessionExerciseList(
                    appState: appState,
                    sessionId: active.id,
                    exercises: active.exercises,
                    selectedExerciseId: active.selectedExerciseId,
                  ),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: WorkoutSessionActions(
          finishTooltip: strings.finish,
          addExerciseLabel: strings.addExercise,
          onFinishPressed: () async {
            final confirmed = await confirmFinishWorkout(context);
            if (confirmed != true) {
              return;
            }
            await appState.finishActiveWorkoutSession();
            unawaited(_voiceCoach.stop());
            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          onAddExercisePressed: () {
            showWorkoutExercisePickerSheet(
              context,
              appState: appState,
              activeSessionId: session?.id,
            );
          },
        ),
      ),
    );
  }
}
