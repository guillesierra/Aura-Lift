import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/metrics/calorie_estimator.dart';
import '../../core/models/workout_session.dart';
import '../../core/state/app_state.dart';
import '../home/home_screen.dart';
import '../workout/workout_summary_detail_screen.dart';

class WorkoutCalendarScreen extends StatefulWidget {
  const WorkoutCalendarScreen({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<WorkoutCalendarScreen> createState() => _WorkoutCalendarScreenState();
}

class _WorkoutCalendarScreenState extends State<WorkoutCalendarScreen> {
  int? _selectedYear;

  @override
  Widget build(BuildContext context) {
    final appState = widget.appState;
    return AnimatedBuilder(
      animation: appState,
      builder: (context, _) {
        final theme = Theme.of(context);
        final strings = AppStrings.of(appState.languageCode);
        final profile = appState.profile!;
        final completedSessions = appState.sessions
            .where((session) => !session.isActive)
            .toList(growable: false)
          ..sort((a, b) => b.startedAt.compareTo(a.startedAt));
        final availableYears = completedSessions
            .map((session) => session.startedAt.toLocal().year)
            .toSet()
            .toList(growable: false)
          ..sort();
        final fallbackYear = availableYears.isEmpty
            ? DateTime.now().year
            : availableYears.last;
        final selectedYear = _selectedYear == null ||
                (!availableYears.contains(_selectedYear) &&
                    availableYears.isNotEmpty)
            ? fallbackYear
            : _selectedYear!;

        if (_selectedYear != selectedYear) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              setState(() {
                _selectedYear = selectedYear;
              });
            }
          });
        }

        final yearSessions = completedSessions
            .where((session) => session.startedAt.toLocal().year == selectedYear)
            .toList(growable: false);
        final days = _WorkoutDay.fromSessions(yearSessions);

        final currentYearIndex = availableYears.indexOf(selectedYear);
        final hasPreviousYear = currentYearIndex > 0;
        final hasNextYear = currentYearIndex >= 0 &&
            currentYearIndex < availableYears.length - 1;

        return Scaffold(
          body: TintedBackground(
            child: SafeArea(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
                children: [
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: const Icon(Icons.arrow_back_ios_new),
                      ),
                      Expanded(
                        child: Text(
                          strings.workoutCalendarTitle,
                          style: theme.textTheme.headlineMedium,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    completedSessions.isEmpty
                        ? strings.workoutCalendarEmpty
                        : strings.workoutCalendarCopy(completedSessions.length),
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 20),
                  if (days.isEmpty)
                    AuraCard(
                      child: Text(
                        strings.workoutCalendarEmpty,
                        style: theme.textTheme.bodyMedium,
                      ),
                    )
                  else ...[
                    _YearWorkoutCalendar(
                      year: selectedYear,
                      sessions: yearSessions,
                      onPreviousYear: hasPreviousYear
                          ? () {
                              setState(() {
                                _selectedYear = availableYears[currentYearIndex - 1];
                              });
                            }
                          : null,
                      onNextYear: hasNextYear
                          ? () {
                              setState(() {
                                _selectedYear = availableYears[currentYearIndex + 1];
                              });
                            }
                          : null,
                    ),
                    const SizedBox(height: 24),
                    ...days.map(
                      (day) => Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: _WorkoutDaySection(
                          day: day,
                          authorName: profile.name,
                          authorAvatarUrl: profile.avatarUrl,
                          bodyWeightKg: profile.weightKg,
                          highlightColor: theme.colorScheme.primary,
                          appState: appState,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _YearWorkoutCalendar extends StatelessWidget {
  const _YearWorkoutCalendar({
    required this.year,
    required this.sessions,
    this.onPreviousYear,
    this.onNextYear,
  });

  final int year;
  final List<WorkoutSession> sessions;
  final VoidCallback? onPreviousYear;
  final VoidCallback? onNextYear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeDayKeys = sessions.map((session) {
      final local = session.startedAt.toLocal();
      return _dateKey(local.year, local.month, local.day);
    }).toSet();

    return AuraCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousYear,
                icon: const Icon(Icons.chevron_left_rounded),
              ),
              Expanded(
                child: Center(
                  child: Text(
                    '$year',
                    style: theme.textTheme.headlineMedium,
                  ),
                ),
              ),
              IconButton(
                onPressed: onNextYear,
                icon: const Icon(Icons.chevron_right_rounded),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GridView.count(
            crossAxisCount: MediaQuery.of(context).size.width > 560 ? 3 : 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            childAspectRatio: 0.82,
            children: List.generate(12, (index) {
              return _MonthTrainingCard(
                year: year,
                month: index + 1,
                activeDayKeys: activeDayKeys,
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _MonthTrainingCard extends StatelessWidget {
  const _MonthTrainingCard({
    required this.year,
    required this.month,
    required this.activeDayKeys,
  });

  final int year;
  final int month;
  final Set<String> activeDayKeys;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    final daysInMonth = DateTime(year, month + 1, 0).day;
    final firstWeekday = DateTime(year, month, 1).weekday;
    final activeDays = List.generate(daysInMonth, (index) => index + 1)
        .where((day) => activeDayKeys.contains(_dateKey(year, month, day)))
        .toSet();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_monthName(month, strings), style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            strings.dayWorkoutCount(activeDays.length),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          Expanded(
            child: GridView.count(
              crossAxisCount: 7,
              crossAxisSpacing: 3,
              mainAxisSpacing: 3,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ...List.generate(firstWeekday - 1, (_) => const SizedBox()),
                ...List.generate(daysInMonth, (index) {
                  final day = index + 1;
                  final isActive = activeDays.contains(day);
                  return Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isActive
                          ? Colors.redAccent
                          : theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isActive
                            ? Colors.redAccent
                            : theme.colorScheme.outline,
                      ),
                    ),
                    child: Text(
                      '$day',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isActive ? Colors.white : null,
                        fontSize: 12,
                        fontWeight:
                            isActive ? FontWeight.w800 : FontWeight.w500,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String _monthName(int month, AppStrings strings) {
    final names = strings.isEnglish
        ? const [
            'Jan',
            'Feb',
            'Mar',
            'Apr',
            'May',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Oct',
            'Nov',
            'Dec',
          ]
        : const [
            'Ene',
            'Feb',
            'Mar',
            'Abr',
            'May',
            'Jun',
            'Jul',
            'Ago',
            'Sep',
            'Oct',
            'Nov',
            'Dic',
          ];
    return names[month - 1];
  }
}

String _dateKey(int year, int month, int day) {
  return '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
}

class _WorkoutDaySection extends StatelessWidget {
  const _WorkoutDaySection({
    required this.day,
    required this.authorName,
    this.authorAvatarUrl,
    required this.bodyWeightKg,
    required this.highlightColor,
    required this.appState,
  });

  final _WorkoutDay day;
  final String authorName;
  final String? authorAvatarUrl;
  final double bodyWeightKg;
  final Color highlightColor;
  final AppState appState;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _formatFullDate(day.date),
                style: theme.textTheme.titleLarge,
              ),
            ),
            Text(
              strings.dayWorkoutCount(day.sessions.length),
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...day.sessions.map(
          (session) => Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: WorkoutSummaryCard(
              session: session,
              authorName: authorName,
              authorHandle: authorName.toLowerCase(),
              authorAvatarUrl: authorAvatarUrl,
              highlightColor: highlightColor,
              estimatedCalories: CalorieEstimator.estimateWorkoutCalories(
                session: session,
                bodyWeightKg: bodyWeightKg,
              ),
              auraPoints: appState.auraPointsForSession(
                session,
                bodyWeightKg: bodyWeightKg,
              ),
              onTap: () async {
                await Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => WorkoutSummaryDetailScreen(
                      session: session,
                      authorName: authorName,
                      bodyWeightKg: bodyWeightKg,
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
    );
  }

  static String _formatFullDate(DateTime value) {
    return '${value.day.toString().padLeft(2, '0')}/'
        '${value.month.toString().padLeft(2, '0')}/${value.year}';
  }
}

class _WorkoutDay {
  const _WorkoutDay({
    required this.date,
    required this.sessions,
  });

  final DateTime date;
  final List<WorkoutSession> sessions;

  static List<_WorkoutDay> fromSessions(List<WorkoutSession> sessions) {
    final days = <_WorkoutDay>[];

    for (final session in sessions) {
      final local = session.startedAt.toLocal();
      final date = DateTime(local.year, local.month, local.day);
      if (days.isNotEmpty && _isSameDate(days.last.date, date)) {
        days[days.length - 1] = _WorkoutDay(
          date: days.last.date,
          sessions: [...days.last.sessions, session],
        );
        continue;
      }

      days.add(_WorkoutDay(date: date, sessions: [session]));
    }

    return days;
  }

  static bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }
}
