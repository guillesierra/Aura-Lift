enum HeartRateCoachCue {
  motivation,
  nextSet,
}

enum VoiceTone {
  energetic,
  calm,
}

class CoachUtterance {
  const CoachUtterance({
    required this.text,
    required this.tone,
  });

  final String text;
  final VoiceTone tone;
}

extension HeartRateCoachCueX on HeartRateCoachCue {
  String get audioMessage => utteranceFor('es').text;

  String audioMessageFor(String languageCode) => utteranceFor(languageCode).text;

  VoiceTone get preferredTone {
    switch (this) {
      case HeartRateCoachCue.motivation:
        return VoiceTone.energetic;
      case HeartRateCoachCue.nextSet:
        return VoiceTone.calm;
    }
  }

  List<String> _messagesFor(String languageCode) {
    final isEnglish = languageCode == 'en';
    switch (this) {
      case HeartRateCoachCue.motivation:
        if (isEnglish) {
          return const [
            'Strong rep. Stay sharp and push this set.',
            'You are locked in. Drive through every repetition.',
            'Great pace. Keep intensity high and own this set.',
            'Come on, one clean rep at a time. You have this.',
            'Power up now. Keep your form and attack the set.',
          ];
        }
        return const [
          'Vamos, aprieta esta serie con fuerza.',
          'Muy bien, sigue intenso y controla cada repeticion.',
          'Estas dentro. Una repeticion limpia tras otra.',
          'Empuja ahora, tecnica firme y actitud alta.',
          'Excelente ritmo. Cierra esta serie con potencia.',
        ];
      case HeartRateCoachCue.nextSet:
        if (isEnglish) {
          return const [
            'Good recovery. Breathe and prepare for the next set.',
            'Heart rate is down. Calm breath, then continue.',
            'You are ready. Reset posture and start the next set.',
            'Great control. Recover for a moment and go again.',
            'Take a steady breath. Continue when you feel set.',
          ];
        }
        return const [
          'Buen descanso. Respira y prepara la siguiente serie.',
          'La frecuencia ya bajo. Respira tranquilo y seguimos.',
          'Ya estas listo. Colocate bien y ve a la siguiente.',
          'Perfecto, recupera un instante y vuelve con control.',
          'Respiracion estable. Continua cuando te notes listo.',
        ];
    }
  }

  CoachUtterance utteranceFor(String languageCode, {int variant = 0}) {
    final options = _messagesFor(languageCode);
    final safeVariant = options.isEmpty ? 0 : variant % options.length;
    return CoachUtterance(
      text: options[safeVariant],
      tone: preferredTone,
    );
  }
}
