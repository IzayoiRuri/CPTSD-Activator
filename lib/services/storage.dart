import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../models/task.dart';

class StorageService extends ChangeNotifier {
  static final StorageService instance = StorageService._();
  StorageService._();

  String? _basePath;
  String get _labelsPath => '$_basePath/labels.json';

  // 当前任务列表
  List<Task> _tasks = [];
  List<Task> get tasks => List.unmodifiable(_tasks);

  // 自定义标签
  List<TaskLabel> _customLabels = [];
  List<TaskLabel> get customLabels => List.unmodifiable(_customLabels);

  // 历史归档: dateKey -> [Task]
  Map<String, List<Task>> _history = {};
  Map<String, List<Task>> get history => Map.unmodifiable(_history);

  // 当前模式
  AppMode _currentMode = AppMode.daily;
  AppMode get currentMode => _currentMode;

  Future<void> init() async {
    // Use relative path — Flutter resolves to app sandbox automatically
    _basePath = 'activate_data';
    await Directory(_basePath!).create(recursive: true);
    await _loadAll();
  }

  Future<void> _loadAll() async {
    // Load labels
    final labelsFile = File(_labelsPath);
    if (await labelsFile.exists()) {
      final json = jsonDecode(await labelsFile.readAsString());
      _customLabels = (json as List).map((l) => TaskLabel(
            id: l['id'],
            name: l['name'],
            effort: EffortLevel.values.byName(l['effort']),
          )).toList();
    }

    // Load today's tasks
    await _loadTodayTasks();

    // Load history
    await _loadHistory();

    notifyListeners();
  }

  Future<void> _loadTodayTasks() async {
    final file = File('$_basePath/${_todayKey()}.json');
    if (await file.exists()) {
      final json = jsonDecode(await file.readAsString());
      _tasks = (json as List).map((t) => Task.fromJson(t, _allLabels())).toList();
    }
  }

  Future<void> _loadHistory() async {
    final dir = Directory(_basePath!);
    final files = await dir.list().toList();
    final today = _todayKey();
    for (final f in files) {
      if (f is File && f.path.endsWith('.json') && !f.path.contains(today) && !f.path.contains('labels')) {
        final key = f.path.split('/').last.replaceAll('.json', '');
        try {
          final json = jsonDecode(await f.readAsString());
          _history[key] = (json as List)
              .map((t) => Task.fromJson(t, _allLabels()))
              .toList();
        } catch (_) {}
      }
    }
  }

  List<TaskLabel> _allLabels() => [
        ...Task.labelsForMode(AppMode.rescue),
        ...Task.labelsForMode(AppMode.daily),
        ...Task.labelsForMode(AppMode.energy),
        ..._customLabels,
      ];

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> save() async {
    final today = _todayKey();
    final todayTasks = <Task>[];
    final archiveMap = <String, List<Task>>{};

    for (final t in _tasks) {
      final taskDate = '${t.createdAt.year}-${t.createdAt.month.toString().padLeft(2, '0')}-${t.createdAt.day.toString().padLeft(2, '0')}';
      if (taskDate == today) {
        todayTasks.add(t);
      } else {
        archiveMap.putIfAbsent(taskDate, () => []).add(t);
      }
    }

    for (final entry in archiveMap.entries) {
      final file = File('$_basePath/${entry.key}.json');
      await file.writeAsString(jsonEncode(entry.value.map((t) => t.toJson()).toList()));
      _history[entry.key] = entry.value;
    }

    _tasks = todayTasks;
    final file = File('$_basePath/${_todayKey()}.json');
    await file.writeAsString(jsonEncode(_tasks.map((t) => t.toJson()).toList()));

    await File(_labelsPath)
        .writeAsString(jsonEncode(_customLabels.map((l) => {'id': l.id, 'name': l.name, 'effort': l.effort.name}).toList()));

    notifyListeners();
  }

  void addTask(TaskLabel label, int durationMinutes) {
    final task = Task(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      label: label,
      durationMinutes: durationMinutes,
      createdAt: DateTime.now(),
    );
    _tasks.add(task);
    save();
  }

  void completeTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      _tasks[idx] = _tasks[idx].copyWith(
        status: TaskStatus.completed,
        completedAt: DateTime.now(),
      );
      save();
    }
  }

  void cancelTask(String taskId) {
    final idx = _tasks.indexWhere((t) => t.id == taskId);
    if (idx >= 0) {
      _tasks[idx] = _tasks[idx].copyWith(status: TaskStatus.cancelled);
      save();
    }
  }

  void reorderTasks(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex--;
    final task = _tasks.removeAt(oldIndex);
    _tasks.insert(newIndex, task);
    save();
  }

  void setMode(AppMode mode) {
    _currentMode = mode;
    notifyListeners();
  }

  void addCustomLabel(String name, EffortLevel effort) {
    final id = 'custom_${DateTime.now().millisecondsSinceEpoch}';
    _customLabels.add(TaskLabel(id: id, name: name, effort: effort));
    save();
  }

  // ── 统计方法 ──

  List<Task> tasksForDate(String key) {
    if (key == _todayKey()) {
      return _tasks.where((t) => t.status == TaskStatus.completed).toList();
    }
    return (_history[key] ?? [])
        .where((t) => t.status == TaskStatus.completed)
        .toList();
  }

  int completedCountForDate(String key) => tasksForDate(key).length;

  int totalMinutesForDate(String key) =>
      tasksForDate(key).fold(0, (sum, t) => sum + t.durationMinutes);

  Map<String, int> effortBreakdownForDate(String key) {
    final tasks = tasksForDate(key);
    return {
      'light': tasks.where((t) => t.label.effort == EffortLevel.light).length,
      'medium': tasks.where((t) => t.label.effort == EffortLevel.medium).length,
      'heavy': tasks.where((t) => t.label.effort == EffortLevel.heavy).length,
    };
  }

  int get currentStreak {
    int streak = 0;
    final now = DateTime.now();
    for (int i = 0; i < 365; i++) {
      final d = now.subtract(Duration(days: i));
      final key = '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
      if (completedCountForDate(key) > 0) {
        streak++;
      } else if (i > 0) {
        break;
      }
    }
    return streak;
  }

  int get totalCompleted {
    int count = _tasks.where((t) => t.status == TaskStatus.completed).length;
    for (final tasks in _history.values) {
      count += tasks.where((t) => t.status == TaskStatus.completed).length;
    }
    return count;
  }

  int get totalMinutes {
    int mins = _tasks
        .where((t) => t.status == TaskStatus.completed)
        .fold(0, (sum, t) => sum + t.durationMinutes);
    for (final tasks in _history.values) {
      mins += tasks
          .where((t) => t.status == TaskStatus.completed)
          .fold(0, (sum, t) => sum + t.durationMinutes);
    }
    return mins;
  }

  List<String> get dateKeys {
    final keys = <String>{_todayKey()};
    keys.addAll(_history.keys);
    final sorted = keys.toList()..sort((a, b) => b.compareTo(a));
    return sorted;
  }
}
