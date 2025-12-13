import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;
  final bool isEmail;

  const AuthField({
    super.key,
    required this.hintText,
    required this.controller,
    this.isObscureText = false,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      obscureText: isObscureText,
      decoration: InputDecoration(border: InputBorder.none, hintText: hintText),
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return '$hintText is required';
        }

        if (isEmail) {
          final email = value.trim().toLowerCase();
          final regex = RegExp(
            r'^[a-zA-Z0-9._%+-]+@(muj|jaipur)\.manipal\.edu$',
          );

          if (!regex.hasMatch(email)) {
            return 'Use your Manipal email (muj / jaipur)';
          }
        }

        return null;
      },
    );
  }
}
