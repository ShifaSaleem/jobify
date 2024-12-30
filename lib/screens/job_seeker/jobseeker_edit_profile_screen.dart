import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class JobseekerEditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userProfile;

  const JobseekerEditProfileScreen({super.key, required this.userProfile});

  @override
  _JobseekerEditProfileScreenState createState() => _JobseekerEditProfileScreenState();
}

class _JobseekerEditProfileScreenState extends State<JobseekerEditProfileScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController skillsController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController(text: widget.userProfile['name']);
    emailController = TextEditingController(text: widget.userProfile['email']);
    skillsController = TextEditingController(text: widget.userProfile['skills']?.join(', ') ?? '');
  }

  Future<void> saveProfile() async {
    final updatedProfile = {
      'name': nameController.text,
      'email': emailController.text,
      'skills': skillsController.text.split(',').map((e) => e.trim()).toList(),
    };

    await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).update(updatedProfile);
    Navigator.pop(context); // Go back to profile screen after saving
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: saveProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: skillsController,
                decoration: const InputDecoration(labelText: 'Skills (comma separated)'),
              ),
              // Add other fields here like experience, education, etc.
            ],
          ),
        ),
      ),
    );
  }
}
