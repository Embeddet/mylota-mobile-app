import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ProgressPage extends StatefulWidget {
  final double exerciseGoal;
  final double sleepGoal;
  final double waterIntakeGoal;
  final List<String> todoList;
  final List<String> meals;

  const ProgressPage({
    Key? key,
    required this.exerciseGoal,
    required this.sleepGoal,
    required this.waterIntakeGoal,
    required this.todoList,
    required this.meals,
  }) : super(key: key);

  @override
  _ProgressPageState createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  double exerciseProgress = 0.0;
  double sleepProgress = 0.0;
  double waterIntakeProgress = 0.0;
  double todoProgress = 0.0;
  double mealProgress = 0.0;

  List<String> completedTodos = [];
  List<String> completedMeals = [];
  double waterConsumed = 0.0;

  Duration exerciseCountdown = Duration();
  Duration sleepCountdown = Duration();
  Timer? exerciseTimer;
  Timer? sleepTimer;

  @override
  void initState() {
    super.initState();
    exerciseCountdown = Duration(minutes: widget.exerciseGoal.toInt());
    sleepCountdown = Duration(hours: widget.sleepGoal.toInt());
    _startCountdownTimers();
  }

  @override
  void dispose() {
    exerciseTimer?.cancel();
    sleepTimer?.cancel();
    super.dispose();
  }

  void _startCountdownTimers() {
    exerciseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (exerciseCountdown.inSeconds > 0) {
          exerciseCountdown -= const Duration(seconds: 1);
          exerciseProgress = 100.0 - (exerciseCountdown.inSeconds / (widget.exerciseGoal * 60)) * 100.0;
        } else {
          exerciseTimer?.cancel();
        }
      });
    });

    sleepTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (sleepCountdown.inSeconds > 0) {
          sleepCountdown -= const Duration(seconds: 1);
          sleepProgress = 100.0 - (sleepCountdown.inSeconds / (widget.sleepGoal * 3600)) * 100.0;
        } else {
          sleepTimer?.cancel();
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width; // Get screen width

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Progress',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)],
            ),
          ),
        ),
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildFullWidthContainer(
                  screenWidth: screenWidth,
                  child: _buildCountdownDisplay('Exercise Countdown', exerciseCountdown),
                ),
                const SizedBox(height: 20),
                _buildFullWidthContainer(
                  screenWidth: screenWidth,
                  child: _buildCheckListProgress(
                    title: 'To-Do List',
                    items: widget.todoList,
                    completedItems: completedTodos,
                    onItemChecked: (task, isChecked) {
                      setState(() {
                        if (isChecked) {
                          completedTodos.add(task);
                        } else {
                          completedTodos.remove(task);
                        }
                        todoProgress = (completedTodos.length / widget.todoList.length) * 100;
                      });
                    },
                  ),
                ),
                _buildFullWidthContainer(
                  screenWidth: screenWidth,
                  child: _buildCheckListProgress(
                    title: 'Meal Planner',
                    items: widget.meals,
                    completedItems: completedMeals,
                    onItemChecked: (meal, isChecked) {
                      setState(() {
                        if (isChecked) {
                          completedMeals.add(meal);
                        } else {
                          completedMeals.remove(meal);
                        }
                        mealProgress = (completedMeals.length / widget.meals.length) * 100;
                      });
                    },
                  ),
                ),
                _buildFullWidthContainer(
                  screenWidth: screenWidth,
                  child: _buildWaterTracker(),
                ),
                _buildFullWidthContainer(
                  screenWidth: screenWidth,
                  child: _buildCountdownDisplay('Sleep Countdown', sleepCountdown),
                ),
                _buildFullWidthContainer(
                  screenWidth: screenWidth,
                  child: _buildChartContainer(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFullWidthContainer({required double screenWidth, required Widget child}) {
    return Container(
      width: screenWidth * 0.95, // Stretch to 95% of screen width
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            spreadRadius: 3,
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.all(18),
      child: child,
    );
  }

  Widget _buildCheckListProgress({
    required String title,
    required List<String> items,
    required List<String> completedItems,
    required Function(String, bool) onItemChecked,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        if (items.isEmpty)
          const Text("No items added yet!", style: TextStyle(color: Colors.grey, fontSize: 14)), // Handle empty list
        ...items.map((item) {
          return CheckboxListTile(
            title: Text(item),
            value: completedItems.contains(item),
            onChanged: (bool? isChecked) {
              setState(() {
                if (isChecked == true) {
                  completedItems.add(item);
                } else {
                  completedItems.remove(item);
                }
                todoProgress = (completedTodos.length / widget.todoList.length) * 100;
                mealProgress = (completedMeals.length / widget.meals.length) * 100;
              });
            },
            controlAffinity: ListTileControlAffinity.leading, // Aligns checkbox to left
            activeColor: Colors.green, // Set checkbox color
          );
        }).toList(),
      ],
    );
  }


  Widget _buildCountdownDisplay(String title, Duration countdown) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Text(
          '${countdown.inHours.toString().padLeft(2, '0')}:' +
              '${(countdown.inMinutes % 60).toString().padLeft(2, '0')}:' +
              '${(countdown.inSeconds % 60).toString().padLeft(2, '0')}',
          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildWaterTracker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Water Intake', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Slider(
          value: waterConsumed,
          min: 0,
          max: widget.waterIntakeGoal,
          activeColor: Color(0xFF66C3A7), // Updated slider color
          thumbColor: Color(0xFF2A7F67), // Thumb color for consistency
          onChanged: (value) {
            setState(() {
              waterConsumed = value;
              waterIntakeProgress = (waterConsumed / widget.waterIntakeGoal) * 100;
            });
          },
        ),
        Text('${waterConsumed.toStringAsFixed(1)}L / ${widget.waterIntakeGoal}L'),
      ],
    );
  }

  Widget _buildChartContainer() {
    return SizedBox(
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(show: true),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: Colors.grey),
          ),
          lineBarsData: [
            _buildLineChartBarData(todoProgress, Colors.red, Colors.pink),
            _buildLineChartBarData(waterIntakeProgress, Colors.blue, Colors.lightBlue),
            _buildLineChartBarData(mealProgress, Colors.green, Colors.lightGreen),
          ],
        ),
      ),
    );
  }

  LineChartBarData _buildLineChartBarData(double progress, Color startColor, Color endColor) {
    return LineChartBarData(
      spots: [FlSpot(0, progress / 100 * 5), FlSpot(1, 5.0)], // Adjusted scaling
      isCurved: true,
      barWidth: 4,
      belowBarData: BarAreaData(show: true, color: startColor.withOpacity(0.3)),
      gradient: LinearGradient(colors: [startColor, endColor]),
      dotData: FlDotData(show: false),
    );
  }

}
