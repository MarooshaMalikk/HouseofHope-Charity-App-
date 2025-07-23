import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:url_launcher/url_launcher.dart';

class SendScholarshipScreen extends StatefulWidget {
  const SendScholarshipScreen({super.key});

  @override
  State<SendScholarshipScreen> createState() => _SendScholarshipScreenState();
}

class _SendScholarshipScreenState extends State<SendScholarshipScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("needy_students");
  bool _isSending = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Send Scholarship", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.purpleAccent,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _dbRef.orderByChild("status").equalTo("approved").onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.purple));
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No approved students available."));
          }

          final Map data = snapshot.data!.snapshot.value as Map;
          final students = data.entries
              .where((entry) => !(entry.value['scholarshipSent'] ?? false))
              .toList();

          if (students.isEmpty) {
            return const Center(child: Text("All approved students have received scholarships."));
          }

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final key = students[index].key;
              final student = Map<String, dynamic>.from(students[index].value);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 ${student['name']}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text("🏫 University: ${student['university']}"),
                      Text("🎓 Program: ${student['program']}"),
                      Text("📊 CGPA: ${student['cgpa']}"),
                      Text("💳 Account #: ${student['accountNumber'] ?? 'Not provided'}"),

                      if (student.containsKey('scholarshipSentAt'))
                        Text("📬 Sent on: ${student['scholarshipSentAt'].toString().split('T').first}"),

                      const SizedBox(height: 10),
                      const Text("📎 Documents:", style: TextStyle(fontWeight: FontWeight.bold)),
                      if (student.containsKey('documents'))
                        ...(student['documents'] as Map).entries.map((doc) => InkWell(
                          onTap: () => _openLink(doc.value),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text("• ${doc.key}", style: const TextStyle(color: Colors.blue)),
                          ),
                        ))
                      else
                        const Text("No documents uploaded", style: TextStyle(color: Colors.red)),

                      if (student['documents'] != null && student['documents'].containsKey('qrCode')) ...[
                        const SizedBox(height: 10),
                        const Text("📱 JazzCash QR Code:", style: TextStyle(fontWeight: FontWeight.bold)),
                        InkWell(
                          onTap: () => _openLink(student['documents']['qrCode']),
                          child: Image.network(
                            student['documents']['qrCode'],
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                      ],

                      const SizedBox(height: 12),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton.icon(
                          onPressed: _isSending ? null : () => _confirmScholarshipSend(context, key, student),
                          icon: const Icon(Icons.send),
                          label: const Text("Send Scholarship"),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _openLink(String url) async {
    final uri = Uri.tryParse(url);
    if (uri != null && await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Could not open document link"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _confirmScholarshipSend(BuildContext context, String key, Map<String, dynamic> data) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Confirm Send"),
        content: Text("Send scholarship to ${data['name']}?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Send")),
        ],
      ),
    );

    if (confirm == true) {
      await _sendScholarship(key, data);
    }
  }

  Future<void> _sendScholarship(String studentKey, Map<String, dynamic> studentData) async {
    setState(() => _isSending = true);
    try {
      await _dbRef.child(studentKey).update({
        "scholarshipSent": true,
        "scholarshipSentAt": DateTime.now().toIso8601String(),
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Scholarship marked as sent!"), backgroundColor: Colors.green),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.toString()}"), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }
}
