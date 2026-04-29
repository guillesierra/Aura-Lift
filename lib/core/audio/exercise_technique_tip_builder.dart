import '../localization/app_strings.dart';

class ExerciseTechniqueTipBuilder {
  const ExerciseTechniqueTipBuilder._();

  static String tipFor({
    required String exerciseName,
    required String muscleGroup,
    required String languageCode,
  }) {
    final strings = AppStrings.of(languageCode);
    final key = _normalize(exerciseName);

    if (key.contains('sentadilla') || key.contains('squat')) {
      return strings.tipSquat;
    }
    if (key.contains('peso muerto') || key.contains('deadlift')) {
      return strings.tipDeadlift;
    }
    if (key.contains('press de banca') ||
        key.contains('bench press') ||
        key.contains('press inclinado') ||
        key.contains('press declinado')) {
      return strings.tipBenchPress;
    }
    if (key.contains('dominada') ||
        key.contains('jalon') ||
        key.contains('pulldown')) {
      return strings.tipPulldown;
    }
    if (key.contains('remo')) {
      return strings.tipRow;
    }
    if (key.contains('curl')) {
      return strings.tipCurl;
    }
    if (key.contains('triceps') ||
        key.contains('extension') ||
        key.contains('fondos')) {
      return strings.tipTriceps;
    }
    if (key.contains('press militar') ||
        key.contains('shoulder press') ||
        key.contains('elevaciones') ||
        key.contains('lateral')) {
      return strings.tipShoulders;
    }
    if (key.contains('plancha') ||
        key.contains('crunch') ||
        key.contains('abdominal') ||
        key.contains('pallof')) {
      return strings.tipCore;
    }
    if (key.contains('cinta') ||
        key.contains('bike') ||
        key.contains('eliptica') ||
        key.contains('ergometro') ||
        key.contains('escaladora')) {
      return strings.tipCardio;
    }

    final normalizedGroup = _normalize(muscleGroup);
    if (normalizedGroup.contains('pecho')) {
      return strings.tipFallbackChest;
    }
    if (normalizedGroup.contains('espalda')) {
      return strings.tipFallbackBack;
    }
    if (normalizedGroup.contains('piernas') ||
        normalizedGroup.contains('gemelos')) {
      return strings.tipFallbackLegs;
    }
    if (normalizedGroup.contains('hombros') ||
        normalizedGroup.contains('trapecio')) {
      return strings.tipFallbackShoulders;
    }
    if (normalizedGroup.contains('biceps') ||
        normalizedGroup.contains('triceps')) {
      return strings.tipFallbackArms;
    }
    if (normalizedGroup.contains('core')) {
      return strings.tipFallbackCore;
    }
    return strings.tipFallbackGeneric;
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
