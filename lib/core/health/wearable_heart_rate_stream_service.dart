import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../models/external_heart_rate_reading.dart';

enum WearableHeartRateStreamStatus {
  success,
  unsupported,
  denied,
  failed,
}

class WearableHeartRateStartResult {
  const WearableHeartRateStartResult._({
    required this.status,
    this.errorMessage,
  });

  const WearableHeartRateStartResult.success()
      : this._(status: WearableHeartRateStreamStatus.success);

  const WearableHeartRateStartResult.unsupported()
      : this._(status: WearableHeartRateStreamStatus.unsupported);

  const WearableHeartRateStartResult.denied()
      : this._(status: WearableHeartRateStreamStatus.denied);

  const WearableHeartRateStartResult.failed(String message)
      : this._(
          status: WearableHeartRateStreamStatus.failed,
          errorMessage: message,
        );

  final WearableHeartRateStreamStatus status;
  final String? errorMessage;

  bool get isSuccess => status == WearableHeartRateStreamStatus.success;
}

class WearableHeartRateStreamService {
  static const _methodChannel =
      MethodChannel('aura_lift/heart_rate_stream/methods');
  static const _eventChannel =
      EventChannel('aura_lift/heart_rate_stream/events');

  bool get isSupported =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  Stream<ExternalHeartRateReading> stream(
      {required DateTime startedAt}) async* {
    if (!isSupported) {
      return;
    }

    await for (final event in _eventChannel.receiveBroadcastStream(
      <String, dynamic>{
        'startedAtMillis': startedAt.toUtc().millisecondsSinceEpoch,
      },
    )) {
      final map = event is Map ? Map<String, dynamic>.from(event) : null;
      if (map == null) {
        continue;
      }
      final bpm = map['bpm'];
      final timestampMillis = map['timestampMillis'];
      final source = map['source'];
      if (bpm is! num || timestampMillis is! num) {
        continue;
      }

      yield ExternalHeartRateReading(
        bpm: bpm.round(),
        timestamp: DateTime.fromMillisecondsSinceEpoch(
          timestampMillis.toInt(),
          isUtc: true,
        ),
        source:
            source is String && source.isNotEmpty ? source : _defaultSource(),
      );
    }
  }

  Future<WearableHeartRateStartResult> start({
    required DateTime startedAt,
  }) async {
    if (!isSupported) {
      return const WearableHeartRateStartResult.unsupported();
    }

    try {
      await _methodChannel.invokeMethod<void>('start', {
        'startedAtMillis': startedAt.toUtc().millisecondsSinceEpoch,
      });
      return const WearableHeartRateStartResult.success();
    } on PlatformException catch (error) {
      final code = error.code.toLowerCase();
      if (code.contains('unsupported')) {
        return const WearableHeartRateStartResult.unsupported();
      }
      if (code.contains('denied') || code.contains('permission')) {
        return const WearableHeartRateStartResult.denied();
      }
      return WearableHeartRateStartResult.failed(
        error.message ?? error.code,
      );
    } catch (error) {
      return WearableHeartRateStartResult.failed(error.toString());
    }
  }

  Future<void> stop() async {
    if (!isSupported) {
      return;
    }

    try {
      await _methodChannel.invokeMethod<void>('stop');
    } catch (_) {
      // Best effort shutdown.
    }
  }

  String _defaultSource() {
    return defaultTargetPlatform == TargetPlatform.android
        ? 'android_wearable_stream'
        : 'apple_watch_stream';
  }
}
