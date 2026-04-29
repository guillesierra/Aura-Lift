import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/social_profile.dart';
import '../../core/state/app_state.dart';
import 'friend_profile_screen.dart';

class SocialHubScreen extends StatelessWidget {
  const SocialHubScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final strings = AppStrings.of(appState.languageCode);
        final theme = Theme.of(context);

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        IconButton.filledTonal(
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.arrow_back_rounded),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          strings.socialHub,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _SocialSection(
                      title: strings.incomingRequests,
                      emptyLabel: strings.noIncomingRequests,
                      profiles: appState.incomingRequestProfiles,
                      trailingBuilder: (profile) => Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextButton(
                            onPressed: () async {
                              await appState.declineIncomingRequest(profile.id);
                            },
                            child: Text(strings.decline),
                          ),
                          FilledButton.tonal(
                            onPressed: () async {
                              await appState.acceptIncomingRequest(profile.id);
                            },
                            child: Text(strings.acceptRequest),
                          ),
                        ],
                      ),
                      onTapProfile: (profile) async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FriendProfileScreen(
                              appState: appState,
                              profileId: profile.id,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _SocialSection(
                      title: strings.outgoingRequests,
                      emptyLabel: strings.noOutgoingRequests,
                      profiles: appState.outgoingRequestProfiles,
                      trailingBuilder: (profile) => TextButton(
                        onPressed: () async {
                          await appState.unfollowProfile(profile.id);
                        },
                        child: Text(strings.cancelRequest),
                      ),
                      onTapProfile: (profile) async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FriendProfileScreen(
                              appState: appState,
                              profileId: profile.id,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 14),
                    _SocialSection(
                      title: strings.friends,
                      emptyLabel: strings.noFriendsYet,
                      profiles: appState.friendProfiles,
                      trailingBuilder: (profile) => Text(
                        strings.friendsStatus,
                        style: theme.textTheme.labelMedium,
                      ),
                      onTapProfile: (profile) async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => FriendProfileScreen(
                              appState: appState,
                              profileId: profile.id,
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SocialSection extends StatelessWidget {
  const _SocialSection({
    required this.title,
    required this.emptyLabel,
    required this.profiles,
    required this.trailingBuilder,
    required this.onTapProfile,
  });

  final String title;
  final String emptyLabel;
  final List<SocialProfile> profiles;
  final Widget Function(SocialProfile profile) trailingBuilder;
  final Future<void> Function(SocialProfile profile) onTapProfile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AuraCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 10),
          if (profiles.isEmpty)
            Text(emptyLabel, style: theme.textTheme.bodyMedium)
          else
            ...profiles.map(
              (profile) => ListTile(
                contentPadding: EdgeInsets.zero,
                leading: CircleAvatar(
                  backgroundImage: profile.avatarUrl == null
                      ? null
                      : NetworkImage(profile.avatarUrl!),
                  child: profile.avatarUrl == null
                      ? Text(profile.name[0].toUpperCase())
                      : null,
                ),
                title: Text(profile.name),
                subtitle: Text(profile.handle),
                trailing: trailingBuilder(profile),
                onTap: () async {
                  await onTapProfile(profile);
                },
              ),
            ),
        ],
      ),
    );
  }
}
