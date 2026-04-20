class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.isCustom,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final bool isCustom;
  final DateTime createdAt;

  factory Exercise.fromMap(Map<String, dynamic> map) {
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      isCustom: map['isCustom'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
    };
  }
}
