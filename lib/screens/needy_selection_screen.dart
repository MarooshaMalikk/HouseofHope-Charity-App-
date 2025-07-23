import 'package:flutter/material.dart';
import 'needy_student_signup.dart';
import 'needy_student_login_screen.dart';

class NeedySelectionScreen extends StatelessWidget {
  const NeedySelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F6FF),
      appBar: AppBar(
        title: const Text(
          "Needy Student Portal",
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 4,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Column(
            children: [
              const Icon(Icons.school_rounded, size: 100, color: Colors.deepPurple),
              const SizedBox(height: 20),
              const Text(
                "Welcome to the House of Hope",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.deepPurple),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              const Text(
                "Please select your action below to continue.",
                style: TextStyle(fontSize: 16, color: Colors.black54),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Signup Button
              ElevatedButton.icon(
                icon: const Icon(Icons.assignment, color: Colors.white),
                label: const Text(
                  "Needy Student Signup",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.white),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NeedyStudentSignupScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),

              const SizedBox(height: 20),

              // Login Button
              OutlinedButton.icon(
                icon: const Icon(Icons.login, color: Colors.deepPurple),
                label: const Text(
                  "Login to Check Status",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Colors.deepPurple),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const NeedyStudentLoginScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.deepPurple),
                  minimumSize: const Size(double.infinity, 55),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
