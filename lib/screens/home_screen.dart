import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/task.dart';
import '../services/storage.dart';
import '../theme.dart';
import '../widgets/mode_tab_bar.dart';
import '../widgets/label_grid.dart';
import '../widgets/time_picker_sheet.dart';
import '../widgets/task_card.dart';
import '../widgets/confetti_overlay.dart';
import 'stats_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final storage = StorageService.instance;
  bool _showConfetti = false;
  String _confettiEffort = 'medium';

  @override
  void initState() {
    super.initState();
    storage.addListener(_refresh);
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    storage.removeListener(_refresh);
    super.dispose();
  }

  void _onLabelTap(TaskLabel label) {
    showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimePickerSheet(
        mode: storage.currentMode,
        label: label.name,
      ),
    ).then((minutes) {
      if (minutes != null) {
        storage.addTask(label, minutes);
      }
    });
  }

  void _onLabelLongPress(TaskLabel label) {
    HapticFeedback.mediumImpact();
    // Random pick — already handled by picking this label
    showModalBottomSheet<int>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => TimePickerSheet(
        mode: storage.currentMode,
        label: label.name,
      ),
    ).then((minutes) {
      if (minutes != null) {
        storage.addTask(label, minutes);
      }
    });
  }

  void _onCompleteTask(Task task) {
    setState(() {
      _confettiEffort = task.label.effort.name;
      _showConfetti = true;
    });
    storage.completeTask(task.id);
  }

  void _onCancelTask(String taskId) {
    storage.cancelTask(taskId);
  }

  @override
  Widget build(BuildContext context) {
    final mode = storage.currentMode;
    final bg = AppTheme.backgroundForMode(mode);
    final accent = AppTheme.accentForMode(mode);
    final labels = Task.labelsForMode(mode);
    final activeTasks = storage.tasks.where((t) => t.status == TaskStatus.active).toList();
    final completedToday = storage.tasks
        .where((t) =>
            t.status == TaskStatus.completed &&
            t.completedAt != null &&
            t.completedAt!.day == DateTime.now().day)
        .toList();

    final scaffold = Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: Text(
          '启动',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.baseText,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.bar_chart_rounded, color: accent),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const StatsScreen()),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ModeTabBar(
              current: mode,
              onChanged: (m) => storage.setMode(m),
            ),
            const SizedBox(height: 16),
            // Active tasks
            if (activeTasks.isNotEmpty) ...[
              ...activeTasks.map((t) => ActiveTaskCard(
                    key: ValueKey(t.id),
                    task: t,
                    onComplete: () => _onCompleteTask(t),
                    onCancel: () => _onCancelTask(t.id),
                  )),
              const SizedBox(height: 16),
              Divider(color: AppTheme.divider.withOpacity(0.5), indent: 16, endIndent: 16),
            ],
            // Label grid
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (activeTasks.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '选一个想做的事吧 🌱',
                          style: TextStyle(
                            fontSize: 15,
                            color: AppTheme.secondaryText,
                          ),
                        ),
                      ),
                    LabelGrid(
                      mode: mode,
                      labels: labels,
                      customLabels: storage.customLabels,
                      onTap: _onLabelTap,
                      onLongPress: _onLabelLongPress,
                    ),
                    // Completed today
                    if (completedToday.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      Divider(color: AppTheme.divider.withOpacity(0.3)),
                      const SizedBox(height: 8),
                      Text(
                        '✅ 已完成 (${completedToday.length})',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.secondaryText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...completedToday.map((t) => CompletedTaskCard(task: t)),
                    ],
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    if (_showConfetti) {
      return ConfettiOverlay.forEffort(
        child: scaffold,
        effort: _confettiEffort,
        onFinished: () {
          if (mounted) {
            setState(() => _showConfetti = false);
          }
        },
      );
    }

    return scaffold;
  }
}
