import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/muscle_group_icon.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/state/app_state.dart';

class ExerciseCatalogScreen extends StatefulWidget {
  const ExerciseCatalogScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<ExerciseCatalogScreen> createState() => _ExerciseCatalogScreenState();
}

class _ExerciseCatalogScreenState extends State<ExerciseCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final theme = Theme.of(context);
        final strings = AppStrings.of(widget.appState.languageCode);
        final query = _searchController.text.trim().toLowerCase();
        final exercises = widget.appState.exercises.where((exercise) {
          if (query.isEmpty) {
            return true;
          }
          return exercise.name.toLowerCase().contains(query) ||
              exercise.muscleGroup.toLowerCase().contains(query);
        }).toList(growable: false)
          ..sort((a, b) => a.name.compareTo(b.name));

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
                    child: Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            strings.exercises,
                            style: theme.textTheme.headlineMedium,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (_) => setState(() {}),
                      decoration: InputDecoration(
                        prefixIcon: const Icon(Icons.search_rounded),
                        labelText: strings.searchExercise,
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
                      itemBuilder: (context, index) {
                        final exercise = exercises[index];
                        return AuraCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            children: [
                              MuscleGroupIcon(
                                muscleGroup: exercise.muscleGroup,
                                size: 50,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      exercise.name,
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    Text(
                                      '${exercise.muscleGroup} · ${exercise.equipment}',
                                      style: theme.textTheme.bodySmall,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemCount: exercises.length,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
