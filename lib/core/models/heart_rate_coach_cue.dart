enum HeartRateCoachCue {
  motivation,
  nextSet,
}

extension HeartRateCoachCueX on HeartRateCoachCue {
  String get audioMessage {
    switch (this) {
      case HeartRateCoachCue.motivation:
        return 'Vamos, aprieta esta serie.';
      case HeartRateCoachCue.nextSet:
        return 'Ya has descansado. Sigue con la siguiente serie.';
    }
  }
}
