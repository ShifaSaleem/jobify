import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jobify/screens/job_seeker/jobseeker_jobdetail_screen.dart';

class JobCard extends StatelessWidget {
  final QueryDocumentSnapshot job;
  final bool isFeatured;

  const JobCard(this.job, {required this.isFeatured});

  Future<String> _getCompanyLogo(String companyId) async {
    try {
      // Fetch company document using company_id reference
      final companyDoc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(companyId)
          .get();
      if (companyDoc.exists) {
        final companyData = companyDoc.data() as Map<String, dynamic>;
        return companyData['companyLogo'] ??
            ''; // Assuming the company logo field is called 'companyLogo'
      }
    } catch (e) {
      print('Error fetching company logo: $e');
    }
    return ''; // Return an empty string if the logo is not found or there's an error
  }

  @override
  Widget build(BuildContext context) {
    final jobData = job.data() as Map<String, dynamic>;
    final jobId = job.id;
    final companyId = jobData['company_id']; // Get the company_id from job data
    final title = jobData['title'];
    final location = jobData['location'];
    final salary = jobData['salary'].toDouble();
    final category = jobData['category'];

    return FutureBuilder<String>(
      future: _getCompanyLogo(companyId), // Fetch company logo asynchronously
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error fetching logo');
        }
        final companyLogo = snapshot.data ??
            ''; // Use the fetched logo or fallback to an empty string

        return GestureDetector(
          onTap: (){
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobseekerJobDetailScreen(jobId: jobId),
              ),
            );
          },
          child: Card(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: isFeatured
                ? SizedBox(
                    width: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        companyLogo.isNotEmpty
                            ? Image.network(companyLogo,
                                height: 100, width: 250, fit: BoxFit.cover)
                            : Container(
                                height: 100,
                                width: 250,
                                color: Colors.grey), // Fallback if logo is empty
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(title,
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Location: $location\nSalary: \$${salary.toStringAsFixed(0)}\nCategory: $category'),
                        ),
                      ],
                    ),
                  )
                : SizedBox(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            companyLogo.isNotEmpty
                                ? Image.network(companyLogo,
                                    height: 40, width: 40, fit: BoxFit.cover)
                                : Container(
                                    height: 40,
                                    width: 40,
                                    color:
                                        Colors.grey), // Fallback if logo is empty
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(title,
                                  style: TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                              'Location: $location\nSalary: \$${salary.toStringAsFixed(0)}\nCategory: $category'),
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }
}
