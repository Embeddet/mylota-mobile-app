import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';



class ToDoList extends StatefulWidget {
  @override
  _ToDoListState createState() => _ToDoListState();
}

class _ToDoListState extends State<ToDoList> {
  Map<String, List<String>> tasks = {
    'Monday': [],
    'Tuesday': [],
    'Wednesday': [],
    'Thursday': [],
    'Friday': [],
    'Saturday': [],
    'Sunday': [],
  };

  String _selectedDay = 'Monday';
  final TextEditingController _taskController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  // Load tasks from SharedPreferences
  Future<void> _loadTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final String? storedTasks = prefs.getString('tasks');

      if (storedTasks != null && storedTasks.isNotEmpty) {
        setState(() {
          tasks = Map<String, List<String>>.from(
            jsonDecode(storedTasks).map(
                  (key, value) => MapEntry(key, List<String>.from(value)),
            ),
          );
        });
      }
    } catch (e) {
      print('Error loading tasks: $e');
    }
  }

  // Save tasks to SharedPreferences
  Future<void> _saveTasks() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('tasks', jsonEncode(tasks));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('To-Do List saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save tasks. Please try again.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }


  // Add a task to the selected day's list
  void _addTask() {
    if (_taskController.text.isNotEmpty) {
      setState(() {
        tasks[_selectedDay]?.add(_taskController.text);
        _taskController.clear();
        _saveTasks();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please enter a task'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Remove a task from the selected day's list
  void _removeTask(int index) {
    setState(() {
      tasks[_selectedDay]?.removeAt(index);
      _saveTasks();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your To-Do List',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Dropdown for selecting day
            DropdownButtonFormField<String>(
              value: _selectedDay,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 16),
              ),
              items: tasks.keys.map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedDay = value!;
                });
              },
            ),

            SizedBox(height: 20),

            // Task input field
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                labelText: 'Enter task',
                border: OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(Icons.add, color: Colors.green),
                  onPressed: _addTask,
                ),
              ),
            ),
            SizedBox(height: 20),

            // Task List with constraints
            tasks[_selectedDay]!.isEmpty
                ? Center(
              child: Text(
                'No tasks yet. Add one!',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: tasks[_selectedDay]?.length ?? 0,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(tasks[_selectedDay]![index]),
                  trailing: IconButton(
                    icon: Icon(Icons.delete, color: Colors.red),
                    onPressed: () => _removeTask(index),
                  ),
                );
              },
            ),

            SizedBox(height: 20),

            // Save button
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  await _saveTasks();
                },
                child: Text('Save To-Do List'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                  shadowColor: Colors.grey
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
