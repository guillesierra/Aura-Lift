import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'social_repository.dart';

class LocalSocialRepository implements SocialRepository {
  static const _followingIdsKey = 'social_following_ids_v1';
  static const _avatarOverridesKey = 'social_avatar_overrides_v1';
  static const _dismissedIncomingKey = 'social_dismissed_incoming_v1';

  @override
  Future<Set<String>> loadFollowingIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_followingIdsKey) ?? const [];
    return list.toSet();
  }

  @override
  Future<void> saveFollowingIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_followingIdsKey, ids.toList(growable: false));
  }

  @override
  Future<Map<String, String>> loadAvatarOverrides() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_avatarOverridesKey);
    if (raw == null || raw.isEmpty) {
      return const {};
    }

    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      return const {};
    }

    return decoded.map(
      (key, value) => MapEntry(key, value.toString()),
    );
  }

  @override
  Future<void> saveAvatarOverrides(Map<String, String> overrides) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_avatarOverridesKey, jsonEncode(overrides));
  }

  @override
  Future<Set<String>> loadDismissedIncomingRequestIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_dismissedIncomingKey) ?? const [];
    return list.toSet();
  }

  @override
  Future<void> saveDismissedIncomingRequestIds(Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _dismissedIncomingKey,
      ids.toList(growable: false),
    );
  }
}
