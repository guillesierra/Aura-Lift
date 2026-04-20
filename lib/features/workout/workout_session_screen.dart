import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/primary_button.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/models/exercise.dart';
import '../../core/models/exercise_history_snapshot.dart';
import '../../core/models/session_exercise.dart';
import '../../core/state/app_state.dart';

class WorkoutSessionScreen extends StatelessWidget {
  const WorkoutSessionScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final session = appState.activeSession;
    final theme = Theme.of(context);

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
                            'No hay una sesion activa',
                            style: theme.textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Vuelve a inicio y crea un entreno nuevo.',
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
                          if (context.mounted) {
                            Navigator.of(context).pop();
                          }
                        },
                      ),
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
                                'Empieza por un ejercicio',
                                style: theme.textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Anade ejercicios desde el catalogo y registra tus series con peso y repeticiones.',
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
                          lastSnapshot: lastSnapshot,
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
                              title: 'Eliminar ejercicio',
                              message:
                                  'Se borrara "${
                                      exercise.exerciseName
                                    }" y todas sus series registradas en esta sesion.',
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
                              title: 'Eliminar serie',
                              message:
                                  'Se borrara esta serie del ejercicio "${exercise.exerciseName}".',
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
        label: const Text('Anadir ejercicio'),
        icon: const Icon(Icons.add),
      ),
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
                      label: const Text('Editar nombre'),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () async {
                  await onFinish();
                },
                child: const Text('Finalizar'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Inicio ${_formatTime(startedAt)}',
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _HeaderMetric(
                  label: 'Ejercicios',
                  value: '$totalExercises',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _HeaderMetric(
                  label: 'Series',
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

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Nombre del entrenamiento'),
        content: TextField(
          controller: controller,
          textCapitalization: TextCapitalization.sentences,
          decoration: const InputDecoration(
            labelText: 'Titulo',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () async {
              await onSave(controller.text);
              if (context.mounted) {
                Navigator.of(context).pop();
              }
            },
            child: const Text('Guardar'),
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
    required this.lastSnapshot,
    required this.onAddSet,
    required this.onDeleteExercise,
    required this.onDeleteSet,
  });

  final SessionExercise exercise;
  final ExerciseHistorySnapshot? lastSnapshot;
  final Future<void> Function() onAddSet;
  final Future<void> Function() onDeleteExercise;
  final Future<void> Function(String setId) onDeleteSet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                      exercise.exerciseName,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      exercise.muscleGroup,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Eliminar ejercicio',
                onPressed: () async {
                  await onDeleteExercise();
                },
                icon: const Icon(Icons.delete_outline),
              ),
              FilledButton.tonalIcon(
                onPressed: onAddSet,
                icon: const Icon(Icons.add),
                label: const Text('Serie'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _LastTimeStrip(snapshot: lastSnapshot),
          const SizedBox(height: 18),
          if (exercise.sets.isEmpty)
            Text(
              'Sin series registradas todavia.',
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
    );
  }
}

class _LastTimeStrip extends StatelessWidget {
  const _LastTimeStrip({required this.snapshot});

  final ExerciseHistorySnapshot? snapshot;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasData = snapshot != null;
    final dateText = hasData
        ? _formatDate(snapshot!.sessionDate)
        : 'Sin historial';

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
            'Ultima vez',
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 6),
          Text(dateText, style: theme.textTheme.bodyMedium),
          const SizedBox(height: 8),
          Text(
            hasData ? snapshot!.summary : 'Este ejercicio aun no tiene registros.',
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
          Text('Serie $index', style: theme.textTheme.titleMedium),
          const Spacer(),
          Text('$reps reps', style: theme.textTheme.bodyLarge),
          const SizedBox(width: 16),
          Text('$weight kg', style: theme.textTheme.bodyLarge),
          const SizedBox(width: 8),
          IconButton(
            tooltip: 'Eliminar serie',
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
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Eliminar'),
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

  await showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Registrar serie'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: repsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Repeticiones'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: weightController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(labelText: 'Peso (kg)'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
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
            child: const Text('Guardar'),
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
  final nameController = TextEditingController();
  final muscleController = TextEditingController();

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
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
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Anadir ejercicio', style: theme.textTheme.headlineMedium),
                  const SizedBox(height: 8),
                  Text(
                    'Selecciona del catalogo o crea uno nuevo para esta sesion.',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 18),
                  ...appState.exercises.map(
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
                          title: Text(exercise.name),
                          subtitle: Text(
                            lastSnapshot == null
                                ? exercise.muscleGroup
                                : '${exercise.muscleGroup} · ${lastSnapshot.summary}',
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
                  Text('Ejercicio personalizado', style: theme.textTheme.titleLarge),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del ejercicio',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: muscleController,
                    decoration: const InputDecoration(
                      labelText: 'Grupo muscular',
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryButton(
                    label: 'Crear ejercicio',
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
}
