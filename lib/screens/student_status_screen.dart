import 'package:flutter/material.dart';

class StudentStatusScreen extends StatelessWidget {
  final String name;
  final String status;
  final String email;
  final String studentKey;
  final bool scholarshipSent;

  const StudentStatusScreen({
    super.key,
    required this.name,
    required this.status,
    required this.email,
    required this.studentKey,
    required this.scholarshipSent,
  });

  @override
  Widget build(BuildContext context) {
    Color statusColor;
    if (status.toLowerCase() == "approved") {
      statusColor = Colors.green;
    } else if (status.toLowerCase() == "rejected") {
      statusColor = Colors.red;
    } else {
      statusColor = Colors.orange;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: AppBar(
        title: const Text("Student Status"),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: 6,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.account_circle_rounded, size: 90, color: Colors.deepPurple),
                const SizedBox(height: 20),
                Text(
                  "Welcome, $name!",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text("Email: $email", style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 20),

                if (status.toLowerCase() == "approved" && scholarshipSent)
                  Column(
                    children: const [
                      Text("🎉 Congratulations!",
                          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                      SizedBox(height: 8),
                      Text("Your scholarship has been sent.\nPlease check your JazzCash account.",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black87)),
                      SizedBox(height: 20),
                    ],
                  )
                else
                  Column(
                    children: [
                      const Text("Your Application Status:", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 10),
                      Chip(
                        label: Text(status.toUpperCase()),
                        backgroundColor: statusColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
