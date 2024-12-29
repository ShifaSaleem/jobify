import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class DefaultTextField extends StatelessWidget {
  final Icon prefixIcon;
  final TextInputType textInputType;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;

  const DefaultTextField(
      {super.key,
      required this.prefixIcon,
      required this.labelText,
      required this.hintText,
      required this.textInputType,
      required this.validator,
      required this.controller});
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          labelText,
          style: headerText14(),
        ),
        const SizedBox(height: 10),
        Container(
          height: 46,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  blurStyle: BlurStyle.outer),
            ],
          ),
          child: TextFormField(
              style: bodyText14(),
              controller: controller,
              keyboardType: textInputType,
              validator: validator,
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  prefixIcon: prefixIcon,
                  prefixIconColor: iconColor,
                  hintText: hintText,
                  hintStyle: bodyText14(textColor: hintTextColor))),
        ),
      ],
    );
  }
}

class PasswordTextField extends StatefulWidget {
  final Icon prefixIcon;
  final TextInputType textInputType;
  final String labelText;
  final String hintText;
  final FormFieldValidator<String> validator;
  final TextEditingController controller;

  const PasswordTextField(
      {super.key,
      required this.prefixIcon,
      required this.labelText,
      required this.hintText,
      required this.textInputType,
      required this.validator,
      required this.controller});

  @override
  State<PasswordTextField> createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  bool _isPasswordVisible = false;
  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.labelText,
          style: headerText14(),
        ),
        const SizedBox(height: 10),
        Container(
          height : 46,
          decoration: const BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            boxShadow: [
              BoxShadow(
                  color: Colors.black12,
                  blurRadius: 4,
                  blurStyle: BlurStyle.outer),
            ],
          ),
          child: TextFormField(
              style: bodyText14(),
              controller: widget.controller,
              obscureText: !_isPasswordVisible,
              keyboardType: widget.textInputType,
              validator: widget.validator,
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(vertical: 8.0, horizontal: 14.0),
                  border: const OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(30.0)),
                  ),
                  prefixIcon: widget.prefixIcon,
                  prefixIconColor: iconColor,
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility,),
                    onPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                  ),
                  suffixIconColor: primaryColor,
                  hintText: widget.hintText,
                  hintStyle: bodyText14(textColor: hintTextColor))),
        ),
      ],
    );
  }
}
