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
    return HeartRateSample(
      id: map['id'] as String,
      bpm: map['bpm'] as int,
      timestamp: DateTime.parse(map['timestamp'] as String),
      exerciseId: map['exerciseId'] as String?,
      source: map['source'] as String? ?? 'manual',
    );
  }
}
