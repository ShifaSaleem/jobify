import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/button.dart';
import '../../components/input_fields.dart';
import '../../components/tag_input.dart';
import '../../input_validators/input_validators.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'jobseeker_home_screen.dart';

class JobseekerCompleteProfileScreen extends StatefulWidget {
  final Users user;
  const JobseekerCompleteProfileScreen({super.key, required this.user});

  @override
  State<JobseekerCompleteProfileScreen> createState() => _JobseekerCompleteProfileScreenState();
}

class _JobseekerCompleteProfileScreenState extends State<JobseekerCompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late TextEditingController bioController;
  late TextEditingController contactController;
  List<String> selectedSkills = [];
  final AuthProviders _authProvider = AuthProviders();
  late String _profileImageUrl;
  //late final User user;

  File? _profileImage;
  final _imagePicker = ImagePicker();
  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    bioController = TextEditingController();
    contactController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final pickedFile =
    await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage != null) {
      final ref = FirebaseStorage.instance.ref().child('profile_images').child('${widget.user.id}.jpg');
      await ref.putFile(File(_profileImage!.path));  // Upload image to Firebase Storage
      _profileImageUrl = await ref.getDownloadURL();  // Get URL of uploaded image
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 100, 20, 60),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: Text(
                'Complete Profile',
                style: headerText28(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 80,
                        backgroundImage: _profileImage != null
                            ? FileImage(_profileImage!)
                            : null,
                        child: _profileImage == null
                            ? const Icon(Icons.person, size: 80)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickImage,
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTextField(
                  prefixIcon: const Icon(Icons.person),
                  labelText: 'Full Name',
                  hintText: 'Enter Full Name',
                  textInputType: TextInputType.name,
                  controller: _nameController,
                  validator: validateName,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: const Icon(Icons.email),
                  labelText: 'Email',
                  hintText: 'username@gmail.com',
                  textInputType: TextInputType.emailAddress,
                  controller: _emailController,
                  validator: validateEmail,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: const Icon(Icons.info),
                  labelText: 'About',
                  hintText: 'Profession or a bit description about you',
                  textInputType: TextInputType.text,
                  controller: bioController,
                  validator: validateName,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: const Icon(Icons.email),
                  labelText: 'Contact',
                  hintText: '+923546645858',
                  textInputType: TextInputType.number,
                  controller: contactController,
                  validator: validateContact,
                ),
                const SizedBox(height: 16),
                Text('Skills', style: headerText14()),
                const SizedBox(height: 10),
                TagInput(
                  initialTags: selectedSkills,
                  onChanged: (skills) {
                    setState(() {
                      selectedSkills = skills;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            DefaultButton(
                labelText: 'Complete Profile',
                textStyle: headerText16().copyWith(color: textLightColor),
                onPressed: () async {
                  await _uploadProfileImage();
                  await _authProvider.completeUserProfile(
                    userId: widget.user.id,
                    profileImage: _profileImageUrl ?? '',
                    bio: bioController.text,
                    skills: selectedSkills,
                    contact: contactController.text,
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => JobseekerHomeScreen()),
                  );
                },
                backgroundColor: primaryColor),
          ],
        ),
      ),
    );
  }
}
