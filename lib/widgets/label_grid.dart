import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';

class LabelGrid extends StatelessWidget {
  final AppMode mode;
  final List<TaskLabel> labels;
  final List<TaskLabel> customLabels;
  final void Function(TaskLabel) onTap;
  final void Function(TaskLabel) onLongPress;

  const LabelGrid({
    super.key,
    required this.mode,
    required this.labels,
    required this.customLabels,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final allLabels = [...labels, ...customLabels];
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      alignment: WrapAlignment.center,
      children: [
        ...allLabels.map((label) => _LabelTile(
              label: label,
              mode: mode,
              onTap: () => onTap(label),
              onLongPress: () => onLongPress(label),
            )),
        _AddCustomTile(mode: mode),
      ],
    );
  }
}

class _LabelTile extends StatelessWidget {
  final TaskLabel label;
  final AppMode mode;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _LabelTile({
    required this.label,
    required this.mode,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        constraints: const BoxConstraints(minWidth: 88, minHeight: 44),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceForMode(mode),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            Center(
              child: Text(
                label.name,
                style: const TextStyle(
                  fontSize: 16,
                  color: AppTheme.baseText,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTheme.effortColor(label.effort),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AddCustomTile extends StatelessWidget {
  final AppMode mode;
  const _AddCustomTile({required this.mode});

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentForMode(mode);
    return Container(
      constraints: const BoxConstraints(minWidth: 88, minHeight: 44),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent, style: BorderStyle.solid, width: 1.5),
      ),
      child: Icon(Icons.add, color: accent, size: 24),
    );
  }
}
