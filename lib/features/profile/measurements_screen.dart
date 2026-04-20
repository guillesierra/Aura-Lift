import 'package:flutter/material.dart';

import '../../core/design_system/widgets/aura_card.dart';
import '../../core/design_system/widgets/tinted_background.dart';
import '../../core/localization/app_strings.dart';
import '../../core/models/body_type.dart';
import '../../core/models/user_profile.dart';

class MeasurementsScreen extends StatelessWidget {
  const MeasurementsScreen({
    super.key,
    required this.profile,
  });

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

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
                      strings.measurementsTitle,
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              AuraCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      profile.name,
                      style: theme.textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 18),
                    _MeasurementRow(
                      label: strings.height,
                      value: '${profile.heightCm.toStringAsFixed(0)} cm',
                    ),
                    const SizedBox(height: 14),
                    _MeasurementRow(
                      label: strings.weight,
                      value: '${profile.weightKg.toStringAsFixed(0)} kg',
                    ),
                    const SizedBox(height: 14),
                    _MeasurementRow(
                      label: strings.bodyType,
                      value: profile.bodyType.title,
                    ),
                    const SizedBox(height: 18),
                    Text(
                      profile.bodyType.description,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MeasurementRow extends StatelessWidget {
  const _MeasurementRow({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Expanded(
          child: Text(label, style: theme.textTheme.bodyMedium),
        ),
        Text(value, style: theme.textTheme.titleMedium),
      ],
    );
  }
}
