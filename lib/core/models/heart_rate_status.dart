enum HeartRateStatus {
  idle,
  pushing,
  restSuggested,
  readyForNextSet,
}

extension HeartRateStatusX on HeartRateStatus {
  String get title => titleFor('es');

  String titleFor(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (this) {
      case HeartRateStatus.idle:
        return isEnglish ? 'No signal' : 'Sin señal';
      case HeartRateStatus.pushing:
        return isEnglish ? 'High intensity' : 'Alta intensidad';
      case HeartRateStatus.restSuggested:
        return isEnglish ? 'Rest now' : 'Toca descansar';
      case HeartRateStatus.readyForNextSet:
        return isEnglish ? 'Ready to continue' : 'Listo para seguir';
    }
  }

  String get description => descriptionFor('es');

  String descriptionFor(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (this) {
      case HeartRateStatus.idle:
        return isEnglish
            ? 'There are not enough heart rate samples yet.'
            : 'Todavía no hay muestras suficientes de frecuencia cardiaca.';
      case HeartRateStatus.pushing:
        return isEnglish
            ? 'Your heart rate is elevated. Keep the effort or finish the set.'
            : 'Tu frecuencia cardiaca está elevada. Mantén el esfuerzo o termina la serie.';
      case HeartRateStatus.restSuggested:
        return isEnglish
            ? 'Your heart rate has started dropping after the effort. Use this time to rest.'
            : 'La frecuencia ha empezado a bajar tras el esfuerzo. Aprovecha para descansar.';
      case HeartRateStatus.readyForNextSet:
        return isEnglish
            ? 'Your heart rate has stabilized lower. You can start the next set.'
            : 'La frecuencia se ha estabilizado a un nivel más bajo. Puedes empezar la siguiente serie.';
    }
  }
}
