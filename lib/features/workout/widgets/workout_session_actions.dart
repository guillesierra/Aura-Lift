import 'package:flutter/material.dart';

class WorkoutSessionActions extends StatelessWidget {
  const WorkoutSessionActions({
    super.key,
    required this.finishTooltip,
    required this.addExerciseLabel,
    required this.onFinishPressed,
    required this.onAddExercisePressed,
    this.compactBreakpoint = 420,
  });

  final String finishTooltip;
  final String addExerciseLabel;
  final Future<void> Function() onFinishPressed;
  final VoidCallback onAddExercisePressed;
  final double compactBreakpoint;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compactActions = constraints.maxWidth < compactBreakpoint;
        return Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 22),
              child: FloatingActionButton(
                heroTag: 'finish_workout_fab',
                onPressed: onFinishPressed,
                backgroundColor: const Color(0xFFC62828),
                foregroundColor: Colors.white,
                tooltip: finishTooltip,
                child: const Icon(Icons.flag_outlined),
              ),
            ),
            compactActions
                ? FloatingActionButton(
                    heroTag: 'add_exercise_fab',
                    onPressed: onAddExercisePressed,
                    tooltip: addExerciseLabel,
                    child: const Icon(Icons.add),
                  )
                : FloatingActionButton.extended(
                    heroTag: 'add_exercise_fab',
                    onPressed: onAddExercisePressed,
                    label: Text(addExerciseLabel),
                    icon: const Icon(Icons.add),
                  ),
          ],
        );
      },
    );
  }
}
