import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';  // Assuming FirebaseService is where your methods are defined

class JobSeekerApplicationsScreen extends StatefulWidget {
  const JobSeekerApplicationsScreen({super.key});

  @override
  _JobSeekerApplicationsScreenState createState() =>
      _JobSeekerApplicationsScreenState();
}

class _JobSeekerApplicationsScreenState extends State<JobSeekerApplicationsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: StreamBuilder(
        stream: _firebaseService.fetchUserApplications(),
        builder: (context, AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No applications found.'));
          }

          final applications = snapshot.data!;

          return ListView.builder(
            itemCount: applications.length,
            itemBuilder: (context, index) {
              final application = applications[index];
              final jobId = application['job_id'];  // Assuming job_id is stored in the application document

              return FutureBuilder<Map<String, dynamic>>(
                future: _firebaseService.fetchJobAndCompanyDetails(jobId),
                builder: (context, jobSnapshot) {
                  if (jobSnapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: CircularProgressIndicator(),
                    );
                  }

                  if (!jobSnapshot.hasData) {
                    return const SizedBox.shrink();
                  }

                  final jobData = jobSnapshot.data!;
                  final companyLogo = jobData['company_logo'] ?? '';
                  final jobTitle = jobData['job_title'] ?? '';
                  final companyName = jobData['company_name'] ?? '';
                  final status = application['status'] ?? 'Pending';  // Assuming application has 'status' field

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    child: Padding(
                      padding: const EdgeInsets.all(10),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Company Logo
                          companyLogo.isNotEmpty
                              ? Image.network(
                            companyLogo,
                            height: 50,
                            width: 50,
                            fit: BoxFit.cover,
                          )
                              : const Placeholder(
                            fallbackHeight: 50,
                            fallbackWidth: 50,
                          ),
                          const SizedBox(width: 10),
                          // Job Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  jobTitle,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  companyName,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey,
                                  ),
                                ),
                                Text(
                                  'Status: $status',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: status == 'Pending'
                                        ? Colors.orange
                                        : (status == 'Accepted' ? Colors.green : Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
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
