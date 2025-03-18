import 'package:flutter/material.dart';
import 'package:mylota/screens/main_screen.dart';
import 'home_page.dart'; // Import HomePage

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  String? selectedPlan;

  final List<String> subscriptionPlans = [
    'Basic Plan - £9.99/month',
    'Premium Plan - £19.99/month',
    'Pro Plan - £29.99/month'
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color:  Colors.white),
      ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66C3A7), Color(0xFF2A7F67)], // Gradient
            ),
          ),
        ),),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE0F2F1), Color(0xFFB2DFDB)], // Gradient colors
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to Mylota Fitness',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87, // Ensure text is visible
                ),
              ),
              const SizedBox(height: 20),

              // Email Input
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8), // Slight transparency
                ),
              ),
              const SizedBox(height: 15),

              // Password Input
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),

              // Subscription Plan Dropdown
              DropdownButtonFormField<String>(
                value: selectedPlan,
                decoration: InputDecoration(
                  labelText: 'Select a Subscription Plan',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                ),
                items: subscriptionPlans.map((plan) {
                  return DropdownMenuItem(value: plan, child: Text(plan));
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedPlan = value;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Login Button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (emailController.text == "user@example.com" &&
                        passwordController.text == "password123" &&
                        selectedPlan != null) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MainScreen(),
                        ),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(selectedPlan == null
                              ? 'Please select a subscription plan'
                              : 'Invalid email or password'),
                        ),
                      );
                    }
                  },
                  child: const Text('Login'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
