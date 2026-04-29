import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

import '../models/heart_rate_coach_cue.dart';

class VoiceCoach {
  VoiceCoach() : _tts = _isVoicePlatformSupported ? FlutterTts() : null;

  static bool get _isVoicePlatformSupported {
    if (kIsWeb) {
      return false;
    }

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => true,
      TargetPlatform.iOS => true,
      _ => false,
    };
  }

  final FlutterTts? _tts;
  bool _configured = false;
  bool _pluginUnavailable = false;
  final Map<HeartRateCoachCue, int> _cueVariantIndex = {
    HeartRateCoachCue.motivation: 0,
    HeartRateCoachCue.nextSet: 0,
  };

  Future<void> speak(String message) async {
    if (!_canUseVoice) {
      return;
    }

    try {
      await _configureIfNeeded();
      if (!_canUseVoice) {
        return;
      }

      final tts = _tts;
      if (tts == null) {
        return;
      }

      await _applyTone(VoiceTone.calm);
      await tts.stop();
      await tts.speak(message);
    } on MissingPluginException {
      _pluginUnavailable = true;
    } catch (error, stackTrace) {
      debugPrint('VoiceCoach.speak error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> stop() async {
    if (!_canUseVoice) {
      return;
    }

    try {
      await _tts!.stop();
    } on MissingPluginException {
      _pluginUnavailable = true;
    } catch (error, stackTrace) {
      debugPrint('VoiceCoach.stop error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> dispose() async {
    await stop();
  }

  Future<void> speakCue(
    HeartRateCoachCue cue, {
    required String languageCode,
  }) async {
    if (!_canUseVoice) {
      return;
    }

    try {
      await _configureIfNeeded();
      if (!_canUseVoice) {
        return;
      }

      final tts = _tts;
      if (tts == null) {
        return;
      }

      final currentVariant = _cueVariantIndex[cue] ?? 0;
      final utterance = cue.utteranceFor(languageCode, variant: currentVariant);
      _cueVariantIndex[cue] = currentVariant + 1;

      await _applyTone(utterance.tone);
      await tts.stop();
      await tts.speak(utterance.text);
    } on MissingPluginException {
      _pluginUnavailable = true;
    } catch (error, stackTrace) {
      debugPrint('VoiceCoach.speakCue error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _configureIfNeeded() async {
    if (_configured || !_canUseVoice) {
      return;
    }

    try {
      final tts = _tts;
      if (tts == null) {
        return;
      }

      await tts.setLanguage('es-ES');
      await tts.setSpeechRate(0.46);
      await tts.setPitch(1.0);
      await tts.setVolume(1.0);
      _configured = true;
    } on MissingPluginException {
      _pluginUnavailable = true;
    } catch (error, stackTrace) {
      debugPrint('VoiceCoach.configure error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  Future<void> _applyTone(VoiceTone tone) async {
    final tts = _tts;
    if (tts == null) {
      return;
    }

    switch (tone) {
      case VoiceTone.energetic:
        await tts.setSpeechRate(0.56);
        await tts.setPitch(1.15);
        await tts.setVolume(1.0);
      case VoiceTone.calm:
        await tts.setSpeechRate(0.42);
        await tts.setPitch(0.94);
        await tts.setVolume(0.92);
    }
  }

  bool get _canUseVoice => _tts != null && !_pluginUnavailable;
}
