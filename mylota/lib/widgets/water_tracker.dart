import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WaterTracker extends StatefulWidget {
  @override
  _WaterTrackerState createState() => _WaterTrackerState();
}

class _WaterTrackerState extends State<WaterTracker> {
  double _waterIntake = 2.0; // Default water intake goal in litres

  @override
  void initState() {
    super.initState();
    _loadWaterIntake();
  }

  // Load saved water intake goal
  Future<void> _loadWaterIntake() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _waterIntake = prefs.getDouble('waterIntake') ?? 2.0;
    });
  }

  // Save water intake goal
  Future<void> _saveWaterIntake() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('waterIntake', _waterIntake);

      // Show success snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Water intake goal saved successfully!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save water intake goal.'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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
              'Set Your Daily Water Intake (Litres)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),

            // Water intake slider
            Slider(
              value: _waterIntake,
              min: 1.0,
              max: 5.0,
              divisions: 8,
              activeColor: Color(0xFF66C3A7), // Updated slider color
              thumbColor: Color(0xFF2A7F67), // Thumb color for consistency
              label: '${_waterIntake.toStringAsFixed(1)} L',
              onChanged: (value) {
                setState(() {
                  _waterIntake = value;
                });
              },
            ),

            Center(
              child: Text(
                'Goal: ${_waterIntake.toStringAsFixed(1)} Litres',
                style: TextStyle(fontSize: 16),
              ),
            ),

            SizedBox(height: 20),

            // Save button
            Center(
              child: ElevatedButton(
                onPressed: _saveWaterIntake,
                child: Text('Save Goal'),
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
