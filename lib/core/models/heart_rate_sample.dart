class HeartRateSample {
  const HeartRateSample({
    required this.id,
    required this.bpm,
    required this.timestamp,
    required this.exerciseId,
    required this.source,
  });

  final String id;
  final int bpm;
  final DateTime timestamp;
  final String? exerciseId;
  final String source;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'bpm': bpm,
      'timestamp': timestamp.toIso8601String(),
      'exerciseId': exerciseId,
      'source': source,
    };
  }

  factory HeartRateSample.fromMap(Map<String, dynamic> map) {
    final fallbackTime = DateTime.now().toUtc();
    final parsedBpm = (map['bpm'] as num?)?.toInt() ?? 0;
    return HeartRateSample(
      id: (map['id'] as String?) ?? '',
      bpm: parsedBpm.clamp(0, 250),
      timestamp: DateTime.tryParse((map['timestamp'] as String?) ?? '') ??
          fallbackTime,
      exerciseId: map['exerciseId'] as String?,
      source: map['source'] as String? ?? 'manual',
    );
  }
}
