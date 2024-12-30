import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> createJob(Map<String, dynamic> jobData) async {
    final user = _auth.currentUser;
    if (user != null) {
      jobData['company_Id'] = user.uid;
      jobData['created_at'] = FieldValue.serverTimestamp();
      await _db.collection('jobs').add(jobData);
    }
  }

  Stream<List<QueryDocumentSnapshot>> fetchJobs() {
    return _db.collection('jobs').orderBy('created_at', descending: true).snapshots().map(
          (snapshot) => snapshot.docs,
    );
  }

  Stream<List<QueryDocumentSnapshot>> fetchEmployerJobs() {
    final user = _auth.currentUser;
    if (user != null) {
      return _db
          .collection('jobs')
          .where('company_Id', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }
    return Stream.empty();
  }

  Future<void> updateJob(String jobId, Map<String, dynamic> jobData) async {
    await _db.collection('jobs').doc(jobId).update(jobData);
  }

  Future<void> deleteJob(String jobId) async {
    await _db.collection('jobs').doc(jobId).delete();
  }

  Future<void> applyForJob(Map<String, dynamic> applicationData) async {
    final user = _auth.currentUser;
    if (user != null) {
      applicationData['user_Id'] = user.uid;
      applicationData['applied_at'] = FieldValue.serverTimestamp();
      await _db.collection('applications').add(applicationData);
    }
  }

  Stream<List<QueryDocumentSnapshot>> fetchEmployerApplications() {
    final user = _auth.currentUser;
    if (user != null) {
      return _db
          .collection('applications')
          .where('company_Id', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }
    return Stream.empty();
  }

  Stream<List<QueryDocumentSnapshot>> fetchUserApplications() {
    final user = _auth.currentUser;
    if (user != null) {
      return _db
          .collection('applications')
          .where('user_Id', isEqualTo: user.uid)
          .snapshots()
          .map((snapshot) => snapshot.docs);
    }
    return Stream.empty();
  }

  Future<Map<String, dynamic>> fetchApplicationDetails(String applicationId) async {
    try {
      var applicationSnapshot = await _db.collection('applications').doc(applicationId).get();
      if (applicationSnapshot.exists) {
        return applicationSnapshot.data()!;
      }
      throw Exception('Application not found');
    } catch (e) {
      throw Exception('Failed to fetch application details: $e');
    }
  }

  Stream<List<QueryDocumentSnapshot>> fetchSuggestedJobs(
      List<String> skills, {
        String searchQuery = '',
        String category = '',
        double? minSalary,
        double? maxSalary,
        String location = '',
      }) {
    // Start with the base query
    var query = _db.collection('jobs').where('required_skills', arrayContainsAny: skills);

    // Apply search filter on the job title (case-insensitive search)
    if (searchQuery.isNotEmpty) {
      query = query.where('title', isGreaterThanOrEqualTo: searchQuery.toLowerCase())
          .where('title', isLessThan: searchQuery.toLowerCase() + 'z');
    }

    // Apply category filter if provided
    if (category.isNotEmpty) {
      query = query.where('category', isEqualTo: category);
    }

    // Apply salary filters if provided
    if (minSalary != null) {
      query = query.where('salary', isGreaterThanOrEqualTo: minSalary);
    }
    if (maxSalary != null) {
      query = query.where('salary', isLessThanOrEqualTo: maxSalary);
    }

    // Apply location filter if provided
    if (location.isNotEmpty) {
      query = query.where('location', isEqualTo: location);
    }

    // Execute the query and listen for real-time updates
    return query.snapshots().map((snapshot) => snapshot.docs);
  }

  // Fetch employer profile
  Future<Map<String, dynamic>> fetchEmployerProfile() async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        var employerSnapshot = await _db.collection('employers').doc(user.uid).get();
        if (employerSnapshot.exists) {
          return employerSnapshot.data()!;
        }
      }
      throw Exception('Employer not found');
    } catch (e) {
      throw Exception('Failed to fetch employer profile: $e');
    }
  }

  // Update employer profile
  Future<void> updateEmployerProfile(Map<String, dynamic> updatedProfile) async {
    try {
      var user = _auth.currentUser;
      if (user != null) {
        await _db.collection('employers').doc(user.uid).update(updatedProfile);
      }
    } catch (e) {
      throw Exception('Failed to update employer profile: $e');
    }
  }

  Future<Map<String, dynamic>> fetchJobAndCompanyDetails(String jobId) async {
    try {
      // Fetch job details
      final jobDoc = await _db.collection('jobs').doc(jobId).get();
      if (jobDoc.exists) {
        final jobData = jobDoc.data() as Map<String, dynamic>;

        // Fetch company details using company_id from job data
        final companyDoc = await _db.collection('companies').doc(jobData['company_id']).get();
        if (companyDoc.exists) {
          final companyData = companyDoc.data() as Map<String, dynamic>;
          return {
            'job_title': jobData['title'],
            'company_name': companyData['name'],
            'company_logo': companyData['companyLogo'],
            'status': jobData['status'],
          };
        }
      }
    } catch (e) {
      print("Error fetching job and company details: $e");
    }
    return {};
  }

  Future<Map<String, dynamic>> fetchUserProfile(String userId) async {
    try {
      final doc = await _db.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return {};
  }


}
