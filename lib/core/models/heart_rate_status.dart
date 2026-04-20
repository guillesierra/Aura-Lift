enum HeartRateStatus {
  idle,
  pushing,
  restSuggested,
  readyForNextSet,
}

extension HeartRateStatusX on HeartRateStatus {
  String get title {
    switch (this) {
      case HeartRateStatus.idle:
        return 'Sin señal';
      case HeartRateStatus.pushing:
        return 'Alta intensidad';
      case HeartRateStatus.restSuggested:
        return 'Toca descansar';
      case HeartRateStatus.readyForNextSet:
        return 'Listo para seguir';
    }
  }

  String get description {
    switch (this) {
      case HeartRateStatus.idle:
        return 'Todavía no hay muestras suficientes de frecuencia cardiaca.';
      case HeartRateStatus.pushing:
        return 'Tu frecuencia cardiaca está elevada. Mantén el esfuerzo o termina la serie.';
      case HeartRateStatus.restSuggested:
        return 'La frecuencia ha empezado a bajar tras el esfuerzo. Aprovecha para descansar.';
      case HeartRateStatus.readyForNextSet:
        return 'La frecuencia se ha estabilizado a un nivel más bajo. Puedes empezar la siguiente serie.';
    }
  }
}
