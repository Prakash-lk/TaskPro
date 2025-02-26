import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:provider/provider.dart';
import '../providers/task_provider.dart';
import '../models/task_model.dart';

class UpdateTaskScreen extends StatefulWidget {
  final Task task; // The task to be updated

  const UpdateTaskScreen({super.key, required this.task});

  @override
  _UpdateTaskScreenState createState() => _UpdateTaskScreenState();
}

class _UpdateTaskScreenState extends State<UpdateTaskScreen> {
  late TextEditingController _titleController;
  late TextEditingController _categoryController;
  late TextEditingController _priorityController;
  late TextEditingController _dueDateController;
  late TextEditingController _dueTimeController;
  late TextEditingController _dateController;
  late TextEditingController _timeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.task.title);
    _categoryController = TextEditingController(text: widget.task.category);
    _priorityController = TextEditingController(text: widget.task.priority);

    _dueDateController = TextEditingController(
      text: widget.task.dueDate != null
          ? DateFormat('yyyy-MM-dd').format(widget.task.dueDate!)
          : '',
    );
    _dueTimeController = TextEditingController(text: widget.task.dueTime ?? '');

    _dateController = TextEditingController(
      text: widget.task.date != null
          ? DateFormat('yyyy-MM-dd').format(widget.task.date!)
          : '',
    );
    _timeController = TextEditingController(text: widget.task.time ?? '');

    _descriptionController =
        TextEditingController(text: widget.task.description);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _categoryController.dispose();
    _priorityController.dispose();
    _dueDateController.dispose();
    _dueTimeController.dispose();
    _dateController.dispose();
    _timeController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _updateTask() {
    Task updatedTask = Task(
      id: widget.task.id,
      title: _titleController.text,
      category: _categoryController.text,
      priority: _priorityController.text,
      date: _dateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dateController.text)
          : null,
      time: _timeController.text,
      dueDate: _dueDateController.text.isNotEmpty
          ? DateFormat('yyyy-MM-dd').parse(_dueDateController.text)
          : null,
      dueTime: _dueTimeController.text,
      description: _descriptionController.text,
    );

    Provider.of<TaskProvider>(context, listen: false).updateTask(updatedTask);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Task')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
              ),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: _priorityController,
                decoration: InputDecoration(labelText: 'Priority'),
              ),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(labelText: 'Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.task.date ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                  }
                },
              ),
              TextField(
                controller: _timeController,
                decoration: InputDecoration(labelText: 'Time'),
              ),
              TextField(
                controller: _dueDateController,
                decoration: InputDecoration(labelText: 'Due Date'),
                readOnly: true,
                onTap: () async {
                  DateTime? selectedDate = await showDatePicker(
                    context: context,
                    initialDate: widget.task.dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (selectedDate != null) {
                    setState(() {
                      _dueDateController.text =
                          DateFormat('yyyy-MM-dd').format(selectedDate);
                    });
                  }
                },
              ),
              TextField(
                controller: _dueTimeController,
                decoration: InputDecoration(labelText: 'Due Time'),
                readOnly: true,
                onTap: () async {
                  TimeOfDay? selectedTime = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (selectedTime != null) {
                    setState(() {
                      _dueTimeController.text = selectedTime.format(context);
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateTask,
                child: Text('Update Task'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
