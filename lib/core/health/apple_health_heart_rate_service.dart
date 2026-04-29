import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/external_heart_rate_reading.dart';

class HealthHeartRateService {
  HealthHeartRateService({Health? health}) : _health = health ?? Health();

  final Health _health;
  bool _configured = false;

  bool get isSupported =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.android;

  Future<HealthHeartRateResult> fetchHeartRateReadings({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!isSupported) {
      return const HealthHeartRateResult.unsupported();
    }

    try {
      await _configure();
      const types = [HealthDataType.HEART_RATE];
      const permissions = [HealthDataAccess.READ];
      final granted = await _health.requestAuthorization(
        types,
        permissions: permissions,
      );
      if (!granted) {
        return const HealthHeartRateResult.denied();
      }

      final points = await _health.getHealthDataFromTypes(
        types: types,
        startTime: startTime,
        endTime: endTime,
      );
      final uniquePoints = _health.removeDuplicates(points);
      final readings = uniquePoints
          .where((point) => point.type == HealthDataType.HEART_RATE)
          .map(_readingFromPoint)
          .whereType<ExternalHeartRateReading>()
          .toList(growable: false)
        ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

      return HealthHeartRateResult.success(readings);
    } catch (error) {
      return HealthHeartRateResult.failed(error.toString());
    }
  }

  Future<void> _configure() async {
    if (_configured) {
      return;
    }

    await _health.configure();
    _configured = true;
  }

  ExternalHeartRateReading? _readingFromPoint(HealthDataPoint point) {
    final value = point.value;
    if (value is! NumericHealthValue) {
      return null;
    }

    final bpm = value.numericValue.round();
    if (bpm <= 0) {
      return null;
    }

    final sourcePrefix = defaultTargetPlatform == TargetPlatform.android
        ? 'android_health'
        : 'apple_health';
    final source = point.sourceName.isEmpty
        ? sourcePrefix
        : '$sourcePrefix:${point.sourceName}';
    return ExternalHeartRateReading(
      bpm: bpm,
      timestamp: point.dateFrom.toUtc(),
      source: source,
    );
  }
}

class HealthHeartRateResult {
  const HealthHeartRateResult._({
    required this.status,
    required this.readings,
    this.errorMessage,
  });

  const HealthHeartRateResult.unsupported()
      : this._(
          status: HealthHeartRateStatus.unsupported,
          readings: const [],
        );

  const HealthHeartRateResult.denied()
      : this._(
          status: HealthHeartRateStatus.denied,
          readings: const [],
        );

  const HealthHeartRateResult.success(
    List<ExternalHeartRateReading> readings,
  ) : this._(
          status: HealthHeartRateStatus.success,
          readings: readings,
        );

  const HealthHeartRateResult.failed(String errorMessage)
      : this._(
          status: HealthHeartRateStatus.failed,
          readings: const [],
          errorMessage: errorMessage,
        );

  final HealthHeartRateStatus status;
  final List<ExternalHeartRateReading> readings;
  final String? errorMessage;
}

enum HealthHeartRateStatus {
  unsupported,
  denied,
  success,
  failed,
}
