import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../catalog/exercise_taxonomy.dart';
import '../models/exercise.dart';
import 'exercise_repository.dart';

class LocalExerciseRepository implements ExerciseRepository {
  static const _catalogKey = 'exercise_catalog_v1';

  @override
  Future<List<Exercise>> loadExercises() async {
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString(_catalogKey);
    if (cached != null && cached.isNotEmpty) {
      return _decodeExercises(cached);
    }

    final seed = await rootBundle.loadString('assets/seed/exercises_seed.json');
    await prefs.setString(_catalogKey, seed);
    return _decodeExercises(seed);
  }

  @override
  Future<void> addCustomExercise({
    required String name,
    required String muscleGroup,
    String? equipment,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    String? difficulty,
    String? imageAssetPath,
    String? imagePrompt,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadExercises();
    final normalizedMuscleGroup =
        ExerciseTaxonomy.canonicalMuscleGroup(muscleGroup);
    final normalizedEquipment = ExerciseTaxonomy.canonicalEquipment(
      equipment ?? ExerciseTaxonomy.inferEquipmentFromName(name),
    );
    final normalizedPrimary = primaryMuscles == null || primaryMuscles.isEmpty
        ? ExerciseTaxonomy.inferPrimaryMuscles(normalizedMuscleGroup)
        : primaryMuscles;
    final normalizedDifficulty = difficulty == null || difficulty.trim().isEmpty
        ? ExerciseTaxonomy.inferDifficulty(name)
        : difficulty.trim();

    final custom = Exercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      muscleGroup: normalizedMuscleGroup,
      equipment: normalizedEquipment,
      primaryMuscles: normalizedPrimary,
      secondaryMuscles: secondaryMuscles ?? const [],
      difficulty: normalizedDifficulty,
      imageAssetPath: null,
      imagePrompt: imagePrompt ??
          ExerciseTaxonomy.imagePrompt(
            name: name,
            muscleGroup: normalizedMuscleGroup,
            equipment: normalizedEquipment,
            primaryMuscles: normalizedPrimary,
          ),
      isCustom: true,
      createdAt: DateTime.now().toUtc(),
    );

    final updated = [...current, custom]
        .map((exercise) => exercise.toMap())
        .toList(growable: false);

    await prefs.setString(_catalogKey, jsonEncode(updated));
  }

  List<Exercise> _decodeExercises(String rawJson) {
    final list = jsonDecode(rawJson) as List<dynamic>;
    return list
        .map((item) => Exercise.fromMap(item as Map<String, dynamic>))
        .map(_normalizeExercise)
        .toList(growable: false);
  }

  Exercise _normalizeExercise(Exercise exercise) {
    final normalizedMuscleGroup =
        ExerciseTaxonomy.canonicalMuscleGroup(exercise.muscleGroup);
    final normalizedEquipment = ExerciseTaxonomy.canonicalEquipment(
      exercise.equipment == 'Otro'
          ? ExerciseTaxonomy.inferEquipmentFromName(exercise.name)
          : exercise.equipment,
    );
    final normalizedPrimary = exercise.primaryMuscles.isEmpty
        ? ExerciseTaxonomy.inferPrimaryMuscles(normalizedMuscleGroup)
        : exercise.primaryMuscles;
    final normalizedDifficulty = exercise.difficulty.trim().isEmpty
        ? ExerciseTaxonomy.inferDifficulty(exercise.name)
        : exercise.difficulty;

    return exercise.copyWith(
      muscleGroup: normalizedMuscleGroup,
      equipment: normalizedEquipment,
      primaryMuscles: normalizedPrimary,
      difficulty: normalizedDifficulty,
      keepImageAssetPath: false,
      imagePrompt: exercise.imagePrompt ??
          ExerciseTaxonomy.imagePrompt(
            name: exercise.name,
            muscleGroup: normalizedMuscleGroup,
            equipment: normalizedEquipment,
            primaryMuscles: normalizedPrimary,
          ),
    );
  }
}
