import 'package:flutter/material.dart';

class SleepGoal extends StatefulWidget {
  @override
  _SleepGoalState createState() => _SleepGoalState();
}

class _SleepGoalState extends State<SleepGoal> {
  TimeOfDay? _bedTime;
  TimeOfDay? _wakeTime;

  Future<void> _pickTime(BuildContext context, bool isBedTime) async {
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: isBedTime
          ? (_bedTime ?? TimeOfDay(hour: 22, minute: 0))
          : (_wakeTime ?? TimeOfDay(hour: 6, minute: 0)),
    );

    if (pickedTime != null) {
      setState(() {
        if (isBedTime) {
          _bedTime = pickedTime;
        } else {
          _wakeTime = pickedTime;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(context, true),
                child: Text(
                  _bedTime == null
                      ? 'Set Bedtime'
                      : 'Bedtime: ${_bedTime!.format(context)}',
                ),
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.grey
                ),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () => _pickTime(context, false),
                child: Text(
                  _wakeTime == null
                      ? 'Set Wake-up Time'
                      : 'Wake: ${_wakeTime!.format(context)}',
                ),
                style: ElevatedButton.styleFrom(
                  shadowColor: Colors.grey
                ),
              ),
            ),
          ],
        ),
        if (_bedTime != null && _wakeTime != null)
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Text(
              'Sleep Duration: ${_calculateSleepDuration()} hours',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
          ),
      ],
    );
  }

  String _calculateSleepDuration() {
    final bedTimeMinutes = (_bedTime!.hour * 60) + _bedTime!.minute;
    final wakeTimeMinutes = (_wakeTime!.hour * 60) + _wakeTime!.minute;

    int durationMinutes;
    if (wakeTimeMinutes >= bedTimeMinutes) {
      durationMinutes = wakeTimeMinutes - bedTimeMinutes;
    } else {
      durationMinutes = (24 * 60 - bedTimeMinutes) + wakeTimeMinutes;
    }

    final hours = durationMinutes ~/ 60;
    final minutes = durationMinutes % 60;
    return '${hours}h ${minutes}m';
  }
}
