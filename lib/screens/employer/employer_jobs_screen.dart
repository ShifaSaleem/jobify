import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobify/screens/employer/employer_job_detail_screen.dart';

import '../../services/firebase_service.dart';
import 'create_job_screen.dart';

class EmployerJobsScreen extends StatefulWidget {
  const EmployerJobsScreen({super.key});

  @override
  State<EmployerJobsScreen> createState() => _EmployerJobsScreenState();
}

class _EmployerJobsScreenState extends State<EmployerJobsScreen> {
  FirebaseService _firebaseService = FirebaseService();
  int _selectedJobStatus = 0;

  @override
  void initState() {
    super.initState();
  }

  // Update the job status
  Future<void> _updateJobStatus(String jobId, String newStatus) async {
    await _firebaseService.updateJob(jobId, {'status': newStatus});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employer Jobs')),
      body: _buildJobList(context),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreateJobScreen()),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }

  // Job List Builder
  Widget _buildJobList(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return Center(child: Text('No employer logged in.'));

    return StreamBuilder<List<QueryDocumentSnapshot>>(
      stream: _firebaseService.fetchEmployerJobs(), // Get jobs from Firebase
      builder: (context, jobSnapshot) {
        if (jobSnapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!jobSnapshot.hasData || jobSnapshot.data!.isEmpty) {
          return Center(child: Text('No jobs available.'));
        }

        var jobs = jobSnapshot.data!;
        return ListView.builder(
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            var job = jobs[index];
            var jobId = job.id;
            var jobTitle = job['title'];
            var jobDescription = job['description'];
            var companyId = job['company_Id'];
            var jobStatus = job['status'] ?? 'Open'; // Default to 'Open' if no status

            // Truncate description
            var truncatedDescription = jobDescription.length > 50
                ? jobDescription.substring(0, 50) + '...'
                : jobDescription;

            return FutureBuilder<DocumentSnapshot>(
              future: FirebaseFirestore.instance
                  .collection('companies')
                  .doc(companyId)
                  .get(), // Fetch the company details
              builder: (context, companySnapshot) {
                if (companySnapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (!companySnapshot.hasData) {
                  return ListTile(title: Text('Error loading company.'));
                }

                var companyLogoUrl = companySnapshot.data!['logo_url'] ?? '';
                var companyName = companySnapshot.data!['name'] ?? 'Company';

                return ListTile(
                  leading: companyLogoUrl.isNotEmpty
                      ? CircleAvatar(backgroundImage: NetworkImage(companyLogoUrl))
                      : CircleAvatar(child: Icon(Icons.business)),
                  title: Text(jobTitle),
                  subtitle: Text(truncatedDescription),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(jobStatus),
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          // Show a dialog to change status
                          _showStatusChangeDialog(context, jobId, jobStatus);
                        },
                      ),
                    ],
                  ),
                  onTap: () {
                    // Navigate to the Job Detail Page
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EmployerJobDetailScreen(jobId: jobId),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Show dialog to change job status
  void _showStatusChangeDialog(BuildContext context, String jobId, String currentStatus) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Job Status'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioListTile(
                value: 0,
                groupValue: _selectedJobStatus,
                title: Text('Open'),
                onChanged: (value) {
                  setState(() {
                    _selectedJobStatus = value as int;
                  });
                  _updateJobStatus(jobId, 'Open');
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                value: 1,
                groupValue: _selectedJobStatus,
                title: Text('Closed'),
                onChanged: (value) {
                  setState(() {
                    _selectedJobStatus = value as int;
                  });
                  _updateJobStatus(jobId, 'Closed');
                  Navigator.pop(context);
                },
              ),
              RadioListTile(
                value: 2,
                groupValue: _selectedJobStatus,
                title: Text('Filled'),
                onChanged: (value) {
                  setState(() {
                    _selectedJobStatus = value as int;
                  });
                  _updateJobStatus(jobId, 'Filled');
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

}
