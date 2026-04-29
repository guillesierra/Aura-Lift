import 'package:flutter/material.dart';

import '../../../core/design_system/widgets/aura_card.dart';
import '../../../core/design_system/widgets/muscle_group_icon.dart';
import '../../../core/localization/app_strings.dart';
import '../../../core/models/exercise_history_snapshot.dart';
import '../../../core/models/session_exercise.dart';

class WorkoutSessionExerciseCard extends StatefulWidget {
  const WorkoutSessionExerciseCard({
    super.key,
    required this.exercise,
    required this.isSelected,
    required this.lastSnapshot,
    required this.onSelect,
    required this.onAddSet,
    required this.onDeleteExercise,
    required this.onDeleteSet,
  });

  final SessionExercise exercise;
  final bool isSelected;
  final ExerciseHistorySnapshot? lastSnapshot;
  final Future<void> Function() onSelect;
  final Future<void> Function(int reps, double weightKg) onAddSet;
  final Future<void> Function() onDeleteExercise;
  final Future<void> Function(String setId) onDeleteSet;

  @override
  State<WorkoutSessionExerciseCard> createState() =>
      _WorkoutSessionExerciseCardState();
}

class _WorkoutSessionExerciseCardState
    extends State<WorkoutSessionExerciseCard> {
  static const _showHeartRateExerciseSelector = true;

  final _weightController = TextEditingController();
  final _repsController = TextEditingController();
  final _weightFocus = FocusNode();
  bool _isAddingSet = false;
  bool _isSavingSet = false;
  bool _isDraftSuggested = false;

  @override
  void initState() {
    super.initState();
    _weightController.addListener(_onDraftChanged);
    _repsController.addListener(_onDraftChanged);
  }

  void _onDraftChanged() {
    if (!_isDraftSuggested) {
      return;
    }
    setState(() {
      _isDraftSuggested = false;
    });
  }

  @override
  void dispose() {
    _weightController.removeListener(_onDraftChanged);
    _repsController.removeListener(_onDraftChanged);
    _weightController.dispose();
    _repsController.dispose();
    _weightFocus.dispose();
    super.dispose();
  }

  void _startAddingSet() {
    final defaults = _defaultDraftValues();
    _weightController.text = defaults.weight;
    _repsController.text = defaults.reps;
    setState(() {
      _isAddingSet = true;
      _isDraftSuggested = defaults.isSuggestion;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _weightFocus.requestFocus();
      }
    });
  }

  Future<void> _saveDraftSet() async {
    final reps = int.tryParse(_repsController.text.trim());
    final normalizedWeight = _weightController.text.trim().replaceAll(',', '.');
    final weight = double.tryParse(normalizedWeight);
    if (reps == null || weight == null || reps <= 0 || weight < 0) {
      return;
    }

    setState(() => _isSavingSet = true);
    await widget.onAddSet(reps, weight);
    if (!mounted) {
      return;
    }

    _weightController.clear();
    _repsController.clear();
    setState(() {
      _isAddingSet = false;
      _isSavingSet = false;
      _isDraftSuggested = false;
    });
  }

  _DraftSetDefaults _defaultDraftValues() {
    final targetSetIndex = widget.exercise.sets.length;
    final previousSets = widget.lastSnapshot?.sets ?? const [];
    if (targetSetIndex >= 0 && targetSetIndex < previousSets.length) {
      final suggested = previousSets[targetSetIndex];
      return _DraftSetDefaults(
        weight: _formatNumber(suggested.weightKg),
        reps: suggested.reps.toString(),
        isSuggestion: true,
      );
    }

    if (widget.exercise.sets.isNotEmpty) {
      final last = widget.exercise.sets.last;
      return _DraftSetDefaults(
        weight: _formatNumber(last.weightKg),
        reps: last.reps.toString(),
        isSuggestion: false,
      );
    }

    if (previousSets.isNotEmpty) {
      final firstPrevious = previousSets.first;
      return _DraftSetDefaults(
        weight: _formatNumber(firstPrevious.weightKg),
        reps: firstPrevious.reps.toString(),
        isSuggestion: true,
      );
    }

    return const _DraftSetDefaults(weight: '', reps: '', isSuggestion: false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);
    const showSelector = _showHeartRateExerciseSelector;
    return InkWell(
      borderRadius: BorderRadius.circular(AuraCard.radius),
      onTap: showSelector
          ? () async {
              await widget.onSelect();
            }
          : null,
      child: AuraCard(
        borderColor: showSelector && widget.isSelected
            ? theme.colorScheme.primary
            : theme.colorScheme.outline.withValues(alpha: 0.4),
        borderWidth: showSelector && widget.isSelected ? 2 : 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                MuscleGroupIcon(
                    muscleGroup: widget.exercise.muscleGroup, size: 62),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.exercise.exerciseName,
                        style: theme.textTheme.titleLarge,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.exercise.muscleGroup,
                        style: theme.textTheme.bodyMedium,
                      ),
                      if (showSelector && widget.isSelected) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            strings.selectedExerciseForHeartRateBadge,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                IconButton(
                  tooltip: strings.deleteExercise,
                  onPressed: () async {
                    await widget.onDeleteExercise();
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _SetTableHeader(strings: strings),
            const SizedBox(height: 8),
            ...widget.exercise.sets.asMap().entries.map(
                  (entry) => _SetRow(
                    setId: entry.value.id,
                    index: entry.key + 1,
                    previousSet: _previousSetText(entry.key),
                    reps: entry.value.reps,
                    weightKg: entry.value.weightKg,
                    onDelete: widget.onDeleteSet,
                  ),
                ),
            if (_isAddingSet)
              _DraftSetRow(
                index: widget.exercise.sets.length + 1,
                previousSet: _previousSetText(widget.exercise.sets.length),
                weightController: _weightController,
                repsController: _repsController,
                weightFocus: _weightFocus,
                isSuggested: _isDraftSuggested,
                isSaving: _isSavingSet,
                onSave: _saveDraftSet,
              )
            else if (widget.exercise.sets.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12),
                child: Text(
                  strings.noSetsYet,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: FilledButton.tonalIcon(
                onPressed: _isAddingSet ? null : _startAddingSet,
                icon: const Icon(Icons.add),
                label: Text(
                  strings.isEnglish ? 'Add set' : 'Agregar serie',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _previousSetText(int index) {
    final sets = widget.lastSnapshot?.sets ?? const [];
    if (index < 0 || index >= sets.length) {
      return '-';
    }
    final set = sets[index];
    return '${_formatNumber(set.weightKg)}kg x ${set.reps}';
  }
}

class _DraftSetDefaults {
  const _DraftSetDefaults({
    required this.weight,
    required this.reps,
    required this.isSuggestion,
  });

  final String weight;
  final String reps;
  final bool isSuggestion;
}

String _formatNumber(double value) {
  return value % 1 == 0 ? value.toStringAsFixed(0) : value.toStringAsFixed(1);
}

class _SetTableHeader extends StatelessWidget {
  const _SetTableHeader({
    required this.strings,
  });

  final AppStrings strings;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelMedium?.copyWith(
      fontSize: 13,
      fontWeight: FontWeight.w800,
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Row(
      children: [
        SizedBox(
          width: 42,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(strings.set.toUpperCase(), style: style),
          ),
        ),
        Expanded(
          flex: 3,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              strings.isEnglish ? 'PREVIOUS' : 'ANTERIOR',
              style: style,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              'KG',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
        Expanded(
          flex: 2,
          child: FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.center,
            child: Text(
              'REPS',
              textAlign: TextAlign.center,
              style: style,
            ),
          ),
        ),
        const SizedBox(width: 46),
      ],
    );
  }
}

class _SetRow extends StatelessWidget {
  const _SetRow({
    required this.setId,
    required this.index,
    required this.previousSet,
    required this.reps,
    required this.weightKg,
    required this.onDelete,
  });

  final String setId;
  final int index;
  final String previousSet;
  final int reps;
  final double weightKg;
  final Future<void> Function(String setId) onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppStrings.of(Localizations.localeOf(context).languageCode);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primary.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text('$index', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(previousSet, style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            flex: 2,
            child: Text(
              _formatNumber(weightKg),
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          Expanded(
            flex: 2,
            child: Text(
              '$reps',
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
          ),
          SizedBox(
            width: 52,
            child: IconButton.filled(
              tooltip: strings.deleteSet,
              onPressed: () async {
                await onDelete(setId);
              },
              icon: const Icon(Icons.check_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftSetRow extends StatelessWidget {
  const _DraftSetRow({
    required this.index,
    required this.previousSet,
    required this.weightController,
    required this.repsController,
    required this.weightFocus,
    required this.isSuggested,
    required this.isSaving,
    required this.onSave,
  });

  final int index;
  final String previousSet;
  final TextEditingController weightController;
  final TextEditingController repsController;
  final FocusNode weightFocus;
  final bool isSuggested;
  final bool isSaving;
  final Future<void> Function() onSave;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color:
            theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.48),
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 42,
            child: Text('$index', style: theme.textTheme.titleMedium),
          ),
          Expanded(
            flex: 3,
            child: Text(previousSet, style: theme.textTheme.bodyLarge),
          ),
          Expanded(
            flex: 2,
            child: _InlineNumberField(
              controller: weightController,
              focusNode: weightFocus,
              isSuggested: isSuggested,
              onSubmitted: (_) => onSave(),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            flex: 2,
            child: _InlineNumberField(
              controller: repsController,
              isSuggested: isSuggested,
              onSubmitted: (_) => onSave(),
            ),
          ),
          SizedBox(
            width: 52,
            child: IconButton.filledTonal(
              onPressed: isSaving ? null : onSave,
              icon: isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.check_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _InlineNumberField extends StatelessWidget {
  const _InlineNumberField({
    required this.controller,
    required this.onSubmitted,
    required this.isSuggested,
    this.focusNode,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final ValueChanged<String> onSubmitted;
  final bool isSuggested;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      textAlign: TextAlign.center,
      style: theme.textTheme.titleMedium?.copyWith(
        color: isSuggested
            ? theme.colorScheme.onSurfaceVariant
            : theme.colorScheme.onSurface,
      ),
      onSubmitted: onSubmitted,
      decoration: const InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      ),
    );
  }
}
