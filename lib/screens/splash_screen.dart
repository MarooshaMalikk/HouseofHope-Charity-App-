import 'package:flutter/material.dart';
import 'dart:async';
import 'user_selection.dart';
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 10), () {
      if (mounted) { // Prevent navigation error
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SelectionScreen()), // Make sure SelectionScreen is Stateless
        );
      }
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset("lib/assests/images/Charity_logo.png", width: 400),
          ],
        ),
      ),
    );
  }
}
