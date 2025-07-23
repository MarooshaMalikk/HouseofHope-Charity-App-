import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController(text: "500");
  bool _isProcessing = false;

  final String jazzCashNumber = "03097990693"; // Your JazzCash number

  String? _selectedDonationFor;
  final List<String> donationOptions = [
    "Needy Student",
    "Needy Person",
    "Medical Case",
    "Education Fund",
    "Other",
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donate via JazzCash", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple.withOpacity(0.85),
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // 🔹 Background Image
          Positioned.fill(
            child: Image.asset(
              "lib/assests/images/payment_bg.jpg",
              fit: BoxFit.cover,
            ),
          ),

          // 🔹 Foreground Content
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(height: 30),

                // QR Image
                Image.asset(
                  "lib/assests/images/qr_flutter.jpg",
                  height: 240,
                  width: 240,
                  fit: BoxFit.contain,
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.85),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 5)],
                  ),
                  child: const Text(
                    "Scan this QR to Donate via JazzCash",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Use JazzCash app to scan & pay",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),

                const SizedBox(height: 30),

                // Dropdown to select donation purpose
                DropdownButtonFormField<String>(
                  value: _selectedDonationFor,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Colors.white,
                    labelText: "Name you want to donate to",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: donationOptions.map((option) {
                    return DropdownMenuItem(value: option, child: Text(option));
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedDonationFor = value;
                    });
                  },
                ),

                const SizedBox(height: 20),
                _buildAmountInput(),

                const SizedBox(height: 20),

                _isProcessing
                    ? const CircularProgressIndicator(color: Colors.deepPurple)
                    : ElevatedButton(
                  onPressed: _processDonation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.purple,
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  child: const Text("I Have Donated", style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return TextField(
      controller: _amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Enter Donation Amount (Max Rs. 50,000)",
        prefixText: "Rs. ",
        prefixStyle: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  Future<void> _processDonation() async {
    final enteredAmount = double.tryParse(_amountController.text.trim()) ?? 0;
    if (_selectedDonationFor == null) {
      _showError("Please select who you want to donate to.");
      return;
    }
    if (enteredAmount <= 0 || enteredAmount > 50000) {
      _showError("Amount must be between Rs. 10 and Rs. 50,000");
      return;
    }

    setState(() {
      _isProcessing = true;
    });

    await Future.delayed(const Duration(seconds: 2)); // Simulating donation delay

    final user = FirebaseAuth.instance.currentUser;
    final donationRef = FirebaseDatabase.instance.ref().child("donations");

    await donationRef.push().set({
      "email": user?.email ?? "Anonymous",
      "method": "JazzCash QR",
      "accountInfo": jazzCashNumber,
      "amount": enteredAmount,
      "donatedTo": _selectedDonationFor,
      "timestamp": DateTime.now().toIso8601String(),
    });

    setState(() {
      _isProcessing = false;
    });

    if (!mounted) return;

    // Navigate to receipt screen
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DonationReceiptScreen(
          amount: enteredAmount,
          donatedTo: _selectedDonationFor!,
        ),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }
}

// 🔹 Donation Receipt Screen
class DonationReceiptScreen extends StatelessWidget {
  final double amount;
  final String donatedTo;

  const DonationReceiptScreen({
    super.key,
    required this.amount,
    required this.donatedTo,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Donation Receipt", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        centerTitle: true,
      ),
      body: Center(
        child: Card(
          margin: const EdgeInsets.all(20),
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle, color: Colors.green, size: 80),
                const SizedBox(height: 20),
                Text("Donation Successful!", style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text("Amount: Rs. $amount", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Text("Donated To: $donatedTo", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                  child: const Text("Back to Home", style: TextStyle(color: Colors.white)),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
