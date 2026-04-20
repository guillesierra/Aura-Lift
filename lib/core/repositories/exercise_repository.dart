import '../models/exercise.dart';

abstract class ExerciseRepository {
  Future<List<Exercise>> loadExercises();
  Future<void> addCustomExercise({
    required String name,
    required String muscleGroup,
  });
}
