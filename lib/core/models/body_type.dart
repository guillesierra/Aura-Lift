enum BodyType {
  ectomorph,
  mesomorph,
  endomorph,
  athletic,
  undefined,
}

extension BodyTypeX on BodyType {
  String get title {
    switch (this) {
      case BodyType.ectomorph:
        return 'Ectomorfo';
      case BodyType.mesomorph:
        return 'Mesomorfo';
      case BodyType.endomorph:
        return 'Endomorfo';
      case BodyType.athletic:
        return 'Atlético';
      case BodyType.undefined:
        return 'Prefiero no definir';
    }
  }

  String get description {
    switch (this) {
      case BodyType.ectomorph:
        return 'Suele asociarse a una complexión delgada, con dificultad para ganar peso o masa muscular.';
      case BodyType.mesomorph:
        return 'Suele asociarse a una estructura atlética, con facilidad relativa para ganar músculo y rendir bien en fuerza.';
      case BodyType.endomorph:
        return 'Suele asociarse a una complexión más robusta, con tendencia a ganar peso con mayor facilidad.';
      case BodyType.athletic:
        return 'Perfil general de alguien ya entrenado o equilibrado físicamente, sin encajar de forma clara en un único somatotipo.';
      case BodyType.undefined:
        return 'La app usará tus datos reales de entreno para ajustar recomendaciones sin partir de esta clasificación.';
    }
  }
}
