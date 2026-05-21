import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';

class ModeTabBar extends StatelessWidget {
  final AppMode current;
  final ValueChanged<AppMode> onChanged;

  const ModeTabBar({super.key, required this.current, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppTheme.surfaceForMode(current),
        border: Border(bottom: BorderSide(color: AppTheme.divider.withOpacity(0.5))),
      ),
      child: Row(
        children: AppMode.values.map((mode) {
          final active = mode == current;
          final accent = AppTheme.accentForMode(mode);
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(mode),
              child: Container(
                alignment: Alignment.center,
                decoration: active
                    ? BoxDecoration(
                        color: accent,
                        borderRadius: BorderRadius.circular(8),
                      )
                    : null,
                margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
                child: Text(
                  '${AppTheme.modeEmoji(mode)} ${AppTheme.modeLabel(mode)}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: active ? Colors.white : AppTheme.secondaryText,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
