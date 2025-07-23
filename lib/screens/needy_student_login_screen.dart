import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'student_status_screen.dart';
import 'needy_student_signup.dart';

class NeedyStudentLoginScreen extends StatefulWidget {
  const NeedyStudentLoginScreen({super.key});

  @override
  State<NeedyStudentLoginScreen> createState() => _NeedyStudentLoginScreenState();
}

class _NeedyStudentLoginScreenState extends State<NeedyStudentLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    try {
      final auth = FirebaseAuth.instance;
      final userCredential = await auth.signInWithEmailAndPassword(email: email, password: password);

      final dbRef = FirebaseDatabase.instance.ref().child('needy_students');
      final snapshot = await dbRef.get();

      bool found = false;

      if (snapshot.exists) {
        for (final child in snapshot.children) {
          final data = child.value as Map?;
          if (data == null) continue;

          final recordEmail = data['email']?.toString().toLowerCase();
          if (recordEmail == email.toLowerCase()) {
            final name = data['name'] ?? 'Unknown';
            final status = data['status'] ?? 'pending';
            final scholarshipSent = data['scholarshipSent'] ?? false; // ✅ New field

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => StudentStatusScreen(
                  name: name,
                  email: email,
                  status: status,
                  studentKey: child.key ?? '',
                  scholarshipSent: scholarshipSent, // ✅ Pass here
                ),
              ),
            );
            found = true;
            break;
          }
        }
      }

      if (!found) {
        _showMessage("No matching application found.");
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        _showMessage("Wrong password.");
      } else {
        _showMessage("Login error: ${e.message}");
      }
    } catch (e) {
      _showMessage("Something went wrong. Please try again.");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF6A1B9A),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 4)),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    "Needy Student Login",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 24),

                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: "Email",
                      border: OutlineInputBorder(),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Enter your email" : null,
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      labelText: "Password",
                      border: const OutlineInputBorder(),
                      suffixIcon: IconButton(
                        icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      ),
                    ),
                    validator: (val) => val == null || val.isEmpty ? "Enter your password" : null,
                  ),

                  const SizedBox(height: 10),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () async {
                        if (_emailController.text.trim().isNotEmpty) {
                          await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailController.text.trim());
                          _showMessage("Password reset link sent.");
                        } else {
                          _showMessage("Enter your email first.");
                        }
                      },
                      child: const Text("Forgot Password?", style: TextStyle(color: Colors.purple)),
                    ),
                  ),

                  const SizedBox(height: 20),
                  _isLoading
                      ? const CircularProgressIndicator(color: Colors.purple)
                      : ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Login", style: TextStyle(fontSize: 18, color: Colors.white)),
                  ),

                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const NeedyStudentSignupScreen()));
                    },
                    child: const Text("Submit a New Application."),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
