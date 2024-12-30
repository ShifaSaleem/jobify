import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'package:jobify/theme/app_theme.dart';
import 'dart:io';

import '../../components/button.dart';

class ApplyNowScreen extends StatefulWidget {
  final String jobId;

  const ApplyNowScreen({super.key, required this.jobId});

  @override
  State<ApplyNowScreen> createState() => _ApplyNowScreenState();
}

class _ApplyNowScreenState extends State<ApplyNowScreen> {
  final _coverLetterController = TextEditingController();
  File? _resumeFile;
  bool _isLoading = false;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickResume() async {
    final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf']);
    if (result != null && result.files.single.path != null) {
      setState(() {
        _resumeFile = File(result.files.single.path!);
      });
    }
  }

  Future<String?> _uploadResume(File file, String userId) async {
    try {
      final ref = _storage.ref('resumes/$userId/${file.path.split('/').last}');
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload resume: $e')),
      );
      return null;
    }
  }

  Future<void> _applyForJob() async {
    if (_resumeFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please upload your resume.')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final user = _auth.currentUser;
    if (user != null) {
      final resumeUrl = await _uploadResume(_resumeFile!, user.uid);
      if (resumeUrl != null) {
        final applicationData = {
          'job_id': widget.jobId,
          'cover_letter': _coverLetterController.text,
          'user_id': user.uid,
          'resume_url': resumeUrl,
          'applied_at': FieldValue.serverTimestamp(),
        };

        await _db.collection('applications').add(applicationData);

        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted successfully!')),
        );

        Navigator.pop(context);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Apply for Job'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload Resume',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _pickResume,
              child: const Text('Pick Resume (PDF)'),
            ),
            if (_resumeFile != null)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: Text('Selected: ${_resumeFile!.path.split('/').last}'),
              ),
            const SizedBox(height: 20),
            const Text(
              'Cover Letter (Optional)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _coverLetterController,
              maxLines: 5,
              decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Write a cover letter...'
              ),
            ),
            const SizedBox(height: 30),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : SizedBox(
              width: double.infinity,
              child: DefaultButton(
                onPressed: _applyForJob,
                labelText: 'Apply Now',
                textStyle: headerText16(),
                backgroundColor: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
