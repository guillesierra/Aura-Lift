class SocialProfile {
  const SocialProfile({
    required this.id,
    required this.name,
    required this.handle,
    this.avatarUrl,
    this.bio,
    this.bodyWeightKg,
    this.followsMe = false,
  });

  final String id;
  final String name;
  final String handle;
  final String? avatarUrl;
  final String? bio;
  final double? bodyWeightKg;
  final bool followsMe;

  SocialProfile copyWith({
    String? name,
    String? handle,
    String? avatarUrl,
    bool keepAvatarUrl = true,
    String? bio,
    bool keepBio = true,
    double? bodyWeightKg,
    bool keepBodyWeightKg = true,
    bool? followsMe,
  }) {
    return SocialProfile(
      id: id,
      name: name ?? this.name,
      handle: handle ?? this.handle,
      avatarUrl: keepAvatarUrl ? (avatarUrl ?? this.avatarUrl) : null,
      bio: keepBio ? (bio ?? this.bio) : null,
      bodyWeightKg:
          keepBodyWeightKg ? (bodyWeightKg ?? this.bodyWeightKg) : null,
      followsMe: followsMe ?? this.followsMe,
    );
  }
}
