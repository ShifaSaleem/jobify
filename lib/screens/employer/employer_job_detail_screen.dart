import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EmployerJobDetailScreen extends StatelessWidget {
  final String jobId;

  const EmployerJobDetailScreen({super.key, required this.jobId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('jobs').doc(jobId).get(),
        builder: (context, jobSnapshot) {
          if (jobSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!jobSnapshot.hasData || !jobSnapshot.data!.exists) {
            return const Center(child: Text('Job not found.'));
          }

          var jobData = jobSnapshot.data!;
          var jobTitle = jobData['title'];
          var jobDescription = jobData['description'];
          var jobRequirements = jobData['requirements'] ?? 'No requirements listed.';
          var jobSkills = List<String>.from(jobData['required_skills'] ?? []);
          var jobSalary = jobData['salary'] ?? 'Not specified';
          var jobStatus = jobData['status'] ?? 'Open';

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    jobTitle,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Status: $jobStatus',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Salary: $jobSalary',
                    style: const TextStyle(fontSize: 18),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Full Description',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jobDescription,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Requirements',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    jobRequirements,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Required Skills',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8.0,
                    runSpacing: 4.0,
                    children: jobSkills.map((skill) {
                      return Chip(
                        label: Text(skill),
                        backgroundColor: Colors.blue.shade100,
                      );
                    }).toList(),
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
