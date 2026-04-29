import 'dart:convert';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'social_auth_service.dart';

class PluginSocialAuthService implements SocialAuthService {
  PluginSocialAuthService()
      : _googleSignIn = GoogleSignIn(
          scopes: const ['email', 'profile'],
        );

  static const _authAccountKey = 'social_auth_account_v1';

  final GoogleSignIn _googleSignIn;

  @override
  Future<SocialAuthAccount?> restoreSession() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_authAccountKey);
    if (raw == null || raw.isEmpty) {
      return null;
    }

    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return SocialAuthAccount.fromMap(
      decoded.map((key, value) => MapEntry(key, value as String?)),
    );
  }

  @override
  Future<SocialAuthResult> signInWithGoogle() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        return SocialAuthResult.cancelled();
      }

      final socialAccount = SocialAuthAccount(
        provider: SocialAuthProvider.google,
        userId: account.id,
        email: account.email,
        displayName: account.displayName,
        photoUrl: account.photoUrl,
      );
      await _persistAccount(socialAccount);
      return SocialAuthResult.success(socialAccount);
    } catch (error) {
      return SocialAuthResult.error(error.toString());
    }
  }

  @override
  Future<SocialAuthResult> signInWithApple() async {
    try {
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        return SocialAuthResult.unsupported();
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final displayName = [credential.givenName, credential.familyName]
          .where((item) => item != null && item.isNotEmpty)
          .join(' ')
          .trim();
      final account = SocialAuthAccount(
        provider: SocialAuthProvider.apple,
        userId: credential.userIdentifier ?? '',
        email: credential.email,
        displayName: displayName.isEmpty ? null : displayName,
      );
      await _persistAccount(account);
      return SocialAuthResult.success(account);
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return SocialAuthResult.cancelled();
      }
      return SocialAuthResult.error(error.message);
    } catch (error) {
      return SocialAuthResult.error(error.toString());
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {
      // Ignore provider sign-out issues and clear local session anyway.
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_authAccountKey);
  }

  Future<void> _persistAccount(SocialAuthAccount account) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_authAccountKey, jsonEncode(account.toMap()));
  }
}
