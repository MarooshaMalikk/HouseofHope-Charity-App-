import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'donor_login.dart';
import 'create_password.dart';

class DonorSignupScreen extends StatefulWidget {
  const DonorSignupScreen({super.key});

  @override
  State<DonorSignupScreen> createState() => _DonorSignupScreenState();
}

class _DonorSignupScreenState extends State<DonorSignupScreen> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _selectedCity;
  final _formKey = GlobalKey<FormState>();

  final List<String> _cities = [
    'Bahawalnagar', 'Sargodha', 'Bahawalpur', 'Karachi', 'Lahore', 'Islamabad',
    'Peshawar', 'Quetta', 'Faisalabad', 'Rawalpindi', 'Gujranwala', 'Multan',
    'Jhang', 'Sheikhupura', 'Gujrat', 'Sahiwal', 'Larkana', 'Sukkur', 'Okara',
    'Rahim Yar Khan', 'Dera Ghazi Khan', 'Burewala', 'Hafizabad', 'Abbottabad',
    'Chakwal', 'Chishtian', 'Attock', 'Hasilpur', 'Arif Wala', 'Haroonabad',
    'Kot Addu', 'Mianwale'
  ];

  final dbRef = FirebaseDatabase.instance.ref().child("donors");

  String? _validatePassword(String? value) {
    if (value == null || value.length < 8) return "Password must be at least 8 characters";
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(value)) return "Include at least 1 special character";
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.length != 13 || !value.startsWith("+92")) {
      return "Phone must start with +92 and be 13 characters long";
    }
    return null;
  }

  Future<void> _signupDonor() async {
    try {
      // Step 1: Create Firebase Auth account
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uid = userCredential.user!.uid;

      // Step 2: Save additional user info to Realtime Database
      await dbRef.child(uid).set({
        "username": _usernameController.text.trim(),
        "email": _emailController.text.trim(),
        "phone": _phoneController.text.trim(),
        "city": _selectedCity,
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Signup successful!")),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DonorLoginScreen()),
      );
    } on FirebaseAuthException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Auth Error: ${e.message}")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  Future<void> _googleSignup() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Ensure account picker shows

      final GoogleSignInAccount? gUser = await googleSignIn.signIn();
      if (gUser == null) return;

      final GoogleSignInAuthentication gAuth = await gUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: gAuth.accessToken,
        idToken: gAuth.idToken,
      );

      UserCredential userCred = await FirebaseAuth.instance.signInWithCredential(credential);
      final user = userCred.user!;

      await dbRef.child(user.uid).set({
        "username": user.displayName ?? "Google User",
        "email": user.email ?? "",
        "phone": user.phoneNumber ?? "N/A",
        "city": "Google Signup",
      });

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreatePasswordScreen(user: user)),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Google Sign-In Failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF4A90E2), Color(0xFF8E44AD)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              elevation: 10,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      const Text("Donor Signup", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF4A90E2))),
                      const SizedBox(height: 10),
                      const Text("A Step for helping someone!", style: TextStyle(fontSize: 16, color: Colors.black54)),
                      const SizedBox(height: 20),
                      _buildTextField(_usernameController, "Username", Icons.person),
                      _buildTextField(_emailController, "Email", Icons.email, keyboardType: TextInputType.emailAddress),
                      _buildTextField(_phoneController, "Phone (+92xxxxxxxxxxx)", Icons.phone,
                          keyboardType: TextInputType.phone, validator: _validatePhone),
                      _buildTextField(
                        _passwordController,
                        "Password",
                        Icons.lock,
                        keyboardType: TextInputType.visiblePassword,
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        suffixIcon: IconButton(
                          icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        ),
                      ),
                      DropdownButtonFormField(
                        items: _cities.map((city) => DropdownMenuItem(value: city, child: Text(city))).toList(),
                        onChanged: (value) => setState(() => _selectedCity = value),
                        decoration: InputDecoration(
                          labelText: "City",
                          prefixIcon: const Icon(Icons.location_city),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        validator: (value) => value == null ? "Please select a city" : null,
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            _signupDonor();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        ),
                        child: const Text("Signup", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                      const SizedBox(height: 10),
                      OutlinedButton.icon(
                        onPressed: _googleSignup,
                        icon: const Icon(Icons.login, color: Colors.red),
                        label: const Text("Signup with Google", style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon, {
        TextInputType keyboardType = TextInputType.text,
        bool obscureText = false,
        String? Function(String?)? validator,
        Widget? suffixIcon,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        validator: validator ?? (value) => value!.isEmpty ? "$label is required" : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
