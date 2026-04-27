class ExternalHeartRateReading {
  const ExternalHeartRateReading({
    required this.bpm,
    required this.timestamp,
    required this.source,
  });

  final int bpm;
  final DateTime timestamp;
  final String source;
}
