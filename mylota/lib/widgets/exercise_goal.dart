import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/notifications_service.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class ExerciseGoal extends StatefulWidget {
  @override
  _ExerciseGoalState createState() => _ExerciseGoalState();
}

class _ExerciseGoalState extends State<ExerciseGoal> {
  double _exerciseGoal = 30;
  String _selectedExercise = 'Running';

  final List<Map<String, dynamic>> _exerciseOptions = [
    {'name': 'Running', 'icon': Icons.directions_run},
    {'name': 'Cycling', 'icon': Icons.pedal_bike},
    {'name': 'Yoga', 'icon': Icons.self_improvement},
    {'name': 'Swimming', 'icon': Icons.pool},
    {'name': 'Weightlifting', 'icon': Icons.fitness_center},
    {'name': 'Walking', 'icon': Icons.directions_walk},
    {'name': 'Gym', 'icon': Icons.sports_gymnastics},
    {'name': 'Tennis', 'icon': Icons.sports_tennis},
  ];

  Future<void> _checkAndRequestAlarmPermission() async {
    // Check if the SCHEDULE_EXACT_ALARM permission is granted
    final status = await Permission.scheduleExactAlarm.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      _showPermissionDialog();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Enable Alarm Permission'),
        content: Text('This app requires exact alarm permission to remind you about your goals. '
            'Please enable it in settings.'),
        actions: [
          TextButton(
            onPressed: () async {
              final intent = AndroidIntent(
                action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
                package: 'com.example.mylota',
                flags: <int>[Flag.FLAG_ACTIVITY_NEW_TASK],
              );
              await intent.launch();
              Navigator.of(context).pop();
            },
            child: Text('Open Settings'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveExerciseGoal() async {
    try {
      await _checkAndRequestAlarmPermission();

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('exerciseGoal', _exerciseGoal);
      await prefs.setString('selectedExercise', _selectedExercise);

      await NotificationService.scheduleExerciseReminder(8, 0);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exercise goal and reminder set!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save goal: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Set Your Exercise Goal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedExercise,
              items: _exerciseOptions.map((exercise) {
                return DropdownMenuItem<String>(
                  value: exercise['name'],
                  child: Row(
                    children: [
                      Icon(exercise['icon'], color: Colors.green),
                      SizedBox(width: 10),
                      Text(exercise['name']),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedExercise = value!;
                });
              },
            ),
            SizedBox(height: 20),
            Text(
              'Set your daily goal (minutes):',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 10),
            Slider(
              value: _exerciseGoal,
              min: 10,
              max: 120,
              divisions: 11,
              activeColor: Color(0xFF66C3A7), // Updated slider color
              thumbColor: Color(0xFF2A7F67), // Thumb color for consistency
              label: '${_exerciseGoal.round()} mins',
              onChanged: (value) {
                setState(() {
                  _exerciseGoal = value;
                });
              },
            ),
            SizedBox(height: 20),
            Center(
            child: ElevatedButton(
              onPressed: _saveExerciseGoal,
              child: Text('Save Goal', style: TextStyle(color: Colors.black)),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                shadowColor: Colors.grey
              ),
            ),
            )
          ],
        ),
      ),
    );
  }
}
