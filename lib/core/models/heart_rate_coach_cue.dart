enum HeartRateCoachCue {
  motivation,
  nextSet,
}

extension HeartRateCoachCueX on HeartRateCoachCue {
  String get audioMessage => audioMessageFor('es');

  String audioMessageFor(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (this) {
      case HeartRateCoachCue.motivation:
        return isEnglish ? 'Push this set.' : 'Vamos, aprieta esta serie.';
      case HeartRateCoachCue.nextSet:
        return isEnglish
            ? 'You have rested. Move to the next set.'
            : 'Ya has descansado. Sigue con la siguiente serie.';
    }
  }
}
