import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../../services/firebase_service.dart';
import 'jobseeker_edit_profile_screen.dart'; // Assuming FirebaseService is where your methods are defined

class JobSeekerProfileScreen extends StatefulWidget {
  const JobSeekerProfileScreen({super.key});

  @override
  _JobSeekerProfileScreenState createState() => _JobSeekerProfileScreenState();
}

class _JobSeekerProfileScreenState extends State<JobSeekerProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late String userId;
  late Map<String, dynamic> userProfile;

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser!.uid;
    fetchUserProfileData();
  }

  Future<void> fetchUserProfileData() async {
    final profileData = await _firebaseService.fetchUserProfile(userId);
    setState(() {
      userProfile = profileData;
    });
  }

  Future<void> pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      // Upload to Firebase Storage
      final file = File(pickedFile.path);
      try {
        final uploadTask = FirebaseStorage.instance
            .ref('profile_pictures/${userId}.jpg')
            .putFile(file);
        await uploadTask;
        final imageUrl = await uploadTask.snapshot.ref.getDownloadURL();
        await FirebaseFirestore.instance.collection('users').doc(userId).update({
          'profile_picture': imageUrl,
        });
        fetchUserProfileData();  // Update UI with new image
      } catch (e) {
        print("Error uploading profile picture: $e");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to edit profile screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobseekerEditProfileScreen(userProfile: userProfile),
                ),
              );
            },
          ),
        ],
      ),
      body: userProfile.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: userProfile['profile_picture'] != null
                      ? NetworkImage(userProfile['profile_picture'])
                      : const NetworkImage('https://www.example.com/default-profile-pic.png'), // Default placeholder
                  child: userProfile['profile_picture'] == null
                      ? const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                  )
                      : null,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Name: ${userProfile['name'] ?? 'Not Available'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Email: ${userProfile['email'] ?? 'Not Available'}',
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Skills: ${userProfile['skills']?.join(', ') ?? 'Not Available'}',
                style: const TextStyle(fontSize: 18),
              ),
              // Add other fields here like experience, education, etc.
            ],
          ),
        ),
      ),
    );
  }
}
