import 'dart:async';
import 'package:flutter/material.dart';
import '../models/task.dart';
import '../theme.dart';

/// 倒计时任务卡片（进行中）— 杀进程后计时保持
class ActiveTaskCard extends StatefulWidget {
  final Task task;
  final VoidCallback onComplete;
  final VoidCallback onCancel;

  const ActiveTaskCard({
    super.key,
    required this.task,
    required this.onComplete,
    required this.onCancel,
  });

  @override
  State<ActiveTaskCard> createState() => _ActiveTaskCardState();
}

class _ActiveTaskCardState extends State<ActiveTaskCard> {
  Timer? _timer;
  late int _remainingSeconds;

  @override
  void initState() {
    super.initState();
    _remainingSeconds = widget.task.remainingSeconds();
    if (_remainingSeconds > 0) {
      _startTimer();
    } else {
      widget.onComplete();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        _remainingSeconds--;
        if (_remainingSeconds <= 0) {
          _timer?.cancel();
          widget.onComplete();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppTheme.accentForMode(AppMode.daily); // accent from parent context
    final isUrgent = _remainingSeconds <= 30;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.surfaceForMode(AppMode.daily),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.divider.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          // Drag handle
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Icon(Icons.drag_handle, color: AppTheme.secondaryText, size: 20),
          ),
          // Task info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Effort dot
                    Container(
                      width: 8,
                      height: 8,
                      margin: const EdgeInsets.only(right: 6),
                      decoration: BoxDecoration(
                        color: AppTheme.effortColor(widget.task.label.effort),
                        shape: BoxShape.circle,
                      ),
                    ),
                    Text(
                      widget.task.label.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: AppTheme.baseText,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _formatTime(_remainingSeconds),
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: isUrgent ? AppTheme.danger : accent,
                  ),
                ),
              ],
            ),
          ),
          // Complete button
          GestureDetector(
            onTap: widget.onComplete,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.success.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.check, color: AppTheme.success, size: 24),
            ),
          ),
          const SizedBox(width: 8),
          // Cancel button
          GestureDetector(
            onTap: widget.onCancel,
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppTheme.danger.withOpacity(0.15),
                borderRadius: BorderRadius.circular(22),
              ),
              child: const Icon(Icons.close, color: AppTheme.danger, size: 24),
            ),
          ),
        ],
      ),
    );
  }
}

/// 已完成任务卡片（dimmed）
class CompletedTaskCard extends StatelessWidget {
  final Task task;

  const CompletedTaskCard({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    final timeStr = task.completedAt != null
        ? '${task.completedAt!.hour.toString().padLeft(2, '0')}:${task.completedAt!.minute.toString().padLeft(2, '0')}'
        : '';

    return Opacity(
      opacity: 0.45,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.surfaceForMode(AppMode.daily),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppTheme.divider.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              margin: const EdgeInsets.only(right: 6),
              decoration: BoxDecoration(
                color: AppTheme.effortColor(task.label.effort),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(
                task.label.name,
                style: const TextStyle(fontSize: 15, color: AppTheme.baseText),
              ),
            ),
            Text(
              timeStr,
              style: const TextStyle(fontSize: 13, color: AppTheme.secondaryText),
            ),
          ],
        ),
      ),
    );
  }
}
