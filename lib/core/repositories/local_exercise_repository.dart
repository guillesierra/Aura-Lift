import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final current = await loadExercises();
    final custom = Exercise(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: name.trim(),
      muscleGroup: muscleGroup.trim(),
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
        .toList(growable: false);
  }
}
