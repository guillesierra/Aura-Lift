import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/catalog/exercise_taxonomy.dart';

void main() {
  test('exercise seed has valid categories and metadata', () {
    final file = File('assets/seed/exercises_seed.json');
    final data = jsonDecode(file.readAsStringSync()) as List<dynamic>;

    final names = <String>{};
    for (final entry in data) {
      final exercise = entry as Map<String, dynamic>;
      final name = (exercise['name'] as String?)?.trim() ?? '';
      final group = (exercise['muscleGroup'] as String?)?.trim() ?? '';
      final equipment = (exercise['equipment'] as String?)?.trim() ?? '';
      final primary = exercise['primaryMuscles'] as List<dynamic>?;
      final difficulty = (exercise['difficulty'] as String?)?.trim() ?? '';
      final imagePrompt = (exercise['imagePrompt'] as String?)?.trim() ?? '';

      expect(name, isNotEmpty, reason: 'Exercise name cannot be empty');
      expect(names.add(name.toLowerCase()), isTrue,
          reason: 'Duplicate exercise name: $name');
      expect(
        ExerciseTaxonomy.muscleGroups.contains(group),
        isTrue,
        reason: 'Invalid muscle group for $name: $group',
      );
      expect(
        ExerciseTaxonomy.equipmentTypes.contains(equipment),
        isTrue,
        reason: 'Invalid equipment for $name: $equipment',
      );
      expect(primary, isNotNull, reason: 'Missing primaryMuscles for $name');
      expect(primary!.isNotEmpty, isTrue,
          reason: 'Empty primaryMuscles for $name');
      expect(
        ExerciseTaxonomy.difficulties.contains(difficulty),
        isTrue,
        reason: 'Invalid difficulty for $name: $difficulty',
      );
      expect(imagePrompt, isNotEmpty,
          reason: 'Missing imagePrompt for $name');
    }

    expect(data.length, greaterThanOrEqualTo(120));
  });
}
