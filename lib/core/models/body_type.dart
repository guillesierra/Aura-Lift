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
}
