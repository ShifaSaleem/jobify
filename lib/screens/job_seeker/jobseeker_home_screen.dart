import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jobify/theme/app_theme.dart';

import '../../components/custom_bottom_navbar.dart';
import '../../components/job_card.dart';
import '../../services/firebase_service.dart';
import 'jobseeker_applications_screen.dart';
import 'jobseeker_profile_screen.dart';

class JobseekerHomeScreen extends StatefulWidget {
  const JobseekerHomeScreen({super.key});

  @override
  State<JobseekerHomeScreen> createState() => _JobseekerHomeScreenState();
}

class _JobseekerHomeScreenState extends State<JobseekerHomeScreen> {
  int _currentIndex = 0; // Index for the BottomNavigationBar

  // Handle screen navigation based on the selected index
  Widget _getSelectedScreen() {
    switch (_currentIndex) {
      case 0:
        return JobseekerHomeContent();
      case 1:
        return JobSeekerApplicationsScreen();
      case 2:
        return JobSeekerProfileScreen();
      default:
        return JobseekerHomeContent();
    }
  }

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
        isEmployer: false, // Pass true for Employer role
      ),
    );
  }
}

class JobseekerHomeContent extends StatefulWidget {
  const JobseekerHomeContent({super.key});

  @override
  State<JobseekerHomeContent> createState() => _JobseekerHomeContentState();
}

class _JobseekerHomeContentState extends State<JobseekerHomeContent> {
  final FirebaseService _firebaseService = FirebaseService();
  List<String> userSkills = [];
  String searchQuery = '';
  String selectedCategory = '';
  String selectedLocation = '';
  double minSalary = 0;
  double maxSalary = 1000000;

  @override
  void initState() {
    super.initState();
    fetchUserSkills();
  }

  Future<void> fetchUserSkills() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();
      if (doc.exists) {
        setState(() {
          userSkills = List<String>.from(doc['skills'] ?? []);
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Job Seeker Home'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search jobs...',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                // Category filter dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedCategory.isEmpty ? null : selectedCategory,
                    hint: Text('Category'),
                    onChanged: (value) {
                      setState(() {
                        selectedCategory = value ?? '';
                      });
                    },
                    items: ['Technology', 'Marketing', 'Design', 'Business']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
                // Location filter dropdown
                Expanded(
                  child: DropdownButton<String>(
                    value: selectedLocation.isEmpty ? null : selectedLocation,
                    hint: Text('Location'),
                    onChanged: (value) {
                      setState(() {
                        selectedLocation = value ?? '';
                      });
                    },
                    items: ['Remote', 'New York', 'Los Angeles', 'Chicago']
                        .map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                // Min Salary filter
                Expanded(
                  child: Slider(
                    value: minSalary,
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    label: minSalary.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        minSalary = value;
                      });
                    },
                  ),
                ),
                // Max Salary filter
                Expanded(
                  child: Slider(
                    value: maxSalary,
                    min: 0,
                    max: 1000000,
                    divisions: 100,
                    label: maxSalary.toStringAsFixed(0),
                    onChanged: (value) {
                      setState(() {
                        maxSalary = value;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Featured Jobs Section (Horizontal Scrolling)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Featured Jobs',
                      style: headerText18(),
                    ),
                  ),
                  SizedBox(
                    height: 250,
                    child: StreamBuilder(
                      stream: _firebaseService.fetchJobs(),
                      builder: (context,
                          AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                        if (snapshot.hasData) {
                          final jobs = snapshot.data!;
                          return ListView(
                            scrollDirection: Axis.horizontal,
                            children: jobs
                                .map((job) => JobCard(job, isFeatured: true))
                                .toList(),
                          );
                        }
                        return Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  // Suggested Jobs Section (Vertical Scrolling)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Suggested Jobs',
                      style: headerText18(),
                    ),
                  ),
                  StreamBuilder(
                    stream: _firebaseService.fetchSuggestedJobs(userSkills,
                        searchQuery: searchQuery,
                        category: selectedCategory,
                        location: selectedLocation,
                        minSalary: minSalary,
                        maxSalary: maxSalary),
                    builder: (context,
                        AsyncSnapshot<List<QueryDocumentSnapshot>> snapshot) {
                      if (snapshot.hasData) {
                        final jobs = snapshot.data!;
                        return ListView(
                          shrinkWrap: true,
                          children: jobs
                              .map((job) => JobCard(job, isFeatured: false))
                              .toList(),
                        );
                      }
                      return Center(child: CircularProgressIndicator());
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
