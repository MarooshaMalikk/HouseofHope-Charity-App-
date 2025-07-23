import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _notificationsEnabled = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            "Preferences",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),

          // 🔔 Notifications toggle
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: SwitchListTile(
              value: _notificationsEnabled,
              title: const Text("Enable Notifications"),
              secondary: const Icon(Icons.notifications, color: Colors.purple),
              onChanged: (value) {
                setState(() => _notificationsEnabled = value);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(value ? "Notifications Enabled" : "Notifications Disabled"),
                  duration: const Duration(seconds: 2),
                ));
              },
            ),
          ),

          const SizedBox(height: 20),
          const Divider(),
          const SizedBox(height: 10),

          const Text(
            "Account",
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black54),
          ),
          const SizedBox(height: 10),

          // 🚪 Logout
          Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            elevation: 2,
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text("Logout", style: TextStyle(color: Colors.red)),
              onTap: _confirmLogout,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Confirm Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context); // Close the dialog
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.popUntil(context, (route) => route.isFirst); // Return to splash/login
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }
}
