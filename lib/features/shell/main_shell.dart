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
    final strings = AppStrings.of(widget.appState.languageCode);
    final screens = [
      HomeScreen(appState: widget.appState),
      TrainingHubScreen(appState: widget.appState),
      ProfileScreen(appState: widget.appState),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: screens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (value) {
          setState(() => _index = value);
        },
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home_rounded),
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
    );
  }
}
