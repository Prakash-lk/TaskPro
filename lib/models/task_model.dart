// ignore: unused_import
import 'dart:convert';

class Task {
  final String id;
  String title;
  String category;
  String priority;
  final bool isRecurring;
  Duration repeatInterval;
  final DateTime? recurringEndDate;

  DateTime? date;
  DateTime? dueDate;
  String? time;
  String? dueTime;

  String? description;

  String? originalCategory;

  // Constructor for Task class
  Task({
    required this.id,
    required this.title,
    required this.category,
    required this.priority,
    this.isRecurring = false,
    this.repeatInterval = const Duration(days: 1),
    this.recurringEndDate,
    this.date,
    this.dueDate,
    this.time,
    this.dueTime,
    this.description,
    this.originalCategory,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'isRecurring': isRecurring,
      'repeatInterval': repeatInterval.inSeconds,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
      'date': date?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'time': time,
      'dueTime': dueTime,
      'description': description,
      'originalCategory': originalCategory,
    };
  }

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      priority: json['priority'] ?? '',
      isRecurring: json['isRecurring'] ?? false,
      repeatInterval: Duration(seconds: json['repeatInterval'] ?? 0),
      recurringEndDate: json['recurringEndDate'] != null
          ? DateTime.parse(json['recurringEndDate'])
          : null,
      date: json['date'] != null ? DateTime.parse(json['date']) : null,
      dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
      time: json['time'],
      dueTime: json['dueTime'],
      description: json['description'],
      originalCategory: json['originalCategory'],
    );
  }

  // Optional: Method to convert the task to a Map (for saving to a database or other storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'category': category,
      'priority': priority,
      'isRecurring': isRecurring,
      'repeatInterval': repeatInterval.inSeconds,
      'recurringEndDate': recurringEndDate?.toIso8601String(),
      'date': date?.toIso8601String(),
      'dueDate': dueDate?.toIso8601String(),
      'time': time,
      'dueTime': dueTime,
      'description': description,
      'originalCategory': originalCategory,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      category: map['category'] ?? '',
      priority: map['priority'] ?? '',
      isRecurring: map['isRecurring'] ?? false,
      repeatInterval: Duration(seconds: map['repeatInterval'] ?? 0),
      recurringEndDate: map['recurringEndDate'] != null
          ? DateTime.parse(map['recurringEndDate'])
          : null,
      date: map['date'] != null ? DateTime.parse(map['date']) : null,
      dueDate: map['dueDate'] != null ? DateTime.parse(map['dueDate']) : null,
      time: map['time'],
      dueTime: map['dueTime'],
      description: map['description'],
      originalCategory: map['originalCategory'],
    );
  }
}
