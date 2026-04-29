import 'package:flutter/material.dart';

import '../../../core/localization/app_strings.dart';

Future<bool?> confirmWorkoutDelete(
  BuildContext context, {
  required String title,
  required String message,
}) {
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.delete),
          ),
        ],
      );
    },
  );
}

Future<bool?> confirmFinishWorkout(BuildContext context) {
  final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
  return showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(strings.finishWorkoutTitle),
        content: Text(strings.finishWorkoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(strings.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(strings.finish),
          ),
        ],
      );
    },
  );
}
