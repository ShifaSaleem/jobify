import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../components/button.dart';
import '../../components/input_fields.dart';
import '../../components/tag_input.dart';
import '../../input_validators/input_validators.dart';
import '../../models/company.dart';
import '../../models/user.dart';
import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import 'employer_home_screen.dart';

class EmployerCompleteProfileScreen extends StatefulWidget {
  final Company user;
  const EmployerCompleteProfileScreen({super.key, required this.user});

  @override
  State<EmployerCompleteProfileScreen> createState() => _EmployerCompleteProfileScreenState();
}

class _EmployerCompleteProfileScreenState extends State<EmployerCompleteProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  late TextEditingController bioController;
  late TextEditingController contactController;
  late TextEditingController websiteController;
  String country = "Select Country";
  String city = "Select City";
  String? _companyLogoUrl;

  File? _companyLogo;
  final _imagePicker = ImagePicker();
  final AuthProviders _authProvider = AuthProviders();

  @override
  void initState() {
    super.initState();
    _nameController.text = widget.user.name;
    _emailController.text = widget.user.email;
    bioController = TextEditingController();
    contactController = TextEditingController();
    websiteController = TextEditingController();
  }

  Future<void> _pickCompanyLogo() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _companyLogo = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadCompanyLogo() async {
    if (_companyLogo != null) {
      final ref = FirebaseStorage.instance.ref().child('company_logos').child('${widget.user.id}_logo.jpg');
      await ref.putFile(File(_companyLogo!.path));  // Upload image to Firebase Storage
      _companyLogoUrl = await ref.getDownloadURL();  // Get URL of uploaded image
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
                        backgroundImage: _companyLogo != null
                            ? FileImage(_companyLogo!)
                            : null,
                        child: _companyLogo == null
                            ? const Icon(Icons.business, size: 80)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _pickCompanyLogo,
                        ),
                      ),
                    ],
                  ),
                ),
                DefaultTextField(
                  prefixIcon: const Icon(Icons.business),
                  labelText: 'Company Name',
                  hintText: 'Enter Company Name',
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
                  hintText: 'A brief description about your company',
                  textInputType: TextInputType.text,
                  controller: bioController,
                  validator: validateName,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: const Icon(Icons.phone),
                  labelText: 'Contact',
                  hintText: '+923546645858',
                  textInputType: TextInputType.number,
                  controller: contactController,
                  validator: validateContact,
                ),
                const SizedBox(height: 16),
                DefaultTextField(
                  prefixIcon: const Icon(Icons.link),
                  labelText: 'Website',
                  hintText: 'http://www.companywebsite.com',
                  textInputType: TextInputType.url,
                  controller: websiteController,
                  validator: validateWebsite,
                ),
                const SizedBox(height: 16),
                Text('Location', style: headerText14()),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: country,
                  onChanged: (newValue) {
                    setState(() {
                      country = newValue!;
                    });
                  },
                  items: <String>['Select Country', 'USA', 'India', 'UK', 'Canada']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: city,
                  onChanged: (newValue) {
                    setState(() {
                      city = newValue!;
                    });
                  },
                  items: <String>['Select City', 'New York', 'London', 'Toronto', 'Delhi']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ],
            ),
            const SizedBox(height: 24),
            DefaultButton(
                labelText: 'Complete Profile',
                textStyle: headerText16().copyWith(color: textLightColor),
                onPressed: () async {
                  await _uploadCompanyLogo();
                  await _authProvider.completeEmployerProfile(
                    userId: widget.user.id,
                    logo: _companyLogoUrl ?? '',
                    bio: bioController.text,
                    contact: contactController.text,
                    website: websiteController.text,
                    location: '$country, $city',
                  );
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => EmployerHomeScreen()),
                  );
                },
                backgroundColor: primaryColor),
          ],
        ),
      ),
    );
  }
}
