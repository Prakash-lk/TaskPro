import 'package:hive/hive.dart';
import '../models/task_model.dart';

class OfflineStorage {
  static Box? _taskBox;

  static Future<void> init() async {
    _taskBox = await Hive.openBox('tasks');
  }

  static Future<void> saveTask(Task task) async {
    await _taskBox?.add(task);
  }

  static List<Task> getTasks() {
    return _taskBox?.values.cast<Task>().toList() ?? [];
  }

  static Future<void> syncTasks(List<Task> tasks) async {
    for (var task in tasks) {
      await saveTask(task);
    }
  }
}
