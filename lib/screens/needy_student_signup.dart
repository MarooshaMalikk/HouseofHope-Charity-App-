import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:path/path.dart' as path;
import 'needy_student_login_screen.dart';

class NeedyStudentSignupScreen extends StatefulWidget {
  const NeedyStudentSignupScreen({super.key});

  @override
  State<NeedyStudentSignupScreen> createState() => _NeedyStudentSignupScreenState();
}

class _NeedyStudentSignupScreenState extends State<NeedyStudentSignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _cnicController = TextEditingController();
  final TextEditingController _programController = TextEditingController();
  final TextEditingController _universityController = TextEditingController();
  final TextEditingController _cgpaController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  XFile? _cnicImage, _resultCard, _utilityBills, _fatherPaySlip, _previousTranscript, _fatherCnic, _qrCode;

  bool _isEligible = true;
  bool _isSubmitting = false;
  bool _obscurePassword = true;

  final allowedExtensions = ['jpg', 'jpeg', 'pdf', 'doc', 'docx'];
  final maxFileSizeMB = 5;

  bool _isValidFile(XFile file) {
    final extension = path.extension(file.path).toLowerCase().replaceFirst('.', '');
    final sizeInMB = File(file.path).lengthSync() / (1024 * 1024);
    return allowedExtensions.contains(extension) && sizeInMB <= maxFileSizeMB;
  }

  Future<void> _pickDocument(Function(XFile?) setFile) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && _isValidFile(pickedFile)) {
      setState(() => setFile(pickedFile));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Only JPG, PDF, Word docs allowed (max 5MB)."), backgroundColor: Colors.red),
      );
    }
  }

  void _checkCgpaEligibility(String value) {
    double? cgpa = double.tryParse(value);
    setState(() {
      _isEligible = (cgpa != null && cgpa >= 2.7);
    });
  }

  Future<String> _uploadToCloudinary(XFile file) async {
    final extension = path.extension(file.path).toLowerCase().replaceFirst('.', '');
    final isRaw = ['pdf', 'doc', 'docx'].contains(extension);
    final url = Uri.parse("https://api.cloudinary.com/v1_1/dqkc2ncax/${isRaw ? "raw" : "image"}/upload");
    final uploadPreset = "ml_default";

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = uploadPreset
      ..files.add(await http.MultipartFile.fromPath('file', file.path));

    final response = await request.send();
    final resStr = await response.stream.bytesToString();
    final resJson = jsonDecode(resStr);

    if (response.statusCode == 200) {
      return resJson['secure_url'];
    } else {
      throw Exception("Upload Failed: ${resJson['error']['message']}");
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate() ||
        _cnicImage == null || _resultCard == null || _utilityBills == null ||
        _fatherPaySlip == null || _previousTranscript == null || _fatherCnic == null || _qrCode == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields and upload all required documents."), backgroundColor: Colors.red),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = FirebaseAuth.instance;
      await auth.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      final uploads = await Future.wait([
        _uploadToCloudinary(_cnicImage!),
        _uploadToCloudinary(_resultCard!),
        _uploadToCloudinary(_utilityBills!),
        _uploadToCloudinary(_fatherPaySlip!),
        _uploadToCloudinary(_previousTranscript!),
        _uploadToCloudinary(_fatherCnic!),
        _uploadToCloudinary(_qrCode!), // QR code
      ]);

      final dbRef = FirebaseDatabase.instance.ref().child('needy_students').push();
      await dbRef.set({
        'name': _nameController.text.trim(),
        'fatherName': _fatherNameController.text.trim(),
        'email': _emailController.text.trim().toLowerCase(),
        'phone': _phoneController.text.trim(),
        'city': _cityController.text.trim(),
        'password': _passwordController.text.trim(),
        'cnic': _cnicController.text.trim(),
        'program': _programController.text.trim(),
        'university': _universityController.text.trim(),
        'cgpa': _cgpaController.text.trim(),
        'status': 'pending',
        'documents': {
          'cnicImage': uploads[0],
          'resultCard': uploads[1],
          'utilityBills': uploads[2],
          'fatherPaySlip': uploads[3],
          'previousTranscript': uploads[4],
          'fatherCnic': uploads[5],
          'qrCode': uploads[6], // Save QR
        },
        'submittedAt': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const NeedyStudentLoginScreen()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Signup Failed: ${e.toString()}"), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Needy Student Signup", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Full Name", _nameController),
              _buildTextField("Father Name", _fatherNameController),
              _buildTextField("Email", _emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField("Password", _passwordController, obscureText: _obscurePassword, suffixIcon: IconButton(
                icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
              )),
              _buildTextField("Phone Number", _phoneController, keyboardType: TextInputType.phone),
              _buildTextField("City", _cityController),
              _buildTextField("CNIC (13 digits)", _cnicController, keyboardType: TextInputType.number, maxLength: 13),
              _buildTextField("Degree Program", _programController),
              _buildTextField("University/College Name", _universityController),
              _buildTextField("CGPA", _cgpaController, keyboardType: TextInputType.number, onChanged: _checkCgpaEligibility),

              const SizedBox(height: 20),
              const Text("Upload Required Documents (JPG / PDF / Word)", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 5),

              _buildUploadField("CNIC Picture", _cnicImage, (file) => _cnicImage = file),
              _buildUploadField("Result Card", _resultCard, (file) => _resultCard = file),
              _buildUploadField("Utility Bills", _utilityBills, (file) => _utilityBills = file),
              _buildUploadField("Father's Pay Slip", _fatherPaySlip, (file) => _fatherPaySlip = file),
              _buildUploadField("Transcript", _previousTranscript, (file) => _previousTranscript = file),
              _buildUploadField("Father's CNIC", _fatherCnic, (file) => _fatherCnic = file),
              _buildUploadField("JazzCash QR Code", _qrCode, (file) => _qrCode = file), // 👈 New QR code field

              const SizedBox(height: 10),
              const Text("📱 Upload your JazzCash or bank QR code so the admin can scan and send scholarship.", style: TextStyle(fontSize: 14, color: Colors.grey)),

              const SizedBox(height: 20),
              _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.deepPurple)
                  : ElevatedButton(
                onPressed: _isEligible ? _submitForm : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text("Submit Application", style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {TextInputType keyboardType = TextInputType.text,
        int? maxLength,
        bool obscureText = false,
        Widget? suffixIcon,
        Function(String)? onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLength: maxLength,
        decoration: InputDecoration(
          labelText: label,
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          suffixIcon: suffixIcon,
        ),
        validator: (value) => value == null || value.isEmpty ? "Required" : null,
        onChanged: onChanged,
      ),
    );
  }

  Widget _buildUploadField(String title, XFile? file, Function(XFile?) setFile) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 5),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (file != null)
              IconButton(
                icon: const Icon(Icons.cancel, color: Colors.red),
                onPressed: () => setState(() => setFile(null)),
              ),
            IconButton(
              icon: const Icon(Icons.upload_file, color: Colors.purple),
              onPressed: () => _pickDocument(setFile),
              tooltip: file != null ? "Change File" : "Upload File",
            ),
          ],
        ),
      ),
    );
  }
}
