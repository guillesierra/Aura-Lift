abstract class SocialRepository {
  Future<Set<String>> loadFollowingIds();
  Future<void> saveFollowingIds(Set<String> ids);
  Future<Map<String, String>> loadAvatarOverrides();
  Future<void> saveAvatarOverrides(Map<String, String> overrides);
  Future<Set<String>> loadDismissedIncomingRequestIds();
  Future<void> saveDismissedIncomingRequestIds(Set<String> ids);
}
