import 'dart:convert';

import 'body_type.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.bodyType,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double heightCm;
  final double weightKg;
  final BodyType bodyType;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bodyType': bodyType.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      name: map['name'] as String,
      heightCm: (map['heightCm'] as num).toDouble(),
      weightKg: (map['weightKg'] as num).toDouble(),
      bodyType: BodyType.values.firstWhere(
        (element) => element.name == map['bodyType'],
        orElse: () => BodyType.undefined,
      ),
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProfile.fromJson(String source) {
    return UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
