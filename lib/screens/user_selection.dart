import 'package:flutter/material.dart';
import './donor_signup.dart';
import '../admin/admin_login_screen.dart';
import './needy_selection_screen.dart';

class SelectionScreen extends StatelessWidget {
  const SelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF6A82FB), // Blueish Purple
              Color(0xFFFC5C7D), // Pinkish Red
            ],
          ),
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  "Welcome to House of Hope",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                const Text(
                  "Choose your role to continue",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),

                // Donor Button
                _buildButton(
                  text: "I'm a Donor",
                  icon: Icons.volunteer_activism,
                  color: Colors.white,
                  textColor: Colors.black87,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const DonorSignupScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Needy Student Button
                _buildButton(
                  text: "I'm a Needy Student",
                  icon: Icons.school_rounded,
                  color: Colors.purple.shade900,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const NeedySelectionScreen()),
                    );
                  },
                ),
                const SizedBox(height: 20),

                // Admin Login Button ✅
                _buildButton(
                  text: "Admin Login",
                  icon: Icons.admin_panel_settings_rounded,
                  color: Colors.deepPurple.shade700,
                  textColor: Colors.white,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const AdminLoginScreen()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildButton({
    required String text,
    required IconData icon,
    required Color color,
    required Color textColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: textColor),
      label: Text(
        text,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: textColor),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        minimumSize: const Size(double.infinity, 60),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
      ),
    );
  }
}
