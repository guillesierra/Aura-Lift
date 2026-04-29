class ExerciseTechniqueTipBuilder {
  const ExerciseTechniqueTipBuilder._();

  static String tipFor({
    required String exerciseName,
    required String muscleGroup,
    required String languageCode,
  }) {
    final isEnglish = languageCode == 'en';
    final key = _normalize(exerciseName);

    if (key.contains('sentadilla') || key.contains('squat')) {
      return isEnglish
          ? 'Keep your chest proud, brace your core, and track knees in line with your toes.'
          : 'Pecho arriba, abdomen firme y rodillas siguiendo la linea de los pies.';
    }
    if (key.contains('peso muerto') || key.contains('deadlift')) {
      return isEnglish
          ? 'Start by bracing your core, keep the bar close, and drive with hips and legs together.'
          : 'Activa el core, barra pegada al cuerpo y empuja con cadera y piernas a la vez.';
    }
    if (key.contains('press de banca') ||
        key.contains('bench press') ||
        key.contains('press inclinado') ||
        key.contains('press declinado')) {
      return isEnglish
          ? 'Retract your shoulder blades, keep feet planted, and lower the bar with control to mid chest.'
          : 'Escapulas atras, pies firmes y baja la barra con control al centro del pecho.';
    }
    if (key.contains('dominada') ||
        key.contains('jalon') ||
        key.contains('pulldown')) {
      return isEnglish
          ? 'Initiate with scapular depression, pull elbows down, and avoid swinging your torso.'
          : 'Inicia bajando escapulas, lleva codos hacia abajo y evita balancear el torso.';
    }
    if (key.contains('remo')) {
      return isEnglish
          ? 'Keep a neutral spine, pull with elbows, and pause briefly with shoulder blades squeezed.'
          : 'Mantén columna neutra, tira con codos y aprieta escapulas un instante al final.';
    }
    if (key.contains('curl')) {
      return isEnglish
          ? 'Keep elbows fixed near the torso, avoid momentum, and control the negative phase.'
          : 'Codos pegados al torso, sin impulso y controla bien la fase de bajada.';
    }
    if (key.contains('triceps') ||
        key.contains('extension') ||
        key.contains('fondos')) {
      return isEnglish
          ? 'Lock your upper arm position, extend fully without snapping, and return under control.'
          : 'Fija el brazo, extiende completo sin bloquear brusco y vuelve con control.';
    }
    if (key.contains('press militar') ||
        key.contains('shoulder press') ||
        key.contains('elevaciones') ||
        key.contains('lateral')) {
      return isEnglish
          ? 'Ribs down, glutes tight, and raise with control without shrugging your shoulders.'
          : 'Costillas abajo, gluteo firme y eleva con control sin encoger los hombros.';
    }
    if (key.contains('plancha') ||
        key.contains('crunch') ||
        key.contains('abdominal') ||
        key.contains('pallof')) {
      return isEnglish
          ? 'Keep your pelvis neutral, breathe steadily, and prioritize tension over speed.'
          : 'Mantén pelvis neutra, respiracion estable y prioriza tension antes que velocidad.';
    }
    if (key.contains('cinta') ||
        key.contains('bike') ||
        key.contains('eliptica') ||
        key.contains('ergometro') ||
        key.contains('escaladora')) {
      return isEnglish
          ? 'Stay tall, keep breathing rhythmically, and maintain a pace you can sustain with technique.'
          : 'Postura alta, respiracion ritmica y un ritmo sostenible sin perder tecnica.';
    }

    final normalizedGroup = _normalize(muscleGroup);
    if (normalizedGroup.contains('pecho')) {
      return isEnglish
          ? 'Control the eccentric phase and keep your shoulders packed to protect the joint.'
          : 'Controla la bajada y mantén hombros estables para proteger la articulacion.';
    }
    if (normalizedGroup.contains('espalda')) {
      return isEnglish
          ? 'Lead with elbows and keep your chest open to engage your back properly.'
          : 'Guia con codos y mantén el pecho abierto para activar bien la espalda.';
    }
    if (normalizedGroup.contains('piernas') || normalizedGroup.contains('gemelos')) {
      return isEnglish
          ? 'Use full range of motion and keep pressure balanced across your feet.'
          : 'Usa rango completo y reparte la presion de forma equilibrada en los pies.';
    }
    if (normalizedGroup.contains('hombros') || normalizedGroup.contains('trapecio')) {
      return isEnglish
          ? 'Stabilize the trunk first, then move with smooth, controlled repetitions.'
          : 'Primero estabiliza el tronco y luego mueve con repeticiones fluidas y controladas.';
    }
    if (normalizedGroup.contains('biceps') || normalizedGroup.contains('triceps')) {
      return isEnglish
          ? 'Keep strict form and avoid compensating with your hips or lower back.'
          : 'Tecnica estricta y evita compensar con cadera o zona lumbar.';
    }
    if (normalizedGroup.contains('core')) {
      return isEnglish
          ? 'Brace your midline and maintain diaphragmatic breathing through the set.'
          : 'Activa la zona media y respira con control diafragmatico durante toda la serie.';
    }
    return isEnglish
        ? 'Move with control, keep your posture aligned, and prioritize clean technique.'
        : 'Mueve con control, postura alineada y prioriza una tecnica limpia.';
  }

  static String _normalize(String value) {
    final trimmed = value.trim().toLowerCase();
    return trimmed
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ü', 'u')
        .replaceAll('ñ', 'n');
  }
}