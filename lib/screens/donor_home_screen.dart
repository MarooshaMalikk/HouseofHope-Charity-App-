import 'package:flutter/material.dart';
import 'donor_profile_screen.dart';
import 'make_donation_screen.dart';
import 'donation_history_screen.dart';
import 'settings_screen.dart';

class DonorHomeScreen extends StatelessWidget {
  const DonorHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, // Extends background image behind app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, // Transparent for a sleek look
        elevation: 0,
        title: const Text(
          "Donor Home",
          style: TextStyle(fontWeight: FontWeight.bold , color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsScreen()));
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Image.asset(
              "lib/assests/images/donation_background.jpg", // Make sure you have this image in assets folder
              fit: BoxFit.cover,
            ),
          ),


          // Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Welcome Message
                const Text(
                  "Welcome, Donor!",
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Start your day with some donation.",
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),

                // Options (Profile, Donation, History)
                Expanded(
                  child: ListView(
                    children: [
                      _buildOptionCard(
                        context,
                        title: "View & Edit Profile",
                        subtitle: "Update your details",
                        icon: Icons.person,
                        color: Colors.blue,
                        screen: const DonorProfileScreen(),
                      ),
                      _buildOptionCard(
                        context,
                        title: "Make a Donation",
                        subtitle: "Donate to a charity",
                        icon: Icons.volunteer_activism,
                        color: Colors.green,
                        screen: const MakeDonationScreen(),
                      ),
                      _buildOptionCard(
                        context,
                        title: "Donation History",
                        subtitle: "See your past donations",
                        icon: Icons.history,
                        color: Colors.orange,
                        screen: const DonationHistoryScreen(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionCard(BuildContext context, {required String title, required String subtitle, required IconData icon, required Color color, required Widget screen}) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        leading: Icon(icon, size: 40, color: color),
        title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 14, color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.grey),
        onTap: () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
        },
      ),
    );
  }
}
