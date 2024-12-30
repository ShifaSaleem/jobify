import 'package:flutter/material.dart';

import '../../services/firebase_service.dart';


class EditEmployerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> profileData;

  const EditEmployerProfileScreen({super.key, required this.profileData});

  @override
  _EditEmployerProfileScreenState createState() => _EditEmployerProfileScreenState();
}

class _EditEmployerProfileScreenState extends State<EditEmployerProfileScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _companyNameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneNumberController;
  late TextEditingController _companyDescriptionController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.profileData['name']);
    _companyNameController = TextEditingController(text: widget.profileData['companyName']);
    _emailController = TextEditingController(text: widget.profileData['email']);
    _phoneNumberController = TextEditingController(text: widget.profileData['phoneNumber']);
    _companyDescriptionController = TextEditingController(text: widget.profileData['companyDescription']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneNumberController.dispose();
    _companyDescriptionController.dispose();
    super.dispose();
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      Map<String, dynamic> updatedProfile = {
        'name': _nameController.text,
        'companyName': _companyNameController.text,
        'email': _emailController.text,
        'phoneNumber': _phoneNumberController.text,
        'companyDescription': _companyDescriptionController.text,
      };

      try {
        await _firebaseService.updateEmployerProfile(updatedProfile);
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.pop(context); // Go back to the profile screen
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _companyNameController,
                  decoration: const InputDecoration(labelText: 'Company Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your company name';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _phoneNumberController,
                  decoration: const InputDecoration(labelText: 'Phone Number'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your phone number';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _companyDescriptionController,
                  decoration: const InputDecoration(labelText: 'Company Description'),
                  maxLines: 5,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a company description';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _saveProfile,
                  child: const Text('Save Profile'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
