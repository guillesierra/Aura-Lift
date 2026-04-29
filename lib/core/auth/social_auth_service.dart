enum SocialAuthProvider {
  google,
  apple,
}

class SocialAuthAccount {
  const SocialAuthAccount({
    required this.provider,
    required this.userId,
    this.email,
    this.displayName,
    this.photoUrl,
  });

  final SocialAuthProvider provider;
  final String userId;
  final String? email;
  final String? displayName;
  final String? photoUrl;

  Map<String, String?> toMap() {
    return {
      'provider': provider.name,
      'userId': userId,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
    };
  }

  factory SocialAuthAccount.fromMap(Map<String, String?> map) {
    return SocialAuthAccount(
      provider: SocialAuthProvider.values.firstWhere(
        (item) => item.name == map['provider'],
        orElse: () => SocialAuthProvider.google,
      ),
      userId: map['userId'] ?? '',
      email: map['email'],
      displayName: map['displayName'],
      photoUrl: map['photoUrl'],
    );
  }
}

class SocialAuthResult {
  const SocialAuthResult._({
    this.account,
    this.errorMessage,
    this.isCancelled = false,
    this.isUnsupported = false,
  });

  final SocialAuthAccount? account;
  final String? errorMessage;
  final bool isCancelled;
  final bool isUnsupported;

  bool get isSuccess => account != null;

  factory SocialAuthResult.success(SocialAuthAccount account) {
    return SocialAuthResult._(account: account);
  }

  factory SocialAuthResult.cancelled() {
    return const SocialAuthResult._(isCancelled: true);
  }

  factory SocialAuthResult.unsupported() {
    return const SocialAuthResult._(isUnsupported: true);
  }

  factory SocialAuthResult.error(String message) {
    return SocialAuthResult._(errorMessage: message);
  }
}

abstract class SocialAuthService {
  Future<SocialAuthAccount?> restoreSession();
  Future<SocialAuthResult> signInWithGoogle();
  Future<SocialAuthResult> signInWithApple();
  Future<void> signOut();
}
