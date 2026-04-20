import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';

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
      await tts.setSpeechRate(0.48);
      await tts.setPitch(1.0);
      _configured = true;
    } on MissingPluginException {
      _pluginUnavailable = true;
    } catch (error, stackTrace) {
      debugPrint('VoiceCoach.configure error: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  bool get _canUseVoice => _tts != null && !_pluginUnavailable;
}
