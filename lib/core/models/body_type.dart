enum BodyType {
  ectomorph,
  mesomorph,
  endomorph,
  athletic,
  undefined,
}

extension BodyTypeX on BodyType {
  String get title => titleFor('es');

  String titleFor(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (this) {
      case BodyType.ectomorph:
        return isEnglish ? 'Ectomorph' : 'Ectomorfo';
      case BodyType.mesomorph:
        return isEnglish ? 'Mesomorph' : 'Mesomorfo';
      case BodyType.endomorph:
        return isEnglish ? 'Endomorph' : 'Endomorfo';
      case BodyType.athletic:
        return isEnglish ? 'Athletic' : 'Atlético';
      case BodyType.undefined:
        return isEnglish ? 'Prefer not to define' : 'Prefiero no definir';
    }
  }

  String get description => descriptionFor('es');

  String descriptionFor(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (this) {
      case BodyType.ectomorph:
        return isEnglish
            ? 'Usually associated with a lean build and difficulty gaining weight or muscle mass.'
            : 'Suele asociarse a una complexión delgada, con dificultad para ganar peso o masa muscular.';
      case BodyType.mesomorph:
        return isEnglish
            ? 'Usually associated with an athletic structure and relative ease gaining muscle and strength.'
            : 'Suele asociarse a una estructura atlética, con facilidad relativa para ganar músculo y rendir bien en fuerza.';
      case BodyType.endomorph:
        return isEnglish
            ? 'Usually associated with a sturdier build and a tendency to gain weight more easily.'
            : 'Suele asociarse a una complexión más robusta, con tendencia a ganar peso con mayor facilidad.';
      case BodyType.athletic:
        return isEnglish
            ? 'General profile for someone already trained or physically balanced, without a single clear somatotype.'
            : 'Perfil general de alguien ya entrenado o equilibrado físicamente, sin encajar de forma clara en un único somatotipo.';
      case BodyType.undefined:
        return isEnglish
            ? 'The app will use your real training data to adjust guidance without relying on this classification.'
            : 'La app usará tus datos reales de entreno para ajustar recomendaciones sin partir de esta clasificación.';
    }
  }
}
