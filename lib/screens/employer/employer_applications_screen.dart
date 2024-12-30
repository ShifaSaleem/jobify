import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../services/firebase_service.dart';
import 'application_detail_screen.dart';

class EmployerApplicationsScreen extends StatefulWidget {
  const EmployerApplicationsScreen({super.key});

  @override
  _EmployerApplicationsScreenState createState() => _EmployerApplicationsScreenState();
}

class _EmployerApplicationsScreenState extends State<EmployerApplicationsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Job Applications"),
      ),
      body: StreamBuilder<List<QueryDocumentSnapshot>>(
        stream: _firebaseService.fetchEmployerApplications(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No applications received.'));
          }

          var applications = snapshot.data!;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              var application = applications[index];
              var applicantData = application['applicant']; // The applicant's user data

              return ListTile(
                contentPadding: EdgeInsets.all(10),
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(applicantData['profileImage']),
                  radius: 30,
                ),
                title: Text(applicantData['name']),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(applicantData['bio'], maxLines: 1, overflow: TextOverflow.ellipsis),
                    SizedBox(height: 5),
                    Wrap(
                      spacing: 8.0,
                      children: applicantData['skills']
                          .map<Widget>((skill) => Chip(label: Text(skill)))
                          .toList(),
                    ),
                  ],
                ),
                onTap: () {
                  // Navigate to application details screen
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ApplicationDetailScreen(
                        applicationId: application.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
