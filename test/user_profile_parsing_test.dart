import 'package:flutter_test/flutter_test.dart';

import 'package:aura_lift/core/models/body_type.dart';
import 'package:aura_lift/core/models/user_profile.dart';

void main() {
  test('UserProfile.fromMap parses complete payload', () {
    final profile = UserProfile.fromMap({
      'id': 'u-1',
      'name': 'Alex',
      'heightCm': 180,
      'weightKg': 82,
      'bodyType': 'athletic',
      'avatarUrl': 'https://example.com/a.png',
      'presentation': 'Test bio',
      'city': 'Madrid',
      'gym': 'Aura Gym',
      'createdAt': '2026-01-01T00:00:00Z',
      'updatedAt': '2026-01-02T00:00:00Z',
    });

    expect(profile.id, 'u-1');
    expect(profile.name, 'Alex');
    expect(profile.heightCm, 180);
    expect(profile.weightKg, 82);
    expect(profile.bodyType, BodyType.athletic);
    expect(profile.avatarUrl, isNotNull);
    expect(profile.city, 'Madrid');
    expect(profile.gym, 'Aura Gym');
  });

  test(
      'UserProfile.fromMap applies defensive defaults for missing required fields',
      () {
    final before = DateTime.now().toUtc().subtract(const Duration(seconds: 1));
    final profile = UserProfile.fromMap({
      'bodyType': 'unknown_type',
    });
    final after = DateTime.now().toUtc().add(const Duration(seconds: 1));

    expect(profile.id, '');
    expect(profile.name, '');
    expect(profile.heightCm, 170);
    expect(profile.weightKg, 70);
    expect(profile.bodyType, BodyType.undefined);
    expect(profile.createdAt.isAfter(before), isTrue);
    expect(profile.createdAt.isBefore(after), isTrue);
    expect(profile.updatedAt.isAfter(before), isTrue);
    expect(profile.updatedAt.isBefore(after), isTrue);
  });
}
