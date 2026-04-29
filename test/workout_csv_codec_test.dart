import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/workout/workout_csv_codec.dart';

void main() {
  test('imports csv with spanish month format and bom header', () {
    const csv =
        '\ufeff"title","start_time","end_time","exercise_title","set_index","weight_kg","reps"\n'
        '"Entrenamiento nocturno","27 abr 2026, 18:27","27 abr 2026, 19:12","Press de Banca (Barra)",0,80,10\n'
        '"Entrenamiento nocturno","27 abr 2026, 18:27","27 abr 2026, 19:12","Press de Banca (Barra)",1,80,6\n'
        '"Entrenamiento nocturno","27 abr 2026, 18:27","27 abr 2026, 19:12","Curl de Biceps (Mancuerna)",0,44,6\n';

    final decoded = WorkoutCsvCodec.decode(csv);

    expect(decoded.report.sessions, 1);
    expect(decoded.report.exercises, 2);
    expect(decoded.report.sets, 3);
    expect(decoded.sessions, hasLength(1));
    expect(decoded.sessions.first.title, 'Entrenamiento nocturno');
    expect(decoded.sessions.first.totalSets, 3);
  });
}
