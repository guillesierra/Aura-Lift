import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';
import '../../../core/models/session_exercise.dart';
import '../../../core/state/app_state.dart';
import 'workout_session_dialogs.dart';
import 'workout_session_exercise_card.dart';

class WorkoutSessionExerciseList extends StatelessWidget {
  const WorkoutSessionExerciseList({
    super.key,
    required this.appState,
    required this.sessionId,
    required this.exercises,
    required this.selectedExerciseId,
  });

  final AppState appState;
  final String sessionId;
  final List<SessionExercise> exercises;
  final String? selectedExerciseId;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(appState.languageCode);
    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 120),
      sliver: SliverList.separated(
        itemBuilder: (context, index) {
          final exercise = exercises[index];
          final lastSnapshot = appState.lastPerformanceForExercise(
            exercise.exerciseId,
            excludingSessionId: sessionId,
          );
          return WorkoutSessionExerciseCard(
            exercise: exercise,
            isSelected: selectedExerciseId == exercise.exerciseId,
            lastSnapshot: lastSnapshot,
            onSelect: () {
              return appState.selectHeartRateExercise(exercise.exerciseId);
            },
            onAddSet: (reps, weightKg) async {
              await appState.addSetToExercise(
                sessionExerciseId: exercise.id,
                reps: reps,
                weightKg: weightKg,
              );
            },
            onDeleteExercise: () async {
              final confirmed = await confirmWorkoutDelete(
                context,
                title: strings.deleteExerciseTitle,
                message: strings.deleteExerciseMessage(
                  exercise.exerciseName,
                ),
              );
              if (confirmed == true) {
                await appState.deleteExerciseFromActiveSession(exercise.id);
              }
            },
            onDeleteSet: (setId) async {
              final confirmed = await confirmWorkoutDelete(
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
        separatorBuilder: (context, index) => const SizedBox(height: 14),
        itemCount: exercises.length,
      ),
    );
  }
}
