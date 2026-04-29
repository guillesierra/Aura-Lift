class Exercise {
  const Exercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.equipment = 'Otro',
    this.primaryMuscles = const [],
    this.secondaryMuscles = const [],
    this.difficulty = 'Intermedio',
    this.imageAssetPath,
    this.imagePrompt,
    required this.isCustom,
    required this.createdAt,
  });

  final String id;
  final String name;
  final String muscleGroup;
  final String equipment;
  final List<String> primaryMuscles;
  final List<String> secondaryMuscles;
  final String difficulty;
  final String? imageAssetPath;
  final String? imagePrompt;
  final bool isCustom;
  final DateTime createdAt;

  factory Exercise.fromMap(Map<String, dynamic> map) {
    final primary = map['primaryMuscles'];
    final secondary = map['secondaryMuscles'];
    return Exercise(
      id: map['id'] as String,
      name: map['name'] as String,
      muscleGroup: map['muscleGroup'] as String,
      equipment: (map['equipment'] as String?) ?? 'Otro',
      primaryMuscles: primary is List
          ? primary.map((item) => item.toString()).toList(growable: false)
          : const [],
      secondaryMuscles: secondary is List
          ? secondary.map((item) => item.toString()).toList(growable: false)
          : const [],
      difficulty: (map['difficulty'] as String?) ?? 'Intermedio',
      imageAssetPath: map['imageAssetPath'] as String?,
      imagePrompt: map['imagePrompt'] as String?,
      isCustom: map['isCustom'] as bool,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'muscleGroup': muscleGroup,
      'equipment': equipment,
      'primaryMuscles': primaryMuscles,
      'secondaryMuscles': secondaryMuscles,
      'difficulty': difficulty,
      'imageAssetPath': imageAssetPath,
      'imagePrompt': imagePrompt,
      'isCustom': isCustom,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Exercise copyWith({
    String? id,
    String? name,
    String? muscleGroup,
    String? equipment,
    List<String>? primaryMuscles,
    List<String>? secondaryMuscles,
    String? difficulty,
    String? imageAssetPath,
    bool keepImageAssetPath = true,
    String? imagePrompt,
    bool keepImagePrompt = true,
    bool? isCustom,
    DateTime? createdAt,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      equipment: equipment ?? this.equipment,
      primaryMuscles: primaryMuscles ?? this.primaryMuscles,
      secondaryMuscles: secondaryMuscles ?? this.secondaryMuscles,
      difficulty: difficulty ?? this.difficulty,
      imageAssetPath:
          keepImageAssetPath ? (imageAssetPath ?? this.imageAssetPath) : null,
      imagePrompt: keepImagePrompt ? (imagePrompt ?? this.imagePrompt) : null,
      isCustom: isCustom ?? this.isCustom,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
