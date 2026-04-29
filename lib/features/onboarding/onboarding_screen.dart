import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/primary_button.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/body_type.dart';
import '../../core/models/user_profile.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    required this.languageCode,
    required this.onCompleted,
  });

  final String languageCode;
  final Future<void> Function(UserProfile profile) onCompleted;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _pageController = PageController();
  final _nameController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  int _step = 0;
  BodyType _bodyType = BodyType.undefined;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_refreshFormState);
    _heightController.addListener(_refreshFormState);
    _weightController.addListener(_refreshFormState);
  }

  @override
  void dispose() {
    _nameController.removeListener(_refreshFormState);
    _heightController.removeListener(_refreshFormState);
    _weightController.removeListener(_refreshFormState);
    _pageController.dispose();
    _nameController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _refreshFormState() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  bool get _canContinue {
    switch (_step) {
      case 0:
        return _nameController.text.trim().isNotEmpty;
      case 1:
        return double.tryParse(_heightController.text) != null &&
            double.tryParse(_weightController.text) != null;
      case 2:
        return true;
      default:
        return false;
    }
  }

  Future<void> _next() async {
    if (_step < 2) {
      setState(() => _step += 1);
      await _pageController.animateToPage(
        _step,
        duration: const Duration(milliseconds: 320),
        curve: Curves.easeOutCubic,
      );
      return;
    }

    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);
    if (height == null || weight == null) {
      return;
    }

    setState(() => _isSubmitting = true);
    final profile = UserProfile(
      id: DateTime.now().microsecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      heightCm: height,
      weightKg: weight,
      bodyType: _bodyType,
      presentation: '',
      city: '',
      gym: '',
      createdAt: DateTime.now().toUtc(),
      updatedAt: DateTime.now().toUtc(),
    );
    await widget.onCompleted(profile);
    if (mounted) {
      setState(() => _isSubmitting = false);
    }
  }

  Future<void> _back() async {
    if (_step == 0) {
      return;
    }
    setState(() => _step -= 1);
    await _pageController.animateToPage(
      _step,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(widget.languageCode);

    return Scaffold(
      body: TintedBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              children: [
                _ProgressHeader(step: _step, strings: strings),
                const SizedBox(height: 24),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    children: [
                      _IntroStep(
                        nameController: _nameController,
                        strings: strings,
                      ),
                      _MetricsStep(
                        heightController: _heightController,
                        weightController: _weightController,
                        strings: strings,
                      ),
                      _BodyTypeStep(
                        selected: _bodyType,
                        strings: strings,
                        onSelected: (value) {
                          setState(() => _bodyType = value);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    if (_step > 0)
                      Expanded(
                        child: OutlinedButton(
                          onPressed: _isSubmitting ? null : _back,
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size.fromHeight(58),
                            side: BorderSide(color: theme.colorScheme.outline),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          child: Text(strings.back),
                        ),
                      ),
                    if (_step > 0) const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: PrimaryButton(
                        label:
                            _step == 2 ? strings.begin : strings.continueLabel,
                        onPressed:
                            (_canContinue && !_isSubmitting) ? _next : null,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  const _ProgressHeader({
    required this.step,
    required this.strings,
  });

  final int step;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          strings.onboardingTitle,
          style: theme.textTheme.displayLarge,
        ),
        const SizedBox(height: 14),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                margin: EdgeInsets.only(right: index == 2 ? 0 : 8),
                height: 6,
                decoration: BoxDecoration(
                  color: index <= step
                      ? theme.colorScheme.primary
                      : theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(999),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({
    required this.nameController,
    required this.strings,
  });

  final TextEditingController nameController;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: AuraCard(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.appName, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                strings.onboardingIntroCopy,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 28),
              Text(strings.name, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: nameController,
                textCapitalization: TextCapitalization.words,
                decoration: InputDecoration(
                  hintText: strings.nameHint,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MetricsStep extends StatelessWidget {
  const _MetricsStep({
    required this.heightController,
    required this.weightController,
    required this.strings,
  });

  final TextEditingController heightController;
  final TextEditingController weightController;
  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: AuraCard(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(strings.yourMetrics, style: theme.textTheme.headlineMedium),
              const SizedBox(height: 12),
              Text(
                strings.metricsCopy,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Text(strings.heightCm, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: heightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: '180'),
              ),
              const SizedBox(height: 18),
              Text(strings.weightKg, style: theme.textTheme.titleMedium),
              const SizedBox(height: 10),
              TextField(
                controller: weightController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(hintText: '78'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyTypeStep extends StatelessWidget {
  const _BodyTypeStep({
    required this.selected,
    required this.strings,
    required this.onSelected,
  });

  final BodyType selected;
  final AppStrings strings;
  final ValueChanged<BodyType> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Align(
      alignment: Alignment.topCenter,
      child: AuraCard(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            Text(strings.bodyType, style: theme.textTheme.headlineMedium),
            const SizedBox(height: 12),
            Text(
              strings.bodyTypeCopy,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ...BodyType.values.map(
              (type) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _BodyTypeTile(
                  type: type,
                  strings: strings,
                  isSelected: type == selected,
                  onTap: () => onSelected(type),
                ),
              ),
            ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BodyTypeTile extends StatelessWidget {
  const _BodyTypeTile({
    required this.type,
    required this.strings,
    required this.isSelected,
    required this.onTap,
  });

  final BodyType type;
  final AppStrings strings;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? theme.colorScheme.primaryContainer
              : theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.outline,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    type.titleFor(strings.languageCode),
                    style: theme.textTheme.titleMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    type.descriptionFor(strings.languageCode),
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              isSelected ? Icons.check_circle : Icons.circle_outlined,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}
