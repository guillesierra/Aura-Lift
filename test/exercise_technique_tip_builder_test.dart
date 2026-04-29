import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/audio/exercise_technique_tip_builder.dart';

void main() {
  test('returns bench-press specific tip in spanish', () {
    final tip = ExerciseTechniqueTipBuilder.tipFor(
      exerciseName: 'Press de banca con barra',
      muscleGroup: 'Pecho',
      languageCode: 'es',
    );

    expect(tip.toLowerCase(), contains('escapulas'));
  });

  test('returns deadlift-specific tip in english', () {
    final tip = ExerciseTechniqueTipBuilder.tipFor(
      exerciseName: 'Deadlift',
      muscleGroup: 'Espalda',
      languageCode: 'en',
    );

    expect(tip.toLowerCase(), contains('bar close'));
  });

  test('falls back to muscle-group guidance when keyword is unknown', () {
    final tip = ExerciseTechniqueTipBuilder.tipFor(
      exerciseName: 'Movimiento inventado',
      muscleGroup: 'Core',
      languageCode: 'es',
    );

    expect(tip.toLowerCase(), contains('zona media'));
  });
}
