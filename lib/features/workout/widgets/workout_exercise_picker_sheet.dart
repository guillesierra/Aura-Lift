import 'package:flutter/material.dart';

import '../../../core/design_system/widgets/muscle_group_icon.dart';
import '../../../core/design_system/widgets/primary_button.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/state/app_state.dart';

Future<void> showWorkoutExercisePickerSheet(
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
                              decoration: InputDecoration(
                                labelText: strings.muscleGroup,
                              ),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(strings.allMuscleGroups),
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
                              decoration: InputDecoration(
                                labelText: strings.equipment,
                              ),
                              items: [
                                DropdownMenuItem<String?>(
                                  value: null,
                                  child: Text(strings.allEquipment),
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
                        decoration: InputDecoration(
                          labelText: strings.equipment,
                        ),
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
