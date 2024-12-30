import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../screens/employer/employer_home_screen.dart';
import '../screens/job_seeker/jobseeker_home_screen.dart';
import '../screens/login_screen.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Widget handleAuthState() {
    return StreamBuilder(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          return FutureBuilder(
            future: _getUserRole(_auth.currentUser!.uid),
            builder: (context, AsyncSnapshot<String> roleSnapshot) {
              if (roleSnapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }
              if (roleSnapshot.hasData) {
                if (roleSnapshot.data == 'Job Seeker') {
                  return JobseekerHomeScreen();
                } else if (roleSnapshot.data == 'Employer') {
                  return EmployerHomeScreen();
                }
              }
              return LoginScreen();
            },
          );
        } else {
          return LoginScreen();
        }
      },
    );
  }

  Future<String> _getUserRole(String userId) async {
    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return 'Job Seeker';
      }
      DocumentSnapshot employerDoc = await _firestore.collection('companies').doc(userId).get();
      if (employerDoc.exists) {
        return 'Employer';
      }
      throw Exception('Role not found');
    } catch (e) {
      print('Error fetching user role: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
