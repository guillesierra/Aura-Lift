import 'dart:convert';

import 'body_type.dart';

class UserProfile {
  const UserProfile({
    required this.id,
    required this.name,
    required this.heightCm,
    required this.weightKg,
    required this.bodyType,
    this.avatarUrl,
    this.presentation = '',
    this.city = '',
    this.gym = '',
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final double heightCm;
  final double weightKg;
  final BodyType bodyType;
  final String? avatarUrl;
  final String presentation;
  final String city;
  final String gym;
  final DateTime createdAt;
  final DateTime updatedAt;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'heightCm': heightCm,
      'weightKg': weightKg,
      'bodyType': bodyType.name,
      'avatarUrl': avatarUrl,
      'presentation': presentation,
      'city': city,
      'gym': gym,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    final now = DateTime.now().toUtc();
    final createdAt = DateTime.tryParse((map['createdAt'] as String?) ?? '');
    final updatedAt = DateTime.tryParse((map['updatedAt'] as String?) ?? '');
    return UserProfile(
      id: (map['id'] as String?) ?? '',
      name: (map['name'] as String?) ?? '',
      heightCm: (map['heightCm'] as num?)?.toDouble() ?? 170,
      weightKg: (map['weightKg'] as num?)?.toDouble() ?? 70,
      bodyType: BodyType.values.firstWhere(
        (element) => element.name == map['bodyType'],
        orElse: () => BodyType.undefined,
      ),
      avatarUrl: map['avatarUrl'] as String?,
      presentation: (map['presentation'] as String?) ?? '',
      city: (map['city'] as String?) ?? '',
      gym: (map['gym'] as String?) ?? '',
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
    );
  }

  String toJson() => jsonEncode(toMap());

  factory UserProfile.fromJson(String source) {
    return UserProfile.fromMap(jsonDecode(source) as Map<String, dynamic>);
  }
}
