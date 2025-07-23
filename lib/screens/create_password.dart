import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'donor_login.dart';

class CreatePasswordScreen extends StatefulWidget {
  final User user;

  const CreatePasswordScreen({super.key, required this.user});

  @override
  State<CreatePasswordScreen> createState() => _CreatePasswordScreenState();
}

class _CreatePasswordScreenState extends State<CreatePasswordScreen> {
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  bool _obscurePassword = true;

  Future<void> _setPassword() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final email = widget.user.email;
      final password = _passwordController.text.trim();

      if (email == null) {
        throw FirebaseAuthException(
          code: 'missing-email',
          message: 'User email not available.',
        );
      }

      final cred = EmailAuthProvider.credential(
        email: email,
        password: password,
      );

      await widget.user.linkWithCredential(cred);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password set successfully!")),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const DonorLoginScreen()),
            (route) => false,
      );
    } on FirebaseAuthException catch (e) {
      String message = "Failed to set password.";
      if (e.code == 'provider-already-linked') {
        message = "Email already linked. Try logging in.";
      } else if (e.code == 'email-already-in-use') {
        message = "This email is already used with another account.";
      } else if (e.code == 'requires-recent-login') {
        message = "Please re-login to change password.";
      } else if (e.code == 'missing-email') {
        message = "Unable to retrieve user email.";
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: Colors.red),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Unexpected error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Create Password"),
        backgroundColor: Colors.purple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              const Text(
                "Set a password for your account.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),

              // Password Field
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: "New Password",
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.length < 8) {
                    return "Password must be at least 8 characters";
                  }
                  if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return "Must include a special character";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _isSaving
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _setPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                ),
                child: const Text(
                  "Save Password",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
