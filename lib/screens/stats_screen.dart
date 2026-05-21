import 'package:flutter/material.dart';
import '../services/storage.dart';
import '../theme.dart';

class StatsScreen extends StatefulWidget {
  const StatsScreen({super.key});

  @override
  State<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends State<StatsScreen> {
  final storage = StorageService.instance;

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

  @override
  Widget build(BuildContext context) {
    final keys = storage.dateKeys;
    final today = keys.isNotEmpty ? keys.first : '';
    final totalCompleted = storage.totalCompleted;
    final totalMinutes = storage.totalMinutes;
    final streak = storage.currentStreak;

    // Today's breakdown
    int todayCompleted = 0;
    int todayMinutes = 0;
    Map<String, int> breakdown = {'light': 0, 'medium': 0, 'heavy': 0};
    if (today.isNotEmpty) {
      todayCompleted = storage.completedCountForDate(today);
      todayMinutes = storage.totalMinutesForDate(today);
      breakdown = storage.effortBreakdownForDate(today);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0E0D0C),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E0D0C),
        title: const Text('统计', style: TextStyle(color: Colors.white70)),
        iconTheme: const IconThemeData(color: Colors.white70),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 总览卡片
            Row(
              children: [
                _StatCard(
                  label: '总完成',
                  value: '$totalCompleted',
                  emoji: '🏆',
                  color: AppTheme.success,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: '总耗时',
                  value: '${totalMinutes}min',
                  emoji: '⏱️',
                  color: AppTheme.effortMedium,
                ),
                const SizedBox(width: 12),
                _StatCard(
                  label: '连续天数',
                  value: '$streak',
                  emoji: '🔥',
                  color: AppTheme.effortHeavy,
                ),
              ],
            ),
            const SizedBox(height: 28),

            // 今日统计
            if (today.isNotEmpty) ...[
              Text(
                '今日 ($today)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _MiniStat(label: '完成', value: '$todayCompleted'),
                  _MiniStat(label: '耗时', value: '${todayMinutes}min'),
                ],
              ),
              const SizedBox(height: 16),

              // 体力分布
              const Text(
                '体力分布',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white54,
                ),
              ),
              const SizedBox(height: 8),
              _EffortBar(label: '🔵 轻度', count: breakdown['light'] ?? 0, color: AppTheme.effortLight),
              _EffortBar(label: '🟡 中度', count: breakdown['medium'] ?? 0, color: AppTheme.effortMedium),
              _EffortBar(label: '🔴 重度', count: breakdown['heavy'] ?? 0, color: AppTheme.effortHeavy),
              const SizedBox(height: 24),
            ],

            // 历史日期列表
            if (keys.length > 1) ...[
              const Divider(color: AppTheme.divider),
              const SizedBox(height: 12),
              const Text(
                '历史记录',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              ...keys.skip(1).map((key) {
                final count = storage.completedCountForDate(key);
                final mins = storage.totalMinutesForDate(key);
                if (count == 0) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Text(key, style: const TextStyle(color: Colors.white54, fontSize: 14)),
                      const SizedBox(width: 16),
                      Text('$count 项', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                      const SizedBox(width: 12),
                      Text('$mins min', style: const TextStyle(color: Colors.white38, fontSize: 13)),
                    ],
                  ),
                );
              }),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String emoji;
  final Color color;
  const _StatCard({
    required this.label,
    required this.value,
    required this.emoji,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 8),
            Text(value,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: color)),
            const SizedBox(height: 4),
            Text(label, style: const TextStyle(fontSize: 12, color: Colors.white38)),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.white)),
          const SizedBox(height: 2),
          Text(label, style: const TextStyle(fontSize: 13, color: Colors.white38)),
        ],
      ),
    );
  }
}

class _EffortBar extends StatelessWidget {
  final String label;
  final int count;
  final Color color;
  const _EffortBar({required this.label, required this.count, required this.color});

  @override
  Widget build(BuildContext context) {
    final maxCount = 10;
    final fraction = (count / (maxCount > 0 ? maxCount : 1)).clamp(0.0, 1.0);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          SizedBox(width: 70, child: Text(label, style: const TextStyle(color: Colors.white70, fontSize: 13))),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: fraction,
                backgroundColor: color.withOpacity(0.15),
                valueColor: AlwaysStoppedAnimation(color),
                minHeight: 8,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text('$count', style: const TextStyle(color: Colors.white54, fontSize: 13)),
        ],
      ),
    );
  }
}
