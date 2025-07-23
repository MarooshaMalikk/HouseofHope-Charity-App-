import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class AdminApprovalScreen extends StatefulWidget {
  const AdminApprovalScreen({super.key});

  @override
  State<AdminApprovalScreen> createState() => _AdminApprovalScreenState();
}

class _AdminApprovalScreenState extends State<AdminApprovalScreen> {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref().child("needy_students");

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Approve Scholarship", style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: _dbRef.orderByChild("status").equalTo("pending").onValue,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.snapshot.value == null) {
            return const Center(child: Text("No pending applications."));
          }

          final Map data = snapshot.data!.snapshot.value as Map;
          final students = data.entries.toList();

          return ListView.builder(
            itemCount: students.length,
            itemBuilder: (context, index) {
              final key = students[index].key;
              final student = Map<String, dynamic>.from(students[index].value);

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("👤 ${student['name']}", style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      Text("📧 Email: ${student['email']}"),
                      Text("🏫 University: ${student['university']}"),
                      Text("🎓 Program: ${student['program']}"),
                      Text("📊 CGPA: ${student['cgpa']}"),

                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          ElevatedButton(
                            onPressed: () => _updateStatus(key, "approved"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Approve"),
                          ),
                          const SizedBox(width: 10),
                          ElevatedButton(
                            onPressed: () => _updateStatus(key, "rejected"),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                            child: const Text("Reject"),
                          ),
                        ],
                      ),
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

  Future<void> _updateStatus(String key, String newStatus) async {
    await _dbRef.child(key).update({
      "status": newStatus,
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Student has been $newStatus.")),
    );
  }
}
