import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/models/heart_rate_coach_cue.dart';

void main() {
  test('motivation cue has energetic tone and varied spanish messages', () {
    final first = HeartRateCoachCue.motivation.utteranceFor('es', variant: 0);
    final second = HeartRateCoachCue.motivation.utteranceFor('es', variant: 1);

    expect(first.tone, VoiceTone.energetic);
    expect(second.tone, VoiceTone.energetic);
    expect(first.text, isNot(second.text));
  });

  test('next set cue uses calm tone and english localization', () {
    final cue = HeartRateCoachCue.nextSet.utteranceFor('en', variant: 0);

    expect(cue.tone, VoiceTone.calm);
    expect(cue.text.toLowerCase(), contains('breathe'));
  });
}
