import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';
import 'profile_repository.dart';

class LocalProfileRepository implements ProfileRepository {
  static const _profileKey = 'user_profile_v1';

  @override
  Future<UserProfile?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }
    return UserProfile.fromJson(raw);
  }

  @override
  Future<void> save(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, profile.toJson());
  }
}
