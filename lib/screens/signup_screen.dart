import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../components/button.dart';
import '../components/input_fields.dart';
import '../input_validators/input_validators.dart';
import '../models/company.dart';
import '../models/user.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';
import 'employer/employer_complete_profile.dart';
import 'job_seeker/jobseeker_complete_profile.dart';
import 'login_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> with SingleTickerProviderStateMixin{
  final AuthProviders _authProvider= AuthProviders();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  late TabController _tabController;


  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync:this);
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
                'Signup',
                style: headerText28(),
              ),
            ),
            TabBar(
              controller: _tabController,
              tabs: const [
                Tab(text: 'Job Seeker'),
                Tab(text: 'Employer'),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                PasswordTextField(
                  prefixIcon: const Icon(Icons.password),
                  labelText: 'Password',
                  hintText: 'Enter Password',
                  textInputType: TextInputType.visiblePassword,
                  controller: _passController,
                  validator: validatePassword,
                ),
              ],
            ),
            const SizedBox(height: 24),
            DefaultButton(
                labelText: 'Signup',
                textStyle: headerText16().copyWith(color: textLightColor),
                onPressed: () async {
                  final role = _tabController.index == 0 ? 'Job Seeker' : 'Employer';
                  final result = await _authProvider.signUp(
                      _nameController.text,
                      _emailController.text,
                      _passController.text,
                      role);
                  _nameController.clear();
                  _emailController.clear();
                  _passController.clear();

                  if (result is Users) {
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => JobseekerCompleteProfileScreen(user: result)));
                  } else if(result is Company){
                    Navigator.pushReplacement(context, MaterialPageRoute(
                        builder: (context) => const EmployerCompleteProfileScreen()));
                  }
                  _nameController.clear();
                  _emailController.clear();
                  _passController.clear();
                },
                backgroundColor: primaryColor),
            Expanded(
              flex: 2,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextButton(
                    onPressed: () {
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                    },
                    child: Text(
                      "Already have an account? Login",
                      style: headerText14().copyWith(color: primaryColor),
                    )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


