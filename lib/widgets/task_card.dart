import 'package:flutter/material.dart';
import '../models/task_model.dart';
import '../providers/task_provider.dart';
import 'package:provider/provider.dart';

class TaskCard extends StatefulWidget {
  final Task task;

  const TaskCard({super.key, required this.task});

  @override
  _TaskCardState createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    String title = widget.task.title;
    String description = widget.task.description ?? '';

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 5),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (widget.task.date != null && widget.task.time != null)
                    Text(
                      '${_formatDate(widget.task.date!)} ${widget.task.time}',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    description,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Priority: ${widget.task.priority}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.blue,
                        ),
                      ),
                      if (widget.task.dueDate != null &&
                          widget.task.dueTime != null)
                        Text(
                          'Due: ${_formatDate(widget.task.dueDate!)} ${widget.task.dueTime}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.red,
                          ),
                        ),
                    ],
                  ),
                ],
              ),
              crossFadeState: _isExpanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.archive, color: Colors.grey),
                  label: const Text(
                    'Archive',
                    style: TextStyle(color: Colors.grey),
                  ),
                  onPressed: () {
                    Provider.of<TaskProvider>(context, listen: false)
                        .archiveTask(widget.task);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.edit, color: Colors.blue),
                  label: const Text(
                    'Update',
                    style: TextStyle(color: Colors.blue),
                  ),
                  onPressed: () {
                    _showUpdateTaskDialog(context, widget.task);
                  },
                ),
                TextButton.icon(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  label: const Text(
                    'Delete',
                    style: TextStyle(color: Colors.red),
                  ),
                  onPressed: () {
                    Provider.of<TaskProvider>(context, listen: false)
                        .deleteTask(widget.task.id);
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showUpdateTaskDialog(BuildContext context, Task task) {
    final TextEditingController titleController =
        TextEditingController(text: task.title);
    final TextEditingController descriptionController =
        TextEditingController(text: task.description ?? '');
    String selectedPriority = task.priority.isNotEmpty ? task.priority : 'Low';
    String selectedCategory =
        task.category.isNotEmpty ? task.category : 'Pending';
    DateTime? selectedDate = task.date;
    String? selectedTime = task.time;
    DateTime? selectedDueDate = task.dueDate;
    String? selectedDueTime = task.dueTime;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Update Task'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(labelText: 'Task Title'),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration:
                          const InputDecoration(labelText: 'Task Description'),
                    ),
                    DropdownButton<String>(
                      value: selectedPriority,
                      onChanged: (value) {
                        setState(() {
                          selectedPriority = value!;
                        });
                      },
                      items: ['Low', 'Medium', 'High']
                          .map((priority) => DropdownMenuItem(
                                value: priority,
                                child: Text(priority),
                              ))
                          .toList(),
                    ),
                    DropdownButton<String>(
                      value: selectedCategory,
                      onChanged: (value) {
                        setState(() {
                          selectedCategory = value!;
                        });
                      },
                      items: ['Pending', 'Completed']
                          .map((category) => DropdownMenuItem(
                                value: category,
                                child: Text(category),
                              ))
                          .toList(),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        selectedDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        setState(() {});
                      },
                      child: Text(selectedDate != null
                          ? 'Date: ${_formatDate(selectedDate!)}'
                          : 'Select Date'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (time != null) {
                          selectedTime = time.format(context);
                        }
                        setState(() {});
                      },
                      child: Text(selectedTime != null
                          ? 'Time: $selectedTime'
                          : 'Select Time'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        selectedDueDate = await showDatePicker(
                          context: context,
                          initialDate: selectedDueDate ?? DateTime.now(),
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        setState(() {});
                      },
                      child: Text(selectedDueDate != null
                          ? 'Due Date: ${_formatDate(selectedDueDate!)}'
                          : 'Select Due Date'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final dueTime = await showTimePicker(
                          context: context,
                          initialTime: TimeOfDay.now(),
                        );
                        if (dueTime != null) {
                          selectedDueTime = dueTime.format(context);
                        }
                        setState(() {});
                      },
                      child: Text(selectedDueTime != null
                          ? 'Due Time: $selectedDueTime'
                          : 'Select Due Time'),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    task.title = titleController.text;
                    task.description =
                        descriptionController.text; // Update description
                    task.priority = selectedPriority;
                    task.category = selectedCategory;
                    task.date = selectedDate;
                    task.time = selectedTime;
                    task.dueDate = selectedDueDate;
                    task.dueTime = selectedDueTime;

                    Provider.of<TaskProvider>(context, listen: false)
                        .updateTask(task);

                    Navigator.of(context).pop();
                  },
                  child: const Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
