import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';

class TimePickerSheet extends StatefulWidget {
  final AppMode mode;
  final String label;

  const TimePickerSheet({
    super.key,
    required this.mode,
    required this.label,
  });

  @override
  State<TimePickerSheet> createState() => _TimePickerSheetState();
}

class _TimePickerSheetState extends State<TimePickerSheet> {
  final options = [1, 3, 5, 10, 15];
  int selected = 3;

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentForMode(widget.mode);
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceElevatedForMode(widget.mode),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '「${widget.label}」需要多久？',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppTheme.baseText,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: options.map((min) {
              final active = selected == min;
              return GestureDetector(
                onTap: () => setState(() => selected = min),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: active ? accent : AppTheme.surfaceForMode(widget.mode),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '$min 分钟',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: active ? Colors.white : AppTheme.baseText,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context, selected),
              style: ElevatedButton.styleFrom(
                backgroundColor: accent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('开始', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}
