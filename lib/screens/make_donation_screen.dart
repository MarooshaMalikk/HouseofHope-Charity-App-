
import 'package:flutter/material.dart';
import 'payment_screen.dart'; // Ensure this import is correct

class MakeDonationScreen extends StatelessWidget {
  const MakeDonationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Make a Donation", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purple,
        elevation: 0,
      ),
      body: Stack(
        children: [
          // Background Image
          Positioned.fill(
            child: Opacity(
              opacity: 0.9, // Subtle background for readability
              child: Image.asset(
                "lib/assests/images/donation_bg2.jpg", // Ensure the correct file path!
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Foreground Content
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // **Donation Card**
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        const Text(
                          "Support a Cause 💖",
                          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.purple),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          "Your small donation can make a huge impact. Let's help those in need!",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16, color: Colors.black54),
                        ),
                        const SizedBox(height: 20),

                        // **Donate Now Button**
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PaymentScreen(), // no amount passed now
                              ),
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purple,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          child: const Text(
                            "Donate Now",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
