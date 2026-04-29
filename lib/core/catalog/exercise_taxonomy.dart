class ExerciseTaxonomy {
  const ExerciseTaxonomy._();

  static const List<String> muscleGroups = [
    'Pecho',
    'Espalda',
    'Hombros',
    'Biceps',
    'Triceps',
    'Piernas',
    'Gemelos',
    'Core',
    'Cardio',
    'Trapecio',
  ];

  static const List<String> equipmentTypes = [
    'Barra',
    'Mancuernas',
    'Polea',
    'Maquina',
    'Peso corporal',
    'Kettlebell',
    'Banda',
    'Cardio machine',
    'Otro',
  ];

  static const List<String> difficulties = [
    'Principiante',
    'Intermedio',
    'Avanzado',
  ];

  static String canonicalMuscleGroup(String raw) {
    final key = _normalize(raw);
    switch (key) {
      case 'pecho':
        return 'Pecho';
      case 'espalda':
        return 'Espalda';
      case 'hombros':
      case 'hombro':
        return 'Hombros';
      case 'biceps':
      case 'bicep':
      case 'bíceps':
        return 'Biceps';
      case 'triceps':
      case 'tricep':
      case 'tríceps':
        return 'Triceps';
      case 'piernas':
      case 'pierna':
      case 'gluteos':
      case 'gluteo':
      case 'gluteosisquios':
      case 'gluteoscuadriceps':
        return 'Piernas';
      case 'gemelos':
      case 'pantorrilla':
      case 'pantorrillas':
        return 'Gemelos';
      case 'core':
      case 'abdominales':
      case 'abdominal':
      case 'abs':
        return 'Core';
      case 'cardio':
      case 'aerobico':
      case 'aeróbico':
        return 'Cardio';
      case 'trapecio':
      case 'trapecios':
        return 'Trapecio';
      default:
        return 'Core';
    }
  }

  static String canonicalEquipment(String raw) {
    final key = _normalize(raw);
    if (key.isEmpty) {
      return 'Otro';
    }
    if (key.contains('barra') || key.contains('smith')) {
      return 'Barra';
    }
    if (key.contains('mancuerna') || key.contains('dumbbell')) {
      return 'Mancuernas';
    }
    if (key.contains('polea') || key.contains('cable')) {
      return 'Polea';
    }
    if (key.contains('maquina') || key.contains('prensa')) {
      return 'Maquina';
    }
    if (key.contains('peso corporal') ||
        key.contains('dominada') ||
        key.contains('plancha') ||
        key.contains('flexion') ||
        key.contains('burpee')) {
      return 'Peso corporal';
    }
    if (key.contains('kettlebell')) {
      return 'Kettlebell';
    }
    if (key.contains('banda')) {
      return 'Banda';
    }
    if (key.contains('cinta') ||
        key.contains('bike') ||
        key.contains('eliptica') ||
        key.contains('ergometro') ||
        key.contains('escaladora')) {
      return 'Cardio machine';
    }
    return 'Otro';
  }

  static String inferEquipmentFromName(String name) {
    final key = _normalize(name);
    if (key.contains('barra') || key.contains('smith')) {
      return 'Barra';
    }
    if (key.contains('mancuerna') || key.contains('mancuernas')) {
      return 'Mancuernas';
    }
    if (key.contains('polea') || key.contains('cable')) {
      return 'Polea';
    }
    if (key.contains('maquina') || key.contains('prensa')) {
      return 'Maquina';
    }
    if (key.contains('cinta') ||
        key.contains('bike') ||
        key.contains('eliptica') ||
        key.contains('ergometro') ||
        key.contains('escaladora')) {
      return 'Cardio machine';
    }
    if (key.contains('kettlebell')) {
      return 'Kettlebell';
    }
    if (key.contains('banda')) {
      return 'Banda';
    }
    return 'Peso corporal';
  }

  static String inferDifficulty(String name) {
    final key = _normalize(name);
    if (key.contains('dominadas') ||
        key.contains('peso muerto') ||
        key.contains('sentadilla frontal') ||
        key.contains('burpees')) {
      return 'Avanzado';
    }
    if (key.contains('maquina') ||
        key.contains('cinta') ||
        key.contains('curl') ||
        key.contains('press') ||
        key.contains('remo')) {
      return 'Intermedio';
    }
    return 'Principiante';
  }

  static List<String> inferPrimaryMuscles(String muscleGroup) {
    switch (canonicalMuscleGroup(muscleGroup)) {
      case 'Pecho':
        return const ['Pectoral mayor'];
      case 'Espalda':
        return const ['Dorsal ancho', 'Romboides'];
      case 'Hombros':
        return const ['Deltoides'];
      case 'Biceps':
        return const ['Biceps braquial'];
      case 'Triceps':
        return const ['Triceps braquial'];
      case 'Piernas':
        return const ['Cuadriceps', 'Isquiotibiales', 'Gluteos'];
      case 'Gemelos':
        return const ['Gemelos'];
      case 'Core':
        return const ['Recto abdominal', 'Oblicuos'];
      case 'Cardio':
        return const ['Sistema cardiovascular'];
      case 'Trapecio':
        return const ['Trapecio'];
      default:
        return const ['Recto abdominal'];
    }
  }

  static String imagePrompt({
    required String name,
    required String muscleGroup,
    required String equipment,
    required List<String> primaryMuscles,
  }) {
    final primary = primaryMuscles.join(', ');
    return 'White background, 3D light-gray mannequin performing "$name" in the exact exercise posture, equipment required for the exercise in dark gray and black ($equipment), only activated muscles highlighted in bright red: $primary, clean anatomy style, full body visible, no realistic skin, no realistic face, no cartoon, no text, no watermark';
  }

  static String _normalize(String value) {
    final trimmed = value.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return '';
    }

    return trimmed
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll(RegExp(r'\s+'), '');
  }
}