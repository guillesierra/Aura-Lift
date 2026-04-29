import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import '../../core/auth/social_auth_service.dart';
import '../../core/design_system/widgets/avatar_image_provider.dart';
import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/insights/training_risk_advisor.dart';
import '../../core/localization/app_strings.dart';
import '../../core/metrics/aura_league.dart';
import '../../core/metrics/calorie_estimator.dart';
import '../../core/models/body_type.dart';
import '../../core/state/app_state.dart';
import '../home/home_screen.dart';
import '../progress/exercise_progress_list_screen.dart';
import '../social/social_hub_screen.dart';
import '../workout/workout_summary_detail_screen.dart';
import 'measurements_screen.dart';
import 'personal_stats_screen.dart';
import 'workout_calendar_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final theme = Theme.of(context);
        final strings = AppStrings.of(appState.languageCode);
        final profile = appState.profile!;
        final completedSessions = appState.sessions
            .where((item) => !item.isActive)
            .toList()
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final totalVolume = completedSessions.fold<double>(
          0,
          (sum, session) => sum + session.totalVolume,
        );
        final totalMinutes = completedSessions.fold<int>(
          0,
          (sum, session) => sum + session.duration.inMinutes,
        );
        final totalAuraPoints = appState.totalAuraPoints(
          bodyWeightKg: profile.weightKg,
        );
        final currentYear = DateTime.now().year;
        final annualAuraPoints = appState.annualAuraPoints(
          year: currentYear,
          bodyWeightKg: profile.weightKg,
        );
        final league = AuraLeagueSystem.fromAnnualPoints(annualAuraPoints);
        final recommendations = TrainingRiskAdvisor.build(
          sessions: completedSessions,
          languageCode: appState.languageCode,
        );
        final friends = appState.friendProfiles;

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AuraCard(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              InkWell(
                                borderRadius: BorderRadius.circular(999),
                                onTap: () async {
                                  await _showAvatarActions(
                                    context,
                                    appState,
                                    hasAvatar: profile.avatarUrl != null,
                                  );
                                },
                                child: CircleAvatar(
                                  radius: 36,
                                  backgroundColor:
                                      theme.colorScheme.primaryContainer,
                                  backgroundImage:
                                      avatarImageProvider(profile.avatarUrl),
                                  child: profile.avatarUrl == null
                                      ? Text(
                                          profile.name.isNotEmpty
                                              ? profile.name[0].toUpperCase()
                                              : 'A',
                                          style: theme.textTheme.headlineMedium
                                              ?.copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                        )
                                      : null,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      profile.name,
                                      style: theme.textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${profile.heightCm.toStringAsFixed(0)} cm · ${profile.weightKg.toStringAsFixed(0)} kg · ${profile.bodyType.titleFor(appState.languageCode)}',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    if (profile.city.isNotEmpty ||
                                        profile.gym.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        [profile.city, profile.gym]
                                            .where((item) => item.isNotEmpty)
                                            .join(' · '),
                                        style: theme.textTheme.bodySmall,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              IconButton.filledTonal(
                                tooltip: strings.settings,
                                onPressed: () async {
                                  await _showProfileSettingsSheet(
                                      context, appState);
                                },
                                icon: const Icon(Icons.settings_outlined),
                              ),
                            ],
                          ),
                          if (profile.presentation.isNotEmpty) ...[
                            const SizedBox(height: 12),
                            Text(
                              profile.presentation,
                              style: theme.textTheme.bodyMedium,
                            ),
                          ],
                          const SizedBox(height: 12),
                          InkWell(
                            borderRadius: BorderRadius.circular(999),
                            onTap: () async {
                              await _showAnnualLeagueInfoSheet(
                                context,
                                appState,
                                year: currentYear,
                                annualAuraPoints: annualAuraPoints,
                              );
                            },
                            child: Container(
                              width: double.infinity,
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
                                  Expanded(
                                    child: Text(
                                      '${strings.annualLeague} ${AuraLeagueSystem.localizedName(league, appState.languageCode)} · $currentYear · $annualAuraPoints ${strings.auraPointsShort}',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.labelMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final itemWidth = (constraints.maxWidth - 10) / 2;
                              return Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  SizedBox(
                                    width: itemWidth,
                                    child: _TopStat(
                                      label: strings.workouts,
                                      value: '${completedSessions.length}',
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _TopStat(
                                      label: strings.volume,
                                      value:
                                          '${totalVolume.toStringAsFixed(0)} kg',
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _TopStat(
                                      label: strings.duration,
                                      value: '${totalMinutes}m',
                                    ),
                                  ),
                                  SizedBox(
                                    width: itemWidth,
                                    child: _TopStat(
                                      label: strings.auraPointsShort,
                                      value: '$totalAuraPoints',
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    InkWell(
                      borderRadius: BorderRadius.circular(AuraCard.radius),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => SocialHubScreen(appState: appState),
                          ),
                        );
                      },
                      child: AuraCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.friends,
                              style: theme.textTheme.titleLarge,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 120,
                                  height: 40,
                                  child: Stack(
                                    children: friends
                                        .take(4)
                                        .toList()
                                        .asMap()
                                        .entries
                                        .map(
                                      (entry) {
                                        final index = entry.key;
                                        final friend = entry.value;
                                        return Positioned(
                                          left: index * 24,
                                          child: CircleAvatar(
                                            radius: 18,
                                            backgroundImage:
                                                friend.avatarUrl == null
                                                    ? null
                                                    : NetworkImage(
                                                        friend.avatarUrl!),
                                            child: friend.avatarUrl == null
                                                ? Text(friend.name[0]
                                                    .toUpperCase())
                                                : null,
                                          ),
                                        );
                                      },
                                    ).toList(growable: false),
                                  ),
                                ),
                                Expanded(
                                  child: Text(
                                    strings.totalFriendsCount(friends.length),
                                    style: theme.textTheme.bodyLarge,
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(strings.info, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 14),
                    AuraCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons.monitor_heart_outlined,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  strings.improvementCardTitle,
                                  style: theme.textTheme.titleLarge,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            strings.improvementCardSubtitle,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          if (recommendations.isEmpty)
                            Text(
                              strings.improvementCardEmpty,
                              style: theme.textTheme.bodyMedium,
                            )
                          else
                            ...recommendations.take(3).map(
                                  (recommendation) => Padding(
                                    padding: const EdgeInsets.only(bottom: 8),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Icon(
                                          _iconForSeverity(
                                            recommendation.severity,
                                          ),
                                          size: 18,
                                          color: _colorForSeverity(
                                            recommendation.severity,
                                            theme,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          child: Text(
                                            recommendation.message,
                                            style: theme.textTheme.bodyMedium,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    GridView.count(
                      crossAxisCount: 2,
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      childAspectRatio: 2.25,
                      children: [
                        _ActionTile(
                          title: strings.stats,
                          icon: Icons.insights_outlined,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => PersonalStatsScreen(
                                  appState: appState,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          title: strings.exercises,
                          icon: Icons.fitness_center_outlined,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => ExerciseProgressListScreen(
                                  appState: appState,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          title: strings.measurements,
                          icon: Icons.accessibility_new_outlined,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => MeasurementsScreen(
                                  profile: profile,
                                  languageCode: appState.languageCode,
                                ),
                              ),
                            );
                          },
                        ),
                        _ActionTile(
                          key: const Key('profile_calendar_tile'),
                          title: strings.calendar,
                          icon: Icons.calendar_today_outlined,
                          onTap: () async {
                            await Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => WorkoutCalendarScreen(
                                  appState: appState,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(strings.workouts, style: theme.textTheme.titleLarge),
                    const SizedBox(height: 14),
                    if (completedSessions.isEmpty)
                      Text(
                        strings.noClosedSessions,
                        style: theme.textTheme.bodyMedium,
                      )
                    else
                      ...completedSessions.map(
                        (session) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: WorkoutSummaryCard(
                            session: session,
                            authorName: profile.name,
                            authorHandle: profile.name.toLowerCase(),
                            authorAvatarUrl: profile.avatarUrl,
                            highlightColor: theme.colorScheme.primary,
                            estimatedCalories:
                                CalorieEstimator.estimateWorkoutCalories(
                              session: session,
                              bodyWeightKg: profile.weightKg,
                            ),
                            auraPoints: appState.auraPointsForSession(
                              session,
                              bodyWeightKg: profile.weightKg,
                            ),
                            onTap: () async {
                              await Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => WorkoutSummaryDetailScreen(
                                    session: session,
                                    authorName: profile.name,
                                    bodyWeightKg: profile.weightKg,
                                  ),
                                ),
                              );
                            },
                            onRename: (title) {
                              return appState.renameWorkoutSession(
                                sessionId: session.id,
                                title: title,
                              );
                            },
                            onDelete: () {
                              return appState.deleteWorkoutSession(session.id);
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

Future<void> _showProfileSettingsSheet(
  BuildContext context,
  AppState appState,
) async {
  final profile = appState.profile!;
  final strings = AppStrings.of(appState.languageCode);
  final nameController = TextEditingController(text: profile.name);
  final heightController =
      TextEditingController(text: profile.heightCm.toStringAsFixed(0));
  final weightController =
      TextEditingController(text: profile.weightKg.toStringAsFixed(0));
  final cityController = TextEditingController(text: profile.city);
  final gymController = TextEditingController(text: profile.gym);
  final presentationController =
      TextEditingController(text: profile.presentation);
  final heartRateBaseController = TextEditingController(
    text: appState.configuredHeartRateBaseBpm?.toString() ?? '',
  );
  final returnCueController = TextEditingController(
    text: appState.configuredHeartRateReturnCueBpm?.toString() ?? '',
  );
  var selectedBodyType = profile.bodyType;
  var replaceExisting = false;
  var isBusy = false;
  String? heartRateBaseError;
  String? returnCueError;

  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      return StatefulBuilder(
        builder: (context, setStateModal) {
          return Padding(
            padding: EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24 + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    strings.profileSettings,
                    style: theme.textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.account,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    appState.authAccount == null
                        ? strings.notConnected
                        : strings.connectedWith(
                            appState.authAccount!.provider ==
                                    SocialAuthProvider.google
                                ? 'Google'
                                : 'Apple',
                          ),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isBusy
                            ? null
                            : () async {
                                setStateModal(() => isBusy = true);
                                final result =
                                    await appState.signInWithGoogle();
                                if (!context.mounted) {
                                  return;
                                }
                                setStateModal(() => isBusy = false);
                                final messenger = ScaffoldMessenger.of(context);
                                if (result.isSuccess) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(strings.authSuccess)),
                                  );
                                } else if (result.isCancelled) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(strings.authCancelled)),
                                  );
                                } else if (result.isUnsupported) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(strings.authUnsupported)),
                                  );
                                } else if (result.errorMessage != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        strings.authError(result.errorMessage!),
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.g_mobiledata_rounded),
                        label: Text(strings.connectGoogle),
                      ),
                      OutlinedButton.icon(
                        onPressed: isBusy
                            ? null
                            : () async {
                                setStateModal(() => isBusy = true);
                                final result = await appState.signInWithApple();
                                if (!context.mounted) {
                                  return;
                                }
                                setStateModal(() => isBusy = false);
                                final messenger = ScaffoldMessenger.of(context);
                                if (result.isSuccess) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(strings.authSuccess)),
                                  );
                                } else if (result.isCancelled) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(strings.authCancelled)),
                                  );
                                } else if (result.isUnsupported) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(strings.authUnsupported)),
                                  );
                                } else if (result.errorMessage != null) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        strings.authError(result.errorMessage!),
                                      ),
                                    ),
                                  );
                                }
                              },
                        icon: const Icon(Icons.apple),
                        label: Text(strings.connectApple),
                      ),
                      TextButton.icon(
                        onPressed: isBusy || appState.authAccount == null
                            ? null
                            : () async {
                                setStateModal(() => isBusy = true);
                                await appState.signOutSocialAuth();
                                if (!context.mounted) {
                                  return;
                                }
                                setStateModal(() => isBusy = false);
                              },
                        icon: const Icon(Icons.logout),
                        label: Text(strings.disconnectAccount),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    strings.dataTransfer,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    value: replaceExisting,
                    onChanged: isBusy
                        ? null
                        : (value) {
                            setStateModal(() => replaceExisting = value);
                          },
                    title: Text(strings.replaceExistingWorkouts),
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      OutlinedButton.icon(
                        onPressed: isBusy
                            ? null
                            : () async {
                                final csv = appState.exportWorkoutsAsCsv();
                                final savePath =
                                    await FilePicker.platform.saveFile(
                                  dialogTitle: strings.exportCsv,
                                  fileName: 'aura_lift_workouts.csv',
                                  type: FileType.custom,
                                  allowedExtensions: const ['csv'],
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                final messenger = ScaffoldMessenger.of(context);
                                if (savePath == null || savePath.isEmpty) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(strings.csvExportCancelled),
                                    ),
                                  );
                                  return;
                                }

                                await File(savePath).writeAsString(
                                  csv,
                                  encoding: utf8,
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                messenger.showSnackBar(
                                  SnackBar(
                                    content:
                                        Text(strings.csvExported(savePath)),
                                  ),
                                );
                              },
                        icon: const Icon(Icons.file_download_outlined),
                        label: Text(strings.exportCsv),
                      ),
                      OutlinedButton.icon(
                        onPressed: isBusy
                            ? null
                            : () async {
                                final picked =
                                    await FilePicker.platform.pickFiles(
                                  dialogTitle: strings.importCsv,
                                  type: FileType.custom,
                                  allowedExtensions: const ['csv'],
                                  withData: true,
                                );
                                if (!context.mounted) {
                                  return;
                                }
                                final messenger = ScaffoldMessenger.of(context);
                                if (picked == null || picked.files.isEmpty) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(strings.csvImportCancelled),
                                    ),
                                  );
                                  return;
                                }

                                final selected = picked.files.first;
                                String? raw;
                                if (selected.bytes != null) {
                                  raw = utf8.decode(selected.bytes!);
                                } else if (selected.path != null) {
                                  raw =
                                      await File(selected.path!).readAsString();
                                }
                                if (raw == null || raw.trim().isEmpty) {
                                  messenger.showSnackBar(
                                    SnackBar(
                                        content: Text(strings.csvImportEmpty)),
                                  );
                                  return;
                                }

                                setStateModal(() => isBusy = true);
                                try {
                                  final report =
                                      await appState.importWorkoutsFromCsv(
                                    raw,
                                    replaceExisting: replaceExisting,
                                  );
                                  if (!context.mounted) {
                                    return;
                                  }
                                  if (report.sessions == 0) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(strings.csvImportEmpty),
                                      ),
                                    );
                                  } else {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          strings.csvImported(
                                            report.sessions,
                                            report.sets,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                } catch (error) {
                                  if (context.mounted) {
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          strings
                                              .csvImportError(error.toString()),
                                        ),
                                      ),
                                    );
                                  }
                                } finally {
                                  if (context.mounted) {
                                    setStateModal(() => isBusy = false);
                                  }
                                }
                              },
                        icon: const Icon(Icons.file_upload_outlined),
                        label: Text(strings.importCsv),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    strings.heartRateCoachSettings,
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    strings.heartRateCoachSettingsHint,
                    style: theme.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: heartRateBaseController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) {
                            if (heartRateBaseError != null) {
                              setStateModal(() => heartRateBaseError = null);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: strings.baseHeartRateBpm,
                            helperText: strings.baseHeartRateRangeHint,
                            errorText: heartRateBaseError,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: returnCueController,
                          keyboardType: TextInputType.number,
                          onChanged: (_) {
                            if (returnCueError != null) {
                              setStateModal(() => returnCueError = null);
                            }
                          },
                          decoration: InputDecoration(
                            labelText: strings.returnCueBpm,
                            helperText: strings.returnCueRangeHint,
                            errorText: returnCueError,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(labelText: strings.name),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: heightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              InputDecoration(labelText: strings.height),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: weightController,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          decoration:
                              InputDecoration(labelText: strings.weight),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<BodyType>(
                    initialValue: selectedBodyType,
                    items: BodyType.values
                        .map(
                          (item) => DropdownMenuItem(
                            value: item,
                            child: Text(item.titleFor(appState.languageCode)),
                          ),
                        )
                        .toList(growable: false),
                    onChanged: (value) {
                      if (value == null) {
                        return;
                      }
                      setStateModal(() => selectedBodyType = value);
                    },
                    decoration: InputDecoration(labelText: strings.bodyType),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: cityController,
                    decoration: InputDecoration(labelText: strings.city),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: gymController,
                    decoration: InputDecoration(labelText: strings.gym),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: presentationController,
                    maxLength: 200,
                    maxLines: 4,
                    decoration:
                        InputDecoration(labelText: strings.presentation),
                  ),
                  const SizedBox(height: 10),
                  FilledButton(
                    onPressed: () async {
                      final height = double.tryParse(heightController.text);
                      final weight = double.tryParse(weightController.text);
                      if (height == null || weight == null) {
                        return;
                      }
                      final baseInput = heartRateBaseController.text.trim();
                      final returnInput = returnCueController.text.trim();
                      final baseBpm =
                          baseInput.isEmpty ? null : int.tryParse(baseInput);
                      final returnCueBpm = returnInput.isEmpty
                          ? null
                          : int.tryParse(returnInput);
                      String? nextBaseError;
                      String? nextReturnCueError;
                      if (baseInput.isNotEmpty && baseBpm == null) {
                        nextBaseError = strings.heartRateRangeError(40, 120);
                      }
                      if (returnInput.isNotEmpty && returnCueBpm == null) {
                        nextReturnCueError = strings.heartRateRangeError(60, 170);
                      }
                      if (baseBpm != null && (baseBpm < 40 || baseBpm > 120)) {
                        nextBaseError = strings.heartRateRangeError(40, 120);
                      }
                      if (returnCueBpm != null &&
                          (returnCueBpm < 60 || returnCueBpm > 170)) {
                        nextReturnCueError = strings.heartRateRangeError(60, 170);
                      }
                      if (nextBaseError != null || nextReturnCueError != null) {
                        setStateModal(() {
                          heartRateBaseError = nextBaseError;
                          returnCueError = nextReturnCueError;
                        });
                        return;
                      }

                      await appState.updateHeartRateCoachSettings(
                        baseBpm: baseBpm,
                        returnCueBpm: returnCueBpm,
                      );
                      await appState.updateProfile(
                        name: nameController.text,
                        heightCm: height,
                        weightKg: weight,
                        bodyType: selectedBodyType,
                        presentation: presentationController.text,
                        city: cityController.text,
                        gym: gymController.text,
                      );
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(strings.saveChanges),
                  ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

class _TopStat extends StatelessWidget {
  const _TopStat({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.4),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      borderRadius: BorderRadius.circular(AuraCard.radius),
      onTap: onTap,
      child: AuraCard(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _pickAvatarFromDevice(
    BuildContext context, AppState appState) async {
  final picked = await FilePicker.platform.pickFiles(
    dialogTitle: AppStrings.of(appState.languageCode).changeProfilePhoto,
    type: FileType.image,
    allowMultiple: false,
    withData: false,
  );
  if (picked == null || picked.files.isEmpty) {
    return;
  }

  final path = picked.files.first.path;
  if (path == null || path.isEmpty) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            appState.languageCode == 'en'
                ? 'The selected image could not be loaded.'
                : 'No se pudo cargar la imagen seleccionada.',
          ),
        ),
      );
    }
    return;
  }

  await appState.updateProfileAvatar(path);
}

Future<void> _showAvatarActions(
  BuildContext context,
  AppState appState, {
  required bool hasAvatar,
}) async {
  final strings = AppStrings.of(appState.languageCode);
  await showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.file_upload_outlined),
              title: Text(strings.changeProfilePhoto),
              onTap: () async {
                Navigator.of(context).pop();
                await _pickAvatarFromDevice(context, appState);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline),
              title: Text(strings.removeProfilePhoto),
              enabled: hasAvatar,
              onTap: hasAvatar
                  ? () async {
                      await appState.updateProfileAvatar(null);
                      if (context.mounted) {
                        Navigator.of(context).pop();
                      }
                    }
                  : null,
            ),
            ListTile(
              leading: const Icon(Icons.close),
              title: Text(strings.cancel),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        ),
      );
    },
  );
}

Future<void> _showAnnualLeagueInfoSheet(
  BuildContext context,
  AppState appState, {
  required int year,
  required int annualAuraPoints,
}) async {
  final strings = AppStrings.of(appState.languageCode);
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (context) {
      final theme = Theme.of(context);
      final currentLeague = AuraLeagueSystem.fromAnnualPoints(annualAuraPoints);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.sizeOf(context).height * 0.8,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(strings.annualLeague, style: theme.textTheme.titleLarge),
                  const SizedBox(height: 6),
                  Text(
                    '$year · $annualAuraPoints ${strings.auraPointsShort}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 12),
                  ...AuraLeagueSystem.orderedLeagues.map((league) {
                    final color = AuraLeagueSystem.color(league, theme);
                    final isCurrent = league == currentLeague;
                    final minPoints = AuraLeagueSystem.minPointsFor(league);
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: isCurrent ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color:
                                color.withValues(alpha: isCurrent ? 0.7 : 0.35),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(AuraLeagueSystem.icon(league), color: color),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${AuraLeagueSystem.localizedName(league, appState.languageCode)} · >= $minPoints ${strings.auraPointsShort}',
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                            if (isCurrent)
                              Icon(
                                Icons.check_circle,
                                size: 18,
                                color: color,
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

IconData _iconForSeverity(RecommendationSeverity severity) {
  switch (severity) {
    case RecommendationSeverity.high:
      return Icons.warning_amber_rounded;
    case RecommendationSeverity.medium:
      return Icons.error_outline;
    case RecommendationSeverity.low:
      return Icons.check_circle_outline;
  }
}

Color _colorForSeverity(RecommendationSeverity severity, ThemeData theme) {
  switch (severity) {
    case RecommendationSeverity.high:
      return Colors.deepOrange;
    case RecommendationSeverity.medium:
      return Colors.orange;
    case RecommendationSeverity.low:
      return theme.colorScheme.primary;
  }
}
