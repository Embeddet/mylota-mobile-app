import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MealPlanner extends StatefulWidget {
  @override
  _MealPlannerState createState() => _MealPlannerState();
}

class _MealPlannerState extends State<MealPlanner> {
  final TextEditingController _mealController = TextEditingController();

  // Meal categories
  Map<String, List<String>> meals = {
    'Breakfast': [],
    'Lunch': [],
    'Dinner': [],
  };

  // List of common vegetable colors
  final List<String> vegetableColors = [
    'Green (Spinach, Broccoli)',
    'Red (Tomato, Bell Pepper)',
    'Yellow (Carrots, Corn)',
    'Purple (Eggplant, Beetroot)',
    'Orange (Pumpkin, Sweet Potato)',
    'White (Cauliflower, Onion)',
  ];

  // Selected category and vegetables
  String _selectedCategory = 'Breakfast';
  String? _selectedVegetable1;
  String? _selectedVegetable2;

  @override
  void initState() {
    super.initState();
    _loadMeals();
  }

  // Load meals from SharedPreferences
  Future<void> _loadMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      meals = prefs.getStringList('meals') != null
          ? Map<String, List<String>>.from(
        (prefs.getString('meals') as Map).map(
              (key, value) => MapEntry(key, List<String>.from(value)),
        ),
      )
          : meals;
    });
  }

  // Save meals to SharedPreferences
  Future<void> _saveMeals() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('meals', meals.toString());
  }

  // Add a new meal with vegetable validation
  void _addMeal() {
    if (_mealController.text.isNotEmpty &&
        _selectedVegetable1 != null &&
        _selectedVegetable2 != null &&
        _selectedVegetable1 != _selectedVegetable2) {
      setState(() {
        meals[_selectedCategory]?.add(
            '${_mealController.text} (with $_selectedVegetable1 and $_selectedVegetable2)');
        _mealController.clear();
        _selectedVegetable1 = null;
        _selectedVegetable2 = null;
        _saveMeals();
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Meal added successfully!'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please include at least 2 different colors of vegetables.'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  // Remove a meal from the list
  void _removeMeal(String category, int index) {
    setState(() {
      meals[category]?.removeAt(index);
      _saveMeals();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      margin: EdgeInsets.all(16.0),
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Icon(Icons.restaurant_menu, color: Colors.green, size: 28),
                SizedBox(width: 10),
                Text(
                  'Meal Planner',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Category dropdown
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Select Meal Category',
              ),
              items: meals.keys.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value!;
                });
              },
            ),
            SizedBox(height: 10),

            // Meal input field
            TextField(
              controller: _mealController,
              decoration: InputDecoration(
                labelText: 'Enter your meal (e.g., Rice, Chicken)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),

            // Vegetable color dropdown 1
            DropdownButtonFormField<String>(
              value: _selectedVegetable1,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Choose first vegetable color',
              ),
              items: vegetableColors.map((color) {
                return DropdownMenuItem<String>(
                  value: color,
                  child: Text(color, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVegetable1 = value;
                });
              },
            ),
            SizedBox(height: 10),

            // Vegetable color dropdown 2
            DropdownButtonFormField<String>(
              value: _selectedVegetable2,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Choose second vegetable color',
              ),
              items: vegetableColors.map((color) {
                return DropdownMenuItem<String>(
                  value: color,
                  child: Text(color, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedVegetable2 = value;
                });
              },
            ),
            SizedBox(height: 20),

            // Add meal button
            Center(
              child: ElevatedButton(
                onPressed: _addMeal,
                child: Text('Add Meal'),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    shadowColor: Colors.grey
                ),
              ),
            ),
            SizedBox(height: 20),

            // Meal list with delete option
            meals.isEmpty
                ? Center(
              child: Text(
                'No meals planned yet. Add one!',
                style: TextStyle(color: Colors.grey),
              ),
            )
                : ListView(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              children: meals.entries.map((entry) {
                String category = entry.key;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: NeverScrollableScrollPhysics(),
                      itemCount: entry.value.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: EdgeInsets.symmetric(vertical: 5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: ListTile(
                            title: Text(entry.value[index]),
                            trailing: IconButton(
                              icon: Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  _removeMeal(category, index),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
