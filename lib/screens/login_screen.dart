import 'package:flutter/material.dart';
import '../components/button.dart';
import '../input_validators/input_validators.dart';
import '../screens/signup_screen.dart';
import '../theme/app_theme.dart';
import '../components/input_fields.dart';
import '../providers/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthProviders _authProvider = AuthProviders();
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
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
                'Login',
                style: headerText28(),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
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
                const SizedBox(height: 16),
                TextButton(
                    onPressed: () {
                      //Navigator.push(context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                    },
                    child: Text(
                      'Forgot Password? Reset',
                      style: headerText14().copyWith(color: primaryColor),
                    )),
              ],
            ),
            const SizedBox(height: 24),
            DefaultButton(
                labelText: 'Login',
                textStyle: headerText16().copyWith(color: textLightColor),
                onPressed: () {
                  _authProvider.login(_emailController.text, _passController.text);
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
                      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignupScreen()));
                    },
                    child: Text(
                      "Don't have an account? Signup",
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
