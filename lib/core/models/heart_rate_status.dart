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
            ? 'Take a short rest before your next set.'
            : 'Toma una pausa corta antes de tu siguiente serie.';
      case HeartRateStatus.readyForNextSet:
        return isEnglish
            ? 'You can start the next set when you feel ready.'
            : 'Puedes empezar la siguiente serie cuando te notes listo.';
    }
  }
}
