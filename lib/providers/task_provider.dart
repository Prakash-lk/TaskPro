import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:workmanager/workmanager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/task_model.dart';
import 'package:timezone/timezone.dart' as tz;

class TaskProvider with ChangeNotifier {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final List<Task> _tasks = [];

  List<Task> get pendingTasks =>
      _tasks.where((task) => task.category == 'Pending').toList();
  List<Task> get completedTasks =>
      _tasks.where((task) => task.category == 'Completed').toList();
  List<Task> get archivedTasks =>
      _tasks.where((task) => task.category == 'Archived').toList();

  TaskProvider() {
    _loadTasks();
    _initializeNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidInitializationSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(
      android: androidInitializationSettings,
    );

    await _notificationsPlugin.initialize(initializationSettings);
  }

  void addTask(Task task) {
    try {
      _tasks.add(task);
      saveTasksManually();
      notifyListeners();

      _scheduleNotification(task);

      if (task.isRecurring) {
        _scheduleRecurringTask(task);
      }
    } catch (e) {
      print('Error adding task: $e');
    }
  }

  void updateTask(Task updatedTask) {
    try {
      int taskIndex = _tasks.indexWhere((task) => task.id == updatedTask.id);
      if (taskIndex >= 0) {
        if (_tasks[taskIndex].isRecurring) {
          _cancelRecurringTask(updatedTask.id.toString());
        }

        _tasks[taskIndex] = updatedTask;
        saveTasksManually();
        notifyListeners();

        _scheduleNotification(updatedTask);

        if (updatedTask.isRecurring) {
          _scheduleRecurringTask(updatedTask);
        }
      } else {
        print('Task not found for update');
      }
    } catch (e) {
      print('Error updating task: $e');
    }
  }

  void updateTaskCategory(Task task, String newCategory) {
    try {
      task.category = newCategory;
      saveTasksManually();
      notifyListeners();
    } catch (e) {
      print('Error updating task category: $e');
    }
  }

  void archiveTask(Task task) {
    try {
      task.originalCategory = task.category;
      task.category = 'Archived';
      saveTasksManually();
      notifyListeners();
    } catch (e) {
      print('Error archiving task: $e');
    }
  }

  void unarchiveTask(Task task) {
    try {
      task.category = 'Pending';
      saveTasksManually();
      notifyListeners();
    } catch (e) {
      print('Error unarchiving task: $e');
    }
  }

  void restoreTask(Task task) {
    try {
      if (task.category == 'Archived' && task.originalCategory != null) {
        task.category = task.originalCategory!;
        saveTasksManually();
        notifyListeners();
      }
    } catch (e) {
      print('Error restoring task: $e');
    }
  }

  void deleteTask(String taskId) {
    try {
      _tasks.removeWhere((task) => task.id == taskId);
      saveTasksManually();
      notifyListeners();
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  void _scheduleRecurringTask(Task task) {
    try {
      if (task.isRecurring && task.recurringEndDate != null) {
        Workmanager().registerPeriodicTask(
          task.id.toString(),
          'recurring_task_${task.id}',
          frequency: const Duration(days: 1),
          inputData: {
            'taskId': task.id,
            'title': task.title,
          },
        );
        print('Recurring task scheduled: ${task.title}');
      }
    } catch (e) {
      print('Error scheduling recurring task: $e');
    }
  }

  void _cancelRecurringTask(String taskId) {
    try {
      Workmanager().cancelByUniqueName(taskId);
      print('Recurring task canceled: $taskId');
    } catch (e) {
      print('Error canceling recurring task: $e');
    }
  }

  static void callbackDispatcher() {
    Workmanager().executeTask((task, inputData) {
      final taskId = inputData?['taskId'];
      final taskTitle = inputData?['title'];
      print('Executing recurring task: $taskId - $taskTitle');
      return Future.value(true);
    });
  }

  void _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final String? taskData = prefs.getString('tasks');

    if (taskData != null) {
      final List<dynamic> decodedData = json.decode(taskData);
      _tasks.clear();
      _tasks.addAll(decodedData.map((task) => Task.fromJson(task)).toList());
      notifyListeners();
    }
  }

  void saveTasksManually() async {
    final prefs = await SharedPreferences.getInstance();
    final String encodedData =
        json.encode(_tasks.map((task) => task.toJson()).toList());
    prefs.setString('tasks', encodedData);
  }

  void _scheduleNotification(Task task) async {
    try {
      if (task.dueDate != null) {
        final notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'task_channel',
            'Task Notifications',
            channelDescription: 'Notifications for tasks',
            importance: Importance.high,
            priority: Priority.high,
            icon: '@mipmap/ic_launcher',
          ),
        );

        final scheduledTime = task.dueDate!;
        await _notificationsPlugin.zonedSchedule(
          int.parse(task.id),
          task.title,
          task.description,
          tz.TZDateTime.from(scheduledTime, tz.local),
          notificationDetails,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
        print('Scheduled notification for task: ${task.title}');
      }
    } catch (e) {
      print('Error scheduling notification: $e');
    }
  }
}
