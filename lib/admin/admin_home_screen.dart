import 'package:flutter/material.dart';
import 'admin_approval_screen.dart'; // Import your existing screen
import 'send_scholarship_screen.dart'; // Create this if it's separate

class AdminHomeScreen extends StatelessWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Admin Panel',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AdminApprovalScreen()),
                );
              },
              icon: const Icon(Icons.check_circle_outline, color: Colors.white),
              label: const Text(
                'Approve Scholarship',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.purple,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
            const SizedBox(height: 30),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SendScholarshipScreen()),
                );
              },
              icon: const Icon(Icons.send, color: Colors.white),
              label: const Text(
                'Send Scholarship to Needy Student',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 60),
                backgroundColor: Colors.purpleAccent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
