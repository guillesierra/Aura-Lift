import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../models/external_heart_rate_reading.dart';

class AppleHealthHeartRateService {
  AppleHealthHeartRateService({Health? health}) : _health = health ?? Health();

  final Health _health;
  bool _configured = false;

  bool get isSupported => defaultTargetPlatform == TargetPlatform.iOS;

  Future<AppleHealthHeartRateResult> fetchHeartRateReadings({
    required DateTime startTime,
    required DateTime endTime,
  }) async {
    if (!isSupported) {
      return const AppleHealthHeartRateResult.unsupported();
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
        return const AppleHealthHeartRateResult.denied();
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

      return AppleHealthHeartRateResult.success(readings);
    } catch (error) {
      return AppleHealthHeartRateResult.failed(error.toString());
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

    final source = point.sourceName.isEmpty
        ? 'apple_health'
        : 'apple_health:${point.sourceName}';
    return ExternalHeartRateReading(
      bpm: bpm,
      timestamp: point.dateFrom.toUtc(),
      source: source,
    );
  }
}

class AppleHealthHeartRateResult {
  const AppleHealthHeartRateResult._({
    required this.status,
    required this.readings,
    this.errorMessage,
  });

  const AppleHealthHeartRateResult.unsupported()
      : this._(
          status: AppleHealthHeartRateStatus.unsupported,
          readings: const [],
        );

  const AppleHealthHeartRateResult.denied()
      : this._(
          status: AppleHealthHeartRateStatus.denied,
          readings: const [],
        );

  const AppleHealthHeartRateResult.success(
    List<ExternalHeartRateReading> readings,
  ) : this._(
          status: AppleHealthHeartRateStatus.success,
          readings: readings,
        );

  const AppleHealthHeartRateResult.failed(String errorMessage)
      : this._(
          status: AppleHealthHeartRateStatus.failed,
          readings: const [],
          errorMessage: errorMessage,
        );

  final AppleHealthHeartRateStatus status;
  final List<ExternalHeartRateReading> readings;
  final String? errorMessage;
}

enum AppleHealthHeartRateStatus {
  unsupported,
  denied,
  success,
  failed,
}
