import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../components/custom_bottom_navbar.dart';
import '../../services/firebase_service.dart';
import 'employer_applications_screen.dart';
import 'employer_jobs_screen.dart';
import 'employer_profile_screen.dart';


class EmployerHomeScreen extends StatefulWidget {
  @override
  _EmployerHomeScreenState createState() => _EmployerHomeScreenState();
}

class _EmployerHomeScreenState extends State<EmployerHomeScreen> {

  int _currentIndex = 0; // Index for the BottomNavigationBar

  // Handle screen navigation based on the selected index
  Widget _getSelectedScreen() {
    switch (_currentIndex) {
      case 0:
        return EmployerHomeScreenContent();
      case 1:
        return EmployerJobsScreen();
      case 2:
        return EmployerApplicationsScreen();
      case 3:
        return EmployerProfileScreen();
      default:
        return EmployerHomeScreenContent();
    }
  }


  // Widget for the Employer Home Screen
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //appBar: AppBar(title: Text('Employer Dashboard')),
      body: _getSelectedScreen(),
      bottomNavigationBar: CustomBottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        isEmployer: true, // Pass true for Employer role
      ),
    );
  }
}

class EmployerHomeScreenContent extends StatefulWidget {
  const EmployerHomeScreenContent({super.key});

  @override
  State<EmployerHomeScreenContent> createState() => _EmployerHomeScreenContentState();
}

class _EmployerHomeScreenContentState extends State<EmployerHomeScreenContent> {

  FirebaseService _firebaseService = FirebaseService();
  int totalJobs = 0;
  int totalApplications = 0;
  List<FlSpot> jobApplicationData = [];
  String selectedTimePeriod = 'weekly'; // Can be 'monthly' or 'weekly'

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  // Fetch total jobs, total applications, and job-application data for the chart
  void fetchData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      // Get total jobs created
      _firebaseService.fetchEmployerJobs().listen((jobs) {
        setState(() {
          totalJobs = jobs.length;
        });
      });

      // Get total applications received
      _firebaseService.fetchEmployerApplications().listen((applications) {
        setState(() {
          totalApplications = applications.length;
        });
      });

      // Fetch job-application data for chart (example for monthly or weekly data)
      fetchJobApplicationChartData();
    }
  }

  // Function to generate chart data
  void fetchJobApplicationChartData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      DateTime now = DateTime.now();
      DateTime startDate;

      if (selectedTimePeriod == 'weekly') {
        startDate = now.subtract(Duration(days: 7));
      } else {
        startDate = DateTime(now.year, now.month, 1); // First day of the month
      }

      // Query jobs and applications in the selected time period
      var jobsQuery = await FirebaseFirestore.instance
          .collection('jobs')
          .where('company_Id', isEqualTo: user.uid)
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .get();

      var applicationsQuery = await FirebaseFirestore.instance
          .collection('applications')
          .where('company_Id', isEqualTo: user.uid)
          .where('applied_at', isGreaterThanOrEqualTo: startDate)
          .get();

      setState(() {
        jobApplicationData = [
          FlSpot(0, jobsQuery.size.toDouble()), // Job count
          FlSpot(1, applicationsQuery.size.toDouble()), // Application count
        ];
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Employer Dashboard')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Cards for total jobs and total applications
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Total Jobs Created', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text(totalJobs.toString(), style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
                Card(
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Total Applications Received', style: TextStyle(fontSize: 18)),
                        SizedBox(height: 8),
                        Text(totalApplications.toString(), style: TextStyle(fontSize: 24)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Chart showing jobs and applications data
            Container(
              height: 250,
              child: LineChart(
                LineChartData(
                  gridData: FlGridData(show: true),
                  titlesData: FlTitlesData(show: true),
                  borderData: FlBorderData(show: true),
                  minX: 0,
                  maxX: 1,
                  minY: 0,
                  maxY: (totalJobs > totalApplications) ? totalJobs.toDouble() : totalApplications.toDouble(),
                  lineBarsData: [
                    LineChartBarData(
                      spots: jobApplicationData,
                      isCurved: true,
                      color: Colors.blue,
                      barWidth: 4,
                      isStrokeCapRound: true,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),

            // List of recent applications
            Expanded(
              child: StreamBuilder<List<QueryDocumentSnapshot>>(
                stream: _firebaseService.fetchEmployerApplications(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(child: Text('No recent applications.'));
                  }

                  var applications = snapshot.data!;
                  return ListView.builder(
                    itemCount: applications.length,
                    itemBuilder: (context, index) {
                      var application = applications[index];
                      return ListTile(
                        title: Text(application['job_title'] ?? 'Unknown Job'),
                        subtitle: Text('Applicant: ${application['user_name']}'),
                        trailing: Text('Applied: ${application['applied_at'].toDate()}'),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
