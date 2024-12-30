import 'package:flutter/material.dart';
import 'package:jobify/theme/app_theme.dart';
import '../../services/firebase_service.dart';
import 'edit_employer_profile_screen.dart';

class EmployerProfileScreen extends StatefulWidget {
  const EmployerProfileScreen({super.key});

  @override
  _EmployerProfileScreenState createState() => _EmployerProfileScreenState();
}

class _EmployerProfileScreenState extends State<EmployerProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<Map<String, dynamic>> employerProfile;

  @override
  void initState() {
    super.initState();
    employerProfile = _firebaseService.fetchEmployerProfile();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Employer Profile'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: employerProfile,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No profile data found.'));
          }

          var profileData = snapshot.data!;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Employer Profile Picture
                  CircleAvatar(
                    backgroundImage: NetworkImage(profileData['profileImage']),
                    radius: 60,
                  ),
                  SizedBox(height: 16),
                  Text(
                    profileData['name'],
                    style: headerText14(),
                  ),
                  Text(profileData['companyName']),
                  SizedBox(height: 16),

                  // Profile Details
                  Text(
                    'Email: ${profileData['email']}',
                    style: bodyText14(),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Phone: ${profileData['phoneNumber']}',
                    style: bodyText14(),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Company Description: ${profileData['companyDescription']}',
                    style: bodyText14(),
                  ),
                  SizedBox(height: 16),

                  // Button to Edit Profile
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        // Navigate to Edit Profile screen
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditEmployerProfileScreen(profileData: profileData),
                          ),
                        );
                      },
                      child: const Text('Edit Profile'),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
