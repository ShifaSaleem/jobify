import 'package:flutter/material.dart';
import 'package:jobify/theme/app_theme.dart';
import '../../services/firebase_service.dart';

class ApplicationDetailScreen extends StatefulWidget {
  final String applicationId;

  const ApplicationDetailScreen({super.key, required this.applicationId});

  @override
  _ApplicationDetailScreenState createState() => _ApplicationDetailScreenState();
}

class _ApplicationDetailScreenState extends State<ApplicationDetailScreen> {
  final FirebaseService _firebaseService = FirebaseService();
  late Future<Map<String, dynamic>> applicationDetails;

  @override
  void initState() {
    super.initState();
    applicationDetails = _firebaseService.fetchApplicationDetails(widget.applicationId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Application Details'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: applicationDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('No application details found.'));
          }

          var application = snapshot.data!;
          var applicantData = application['applicant']; // Applicant data
          var jobDetails = application['job']; // Job details

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Applicant Information
                  CircleAvatar(
                    backgroundImage: NetworkImage(applicantData['profileImage']),
                    radius: 40,
                  ),
                  SizedBox(height: 8),
                  Text(
                    applicantData['name'],
                    style: headerText16(),
                  ),
                  Text(applicantData['bio']),
                  SizedBox(height: 8),
                  Wrap(
                    spacing: 8.0,
                    children: applicantData['skills']
                        .map<Widget>((skill) => Chip(label: Text(skill)))
                        .toList(),
                  ),
                  Divider(),
                  SizedBox(height: 16),

                  // Job Information
                  Text(
                    'Job Title: ${jobDetails['title']}',
                    style: headerText16(),
                  ),
                  SizedBox(height: 8),
                  Text('Job Description: ${jobDetails['description']}'),
                  SizedBox(height: 8),
                  Text('Salary: ${jobDetails['salary']}'),
                  SizedBox(height: 8),
                  Text('Location: ${jobDetails['location']}'),
                  SizedBox(height: 8),
                  Divider(),
                  SizedBox(height: 16),

                  // Resume and Other Documents
                  if (application['resume'] != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Resume:',
                          style: headerText16(),
                        ),
                        SizedBox(height: 8),
                        ElevatedButton(
                          onPressed: () {
                            // Handle resume download or viewing
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Resume Download'),
                                  content: Text('Are you sure you want to download the resume?'),
                                  actions: <Widget>[
                                    TextButton(
                                      child: Text('Cancel'),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                    TextButton(
                                      child: Text('Download'),
                                      onPressed: () {
                                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                          content: Text('Resume downloaded successfully!'),
                                        ));
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Download Resume'),
                        ),
                      ],
                    ),
                  SizedBox(height: 16),

                  // Contact Info
                  Text(
                    'Contact Info:',
                    style: headerText16(),
                  ),
                  SizedBox(height: 8),
                  Text('Phone: ${applicantData['phoneNumber']}'),
                  SizedBox(height: 8),
                  Text('Email: ${applicantData['email']}'),
                  SizedBox(height: 8),

                  // Other details (e.g., experience, qualifications)
                  Text(
                    'Experience:',
                    style: headerText16(),
                  ),
                  SizedBox(height: 8),
                  Text(applicantData['experience'] ?? 'No experience listed.'),
                  SizedBox(height: 8),
                  Text(
                    'Qualifications:',
                    style: headerText16(),
                  ),
                  SizedBox(height: 8),
                  Text(applicantData['qualifications'] ?? 'No qualifications listed.'),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
