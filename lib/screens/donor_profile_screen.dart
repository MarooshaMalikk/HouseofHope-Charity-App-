import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class DonorProfileScreen extends StatefulWidget {
  const DonorProfileScreen({super.key});

  @override
  State<DonorProfileScreen> createState() => _DonorProfileScreenState();
}

class _DonorProfileScreenState extends State<DonorProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("donors");

  bool _isLoading = true;
  String? _editingKey;

  @override
  void initState() {
    super.initState();
    _loadDonorProfile();
  }

  Future<void> _loadDonorProfile() async {
    final user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("User not logged in")),
      );
      return;
    }

    try {
      final snapshot = await _dbRef.get();

      for (var donor in snapshot.children) {
        final data = Map<String, dynamic>.from(donor.value as Map);

        if (data['email'] == user.email) {
          _editingKey = donor.key;
          _nameController.text = data['username'] ?? '';
          _emailController.text = data['email'] ?? '';
          _phoneController.text = data['phone'] ?? '';
          break;
        }
      }

      if (_editingKey == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Your profile could not be found.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error loading profile: ${e.toString()}")),
      );
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _updateProfile() async {
    final name = _nameController.text.trim();
    final phone = _phoneController.text.trim();

    if (name.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Name and phone number cannot be empty.")),
      );
      return;
    }

    if (_editingKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed: profile not loaded.")),
      );
      return;
    }

    try {
      await _dbRef.child(_editingKey!).update({
        "username": name,
        "phone": phone,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated successfully!")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Update failed: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("Donor Profile", style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF5C258D), Color(0xFF4389A2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Icon(Icons.person, size: 50, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 5,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildTextField(_nameController, "Full Name", Icons.person),
                          const SizedBox(height: 12),
                          _buildTextField(_emailController, "Email", Icons.email, enabled: false),
                          const SizedBox(height: 12),
                          _buildTextField(_phoneController, "Phone Number", Icons.phone),
                          const SizedBox(height: 20),
                          ElevatedButton(
                            onPressed: _updateProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF5C258D),
                              padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                            ),
                            child: const Text("Save Changes", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool enabled = true}) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }
}
