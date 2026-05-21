/// 应用模式
enum AppMode { rescue, daily, energy }

/// 体力消耗等级
enum EffortLevel { light, medium, heavy }

/// 任务状态
enum TaskStatus { active, completed, cancelled }

/// 预设标签定义
class TaskLabel {
  final String id;
  final String name;
  final EffortLevel effort;

  const TaskLabel({required this.id, required this.name, required this.effort});
}

/// 任务实例
class Task {
  final String id;
  final TaskLabel label;
  final int durationMinutes;
  final DateTime createdAt;
  final TaskStatus status;
  final DateTime? completedAt;

  Task({
    required this.id,
    required this.label,
    required this.durationMinutes,
    required this.createdAt,
    this.status = TaskStatus.active,
    this.completedAt,
  });

  /// 计算剩余秒数 — 支持杀进程后恢复计时
  int remainingSeconds() {
    if (status != TaskStatus.active) return 0;
    final totalSeconds = durationMinutes * 60;
    final elapsed = DateTime.now().difference(createdAt).inSeconds;
    final remaining = totalSeconds - elapsed;
    return remaining > 0 ? remaining : 0;
  }

  Task copyWith({TaskStatus? status, DateTime? completedAt}) {
    return Task(
      id: id,
      label: label,
      durationMinutes: durationMinutes,
      createdAt: createdAt,
      status: status ?? this.status,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'labelId': label.id,
        'labelName': label.name,
        'effort': label.effort.name,
        'durationMinutes': durationMinutes,
        'createdAt': createdAt.toIso8601String(),
        'status': status.name,
        'completedAt': completedAt?.toIso8601String(),
      };

  static Task fromJson(Map<String, dynamic> json, List<TaskLabel> labels) {
    final label = labels.firstWhere((l) => l.id == json['labelId']);
    return Task(
      id: json['id'],
      label: label,
      durationMinutes: json['durationMinutes'],
      createdAt: DateTime.parse(json['createdAt']),
      status: TaskStatus.values.byName(json['status']),
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : null,
    );
  }

  /// 预设标签库（三模式）
  static List<TaskLabel> labelsForMode(AppMode mode) {
    switch (mode) {
      case AppMode.rescue:
        return [
          const TaskLabel(id: 'r1', name: '深呼吸', effort: EffortLevel.light),
          const TaskLabel(id: 'r2', name: '从床上坐起来', effort: EffortLevel.light),
          const TaskLabel(id: 'r3', name: '洗脸', effort: EffortLevel.light),
          const TaskLabel(id: 'r4', name: '喝水', effort: EffortLevel.light),
          const TaskLabel(id: 'r5', name: '看一页书', effort: EffortLevel.light),
          const TaskLabel(id: 'r6', name: '换一件上衣', effort: EffortLevel.light),
          const TaskLabel(id: 'r7', name: '关掉社交软件', effort: EffortLevel.light),
        ];
      case AppMode.daily:
        return [
          const TaskLabel(id: 'd1', name: '洗碗', effort: EffortLevel.medium),
          const TaskLabel(id: 'd2', name: '洗衣服', effort: EffortLevel.heavy),
          const TaskLabel(id: 'd3', name: '扔垃圾', effort: EffortLevel.light),
          const TaskLabel(id: 'd4', name: '收拾厨房', effort: EffortLevel.medium),
          const TaskLabel(id: 'd5', name: '扫地', effort: EffortLevel.medium),
          const TaskLabel(id: 'd6', name: '拖地', effort: EffortLevel.medium),
          const TaskLabel(id: 'd7', name: '准备做饭食材', effort: EffortLevel.medium),
        ];
      case AppMode.energy:
        return [
          const TaskLabel(id: 'e1', name: '写一段练笔', effort: EffortLevel.medium),
          const TaskLabel(id: 'e2', name: '画画', effort: EffortLevel.medium),
          const TaskLabel(id: 'e3', name: '刻印', effort: EffortLevel.heavy),
          const TaskLabel(id: 'e4', name: '深入读书', effort: EffortLevel.medium),
          const TaskLabel(id: 'e5', name: '有氧拳击', effort: EffortLevel.heavy),
        ];
    }
  }
}
