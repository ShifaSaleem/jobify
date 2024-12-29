import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/company.dart';
import '../models/user.dart';

class AuthProviders {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<dynamic> signUp(String name, String email, String password, String roleName) async {
    try {
      // Fetch role reference from Firestore
      final roleSnapshot = await _firestore
          .collection('roles')
          .where('name', isEqualTo: roleName)
          .limit(1)
          .get();

      if (roleSnapshot.docs.isEmpty) {
        throw Exception("Role does not exist");
      }

      final roleRef = roleSnapshot.docs.first.reference;

      // Create user with Firebase Authentication
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final userId = userCredential.user!.uid;

      if (roleName == 'Job Seeker') {
         final user = Users(
          id: userId,
          name: name,
          email: email,
          bio: '',
          profileImage: null,
          skills: [],
          contact: '',
           password: '',
        );
        await _firestore.collection('users').doc(userId).set(user.toMap());
        await _saveUserId(userId, roleName);
        return user;
      } else {
        final employer = Company(
          id: userId,
          name: name,
          email: email,
          bio: '',
          logo: null,
          website: '',
          contact: '',
          location: '',
        );
        await _firestore.collection('employers').doc(userId).set(employer.toMap());
        await _saveUserId(userId, roleName);
        return employer;
      }

    } catch (e) {
      print('Error during sign up: $e');
      rethrow;
    }
  }


  Future<void> login(String email, String password) async {
    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } catch (e) {
      print(e);
    }
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  Future<void> checkUserAuthentication(Function onAuthenticated, Function onNotAuthenticated) async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      onAuthenticated();
    } else {
      onNotAuthenticated();
    }
  }

  Future<void> completeUserProfile({
    required String userId,
    required String profileImage,
    required String bio,
    required List<String> skills,
    required String contact,
  }) async {
    try {
      await _firestore.collection('users').doc(userId).update({
        'profile_image': profileImage,
        'bio': bio,
        'skills': skills,
        'contact': contact,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> completeEmployerProfile({
    required String userId,
    required String logo,
    required String bio,
    required String website,
    required String contact,
    required String location,
  }) async {
    try {
      await _firestore.collection('employers').doc(userId).update({
        'logo': logo,
        'bio': bio,
        'website': website,
        'contact': contact,
        'location': location,
      });
    } catch (e) {
      print(e);
      rethrow;
    }
  }

  Future<void> _saveUserId(String userId, String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    await prefs.setString('role', role);
  }

  Future<Map<String, String?>> getUserCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'userId': prefs.getString('userId'),
      'role': prefs.getString('role'),
    };
  }

  Future<List<Map<String, dynamic>>> fetchUser() async {
    try {
      QuerySnapshot snapshot =
      await FirebaseFirestore.instance.collection('users').get();
      return snapshot.docs.map((doc) => doc.data() as Map<String, dynamic>).toList();
    } catch (e) {
      print(e);
      return [];
    }
  }

}
