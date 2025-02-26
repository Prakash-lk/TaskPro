import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
// ignore: unused_import
import '../models/task_model.dart';

class ArchivedTasksScreen extends StatelessWidget {
  const ArchivedTasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final archivedTasks = Provider.of<TaskProvider>(context).archivedTasks;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Archived Tasks'),
      ),
      body: archivedTasks.isEmpty
          ? const Center(
              child: Text('No Archived Tasks'),
            )
          : ListView.builder(
              itemCount: archivedTasks.length,
              itemBuilder: (context, index) {
                final task = archivedTasks[index];
                return ListTile(
                  title: Text(task.title),
                  subtitle: Text(task.description ?? 'No description'),
                  trailing: IconButton(
                    icon: const Icon(Icons.restore),
                    onPressed: () {
                      Provider.of<TaskProvider>(context, listen: false)
                          .restoreTask(task);
                    },
                  ),
                );
              },
            ),
    );
  }
}
