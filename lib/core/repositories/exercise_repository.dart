import '../models/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> loadExercises();
  Future<void> addCustomExercise({
    required String name,
    required String muscleGroup,
    String? equipment,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    String? difficulty,
    String? imageAssetPath,
    String? imagePrompt,
  });
}
