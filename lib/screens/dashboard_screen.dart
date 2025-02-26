import 'package:flutter/material.dart';
import '../widgets/task_card.dart';
import '../services/firebase_auth_service.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';
import 'package:provider/provider.dart';

class DashboardScreen extends StatelessWidget {
  final FirebaseAuthService _authService = FirebaseAuthService();

  DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TaskPro Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              _authService.logout();
              Navigator.pushReplacementNamed(context, '/login');
            },
          ),
        ],
      ),
      body: Consumer<TaskProvider>(builder: (context, taskProvider, child) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    TaskCategory(
                      category: 'Pending',
                      tasks: taskProvider.pendingTasks,
                    ),
                    TaskCategory(
                      category: 'Completed',
                      tasks: taskProvider.completedTasks,
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/add_task');
            },
            tooltip: 'Add Task',
            child: const Icon(Icons.add),
          ),
          const SizedBox(width: 10),
          FloatingActionButton(
            onPressed: () {
              Navigator.pushNamed(context, '/archived_tasks');
            },
            tooltip: 'View Archived Tasks',
            child: const Icon(Icons.archive),
          ),
        ],
      ),
    );
  }
}

class TaskCategory extends StatelessWidget {
  final String category;
  final List<Task> tasks;

  const TaskCategory({super.key, required this.category, required this.tasks});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Text(
              category,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            if (tasks.isNotEmpty)
              ...tasks.map((task) => TaskCard(task: task))
            else
              const Text(
                'No tasks available in this category.',
                style: TextStyle(color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }
}
