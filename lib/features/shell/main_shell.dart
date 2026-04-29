import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/localization/app_strings.dart';
import '../../core/state/app_state.dart';
import '../home/home_screen.dart';
import '../profile/profile_screen.dart';
import '../training/training_hub_screen.dart';

class MainShell extends StatefulWidget {
  const MainShell({
    super.key,
    required this.appState,
  });

  final AppState appState;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.appState,
      builder: (context, _) {
        final theme = Theme.of(context);
        final strings = AppStrings.of(widget.appState.languageCode);
        final pending = widget.appState.pendingIncomingRequestsCount;
        final screens = [
          HomeScreen(appState: widget.appState),
          TrainingHubScreen(appState: widget.appState),
          ProfileScreen(appState: widget.appState),
        ];

        return Scaffold(
          extendBody: false,
          body: AnimatedSwitcher(
            duration: widget.appState.menuAnimationsEnabled
                ? const Duration(milliseconds: 220)
                : Duration.zero,
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              if (!widget.appState.menuAnimationsEnabled) {
                return child;
              }
              final offset = Tween<Offset>(
                begin: const Offset(0.02, 0),
                end: Offset.zero,
              ).animate(animation);
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey(_index),
              child: screens[_index],
            ),
          ),
          bottomNavigationBar: DecoratedBox(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: theme.colorScheme.outline.withValues(alpha: 0.44),
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: ClipRect(
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                  child: NavigationBar(
                    backgroundColor:
                        theme.colorScheme.surface.withValues(alpha: 0.88),
                    selectedIndex: _index,
                    onDestinationSelected: (value) {
                      setState(() => _index = value);
                    },
                    destinations: [
                      NavigationDestination(
                        icon: _NavBadgeIcon(
                          icon: Icons.home_outlined,
                          badgeCount: pending,
                        ),
                        selectedIcon: _NavBadgeIcon(
                          icon: Icons.home_rounded,
                          badgeCount: pending,
                        ),
                        label: strings.home,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.fitness_center_outlined),
                        selectedIcon: const Icon(Icons.fitness_center),
                        label: strings.training,
                      ),
                      NavigationDestination(
                        icon: const Icon(Icons.person_outline),
                        selectedIcon: const Icon(Icons.person),
                        label: strings.profile,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _NavBadgeIcon extends StatelessWidget {
  const _NavBadgeIcon({
    required this.icon,
    required this.badgeCount,
  });

  final IconData icon;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Icon(icon),
        if (badgeCount > 0)
          Positioned(
            right: -10,
            top: -8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
              decoration: BoxDecoration(
                color: theme.colorScheme.error,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                badgeCount > 99 ? '99+' : '$badgeCount',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
