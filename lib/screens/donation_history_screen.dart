import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DonationHistoryScreen extends StatefulWidget {
  const DonationHistoryScreen({super.key});

  @override
  State<DonationHistoryScreen> createState() => _DonationHistoryScreenState();
}

class _DonationHistoryScreenState extends State<DonationHistoryScreen> {
  final List<Map<String, dynamic>> _donations = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _fetchDonationHistory();
  }

  Future<void> _fetchDonationHistory() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final ref = FirebaseDatabase.instance.ref().child('donations');
    final snapshot = await ref.once();

    _donations.clear();
    final data = snapshot.snapshot.value as Map<dynamic, dynamic>?;

    if (data != null) {
      data.forEach((key, value) {
        if (value['email'] == user.email) {
          _donations.add({
            "amount": value["amount"],
            "method": value["method"],
            "date": value["timestamp"],
          });
        }
      });
    }

    setState(() {
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation History", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Opacity(
              opacity: 0.9,
              child: Image.asset(
                "lib/assests/images/donation_bg.jpg",
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  "Your Donations",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 10),

                Expanded(
                  child: _loading
                      ? const Center(child: CircularProgressIndicator(color: Colors.purple))
                      : _donations.isEmpty
                      ? const Center(
                      child: Text("No donations found.",
                          style: TextStyle(color: Colors.white, fontSize: 16)))
                      : ListView.builder(
                    itemCount: _donations.length,
                    itemBuilder: (context, index) {
                      final donation = _donations[index];
                      return DonationCard(
                        amount: "Rs. ${donation['amount']}",
                        organization: donation['method'],
                        date: _formatDate(donation['date']),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final date = DateTime.parse(isoDate);
      return "${date.day} ${_monthName(date.month)} ${date.year}";
    } catch (_) {
      return isoDate;
    }
  }

  String _monthName(int month) {
    const months = [
      "Jan", "Feb", "Mar", "Apr", "May", "Jun",
      "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"
    ];
    return months[month - 1];
  }
}

class DonationCard extends StatelessWidget {
  final String amount;
  final String organization;
  final String date;

  const DonationCard({
    super.key,
    required this.amount,
    required this.organization,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        leading: const Icon(Icons.check_circle, color: Colors.green, size: 35),
        title: Text(
          "$amount via $organization",
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        subtitle: Text("Date: $date", style: const TextStyle(color: Colors.grey)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.teal),
      ),
    );
  }
}
