import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/metrics/aura_league.dart';
import '../../core/state/app_state.dart';
import '../home/home_screen.dart';
import '../workout/workout_summary_detail_screen.dart';

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({
    super.key,
    required this.appState,
    required this.profileId,
  });

  final AppState appState;
  final String profileId;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final strings = AppStrings.of(appState.languageCode);
        final theme = Theme.of(context);
        final profile = appState.socialProfileById(profileId);
        if (profile == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(
              child: Text(strings.noExerciseData),
            ),
          );
        }

        final sessions = appState.socialCompletedSessionsFor(profileId);
        final comparison = appState.compareWithProfile(profileId);
        final status = appState.connectionStatusFor(profileId);
        final currentYear = DateTime.now().year;
        const estimatedFriendBodyWeight = 75.0;
        final annualSessions = sessions
            .where((session) => session.startedAt.toLocal().year == currentYear)
            .toList(growable: false);
        final totalVolume = sessions.fold<double>(
          0,
          (sum, session) => sum + session.totalVolume,
        );
        final totalMinutes = sessions.fold<int>(
          0,
          (sum, session) => sum + session.duration.inMinutes,
        );
        final annualAuraPoints = annualSessions.fold<int>(
          0,
          (sum, session) =>
              sum +
              appState.auraPointsForSession(
                session,
                bodyWeightKg: estimatedFriendBodyWeight,
              ),
        );
        final league = AuraLeagueSystem.fromAnnualPoints(annualAuraPoints);

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
                        Expanded(
                          child: Text(
                            profile.handle,
                            style: theme.textTheme.titleLarge,
                          ),
                        ),
                        FilledButton.tonal(
                          onPressed: () async {
                            await _applyConnectionAction(appState, profile.id);
                          },
                          child: Text(
                            _statusActionLabel(strings, status),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    AuraCard(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          _Avatar(url: profile.avatarUrl, name: profile.name),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  profile.name,
                                  style: theme.textTheme.headlineMedium,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  profile.bio ?? '',
                                  style: theme.textTheme.bodyMedium,
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 7,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AuraLeagueSystem.color(
                                      league,
                                      theme,
                                    ).withValues(alpha: 0.14),
                                    borderRadius: BorderRadius.circular(999),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        AuraLeagueSystem.icon(league),
                                        size: 16,
                                        color: AuraLeagueSystem.color(
                                          league,
                                          theme,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${strings.annualLeague} ${AuraLeagueSystem.localizedName(league, appState.languageCode)} · $currentYear · $annualAuraPoints ${strings.auraPointsShort}',
                                        style: theme.textTheme.labelMedium,
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _FriendStat(
                                        label: strings.workouts,
                                        value: '${sessions.length}',
                                      ),
                                    ),
                                    Expanded(
                                      child: _FriendStat(
                                        label: strings.volume,
                                        value:
                                            '${totalVolume.toStringAsFixed(0)} kg',
                                      ),
                                    ),
                                    Expanded(
                                      child: _FriendStat(
                                        label: strings.duration,
                                        value: '${totalMinutes}m',
                                      ),
                                    ),
                                    Expanded(
                                      child: _FriendStat(
                                        label: strings.auraPointsShort,
                                        value: '$annualAuraPoints',
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _statusLabel(strings, status),
                                  style: theme.textTheme.labelMedium,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (comparison != null)
                      _ComparisonCard(
                        comparison: comparison,
                        languageCode: appState.languageCode,
                      ),
                    const SizedBox(height: 18),
                    Text(
                      strings.workouts,
                      style: theme.textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),
                    ...sessions.take(8).map(
                          (session) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: WorkoutSummaryCard(
                              session: session,
                              authorName: profile.name,
                              authorHandle: profile.handle,
                              authorAvatarUrl: profile.avatarUrl,
                              auraPoints: appState.auraPointsForSession(
                                session,
                                bodyWeightKg: appState.profile?.weightKg ?? 75,
                              ),
                              highlightColor: theme.colorScheme.secondary,
                              onTap: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => WorkoutSummaryDetailScreen(
                                      session: session,
                                      authorName: profile.name,
                                      bodyWeightKg: appState.profile?.weightKg ??
                                          75,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
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

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.comparison,
    required this.languageCode,
  });

  final ProfileComparison comparison;
  final String languageCode;

  @override
  Widget build(BuildContext context) {
    final strings = AppStrings.of(languageCode);
    final theme = Theme.of(context);

    return AuraCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.profileComparison,
            style: theme.textTheme.titleLarge,
          ),
          const SizedBox(height: 10),
          _ComparisonRow(
            label: strings.trainingTime,
            mine: '${comparison.myStats.totalMinutes} min',
            other: '${comparison.otherStats.totalMinutes} min',
          ),
          _ComparisonRow(
            label: strings.totalVolume,
            mine: '${comparison.myStats.totalVolume.toStringAsFixed(0)} kg',
            other:
                '${comparison.otherStats.totalVolume.toStringAsFixed(0)} kg',
          ),
          _ComparisonRow(
            label: strings.totalWeightLifted,
            mine: '${comparison.myStats.totalVolume.toStringAsFixed(0)} kg',
            other:
                '${comparison.otherStats.totalVolume.toStringAsFixed(0)} kg',
          ),
          _ComparisonRow(
            label: strings.bestLift,
            mine: '${comparison.myStats.topSingleLift.toStringAsFixed(1)} kg',
            other:
                '${comparison.otherStats.topSingleLift.toStringAsFixed(1)} kg',
          ),
          const SizedBox(height: 10),
          Text(
            strings.sharedExerciseRecords,
            style: theme.textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (comparison.sharedExerciseRecords.isEmpty)
            Text(
              strings.noSharedExercises,
              style: theme.textTheme.bodyMedium,
            )
          else
            ...comparison.sharedExerciseRecords.take(6).map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${_titleCase(item.exerciseName)}: ${strings.youLabel} ${item.myBestWeight.toStringAsFixed(0)}kg • ${strings.heSheLabel} ${item.otherBestWeight.toStringAsFixed(0)}kg',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                ),
        ],
      ),
    );
  }

  String _titleCase(String value) {
    if (value.isEmpty) {
      return value;
    }
    return value[0].toUpperCase() + value.substring(1);
  }
}

class _ComparisonRow extends StatelessWidget {
  const _ComparisonRow({
    required this.label,
    required this.mine,
    required this.other,
  });

  final String label;
  final String mine;
  final String other;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: theme.textTheme.bodyMedium)),
          Expanded(
            child: Text(
              mine,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              other,
              textAlign: TextAlign.end,
              style: theme.textTheme.titleSmall,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({
    required this.url,
    required this.name,
  });

  final String? url;
  final String name;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: 28,
      backgroundImage: url == null ? null : NetworkImage(url!),
      child: url == null
          ? Text(
              name.isNotEmpty ? name[0].toUpperCase() : 'U',
            )
          : null,
    );
  }
}

class _FriendStat extends StatelessWidget {
  const _FriendStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelSmall),
        const SizedBox(height: 2),
        Text(value, style: theme.textTheme.titleSmall),
      ],
    );
  }
}

String _statusLabel(AppStrings strings, SocialConnectionStatus status) {
  switch (status) {
    case SocialConnectionStatus.friends:
      return strings.friendsStatus;
    case SocialConnectionStatus.requestSent:
      return strings.requestSentStatus;
    case SocialConnectionStatus.requestReceived:
      return strings.requestReceivedStatus;
    case SocialConnectionStatus.notFollowing:
      return strings.followProfile;
  }
}

String _statusActionLabel(AppStrings strings, SocialConnectionStatus status) {
  switch (status) {
    case SocialConnectionStatus.friends:
      return strings.removeFriend;
    case SocialConnectionStatus.requestSent:
      return strings.cancelRequest;
    case SocialConnectionStatus.requestReceived:
      return strings.acceptRequest;
    case SocialConnectionStatus.notFollowing:
      return strings.followProfile;
  }
}

Future<void> _applyConnectionAction(AppState appState, String profileId) async {
  final status = appState.connectionStatusFor(profileId);
  switch (status) {
    case SocialConnectionStatus.friends:
    case SocialConnectionStatus.requestSent:
      await appState.unfollowProfile(profileId);
      return;
    case SocialConnectionStatus.requestReceived:
    case SocialConnectionStatus.notFollowing:
      await appState.followProfile(profileId);
      return;
  }
}
