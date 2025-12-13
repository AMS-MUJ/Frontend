import 'package:flutter/material.dart';

class AuthField extends StatelessWidget {
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;
  final bool isEmail;
  final String errorText;

  const AuthField({
    super.key,
    this.hintText = "example@muj.manipal.edu",
    required this.controller,
    required this.errorText,
    this.isObscureText = false,
    this.isEmail = false,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text,
      obscureText: isObscureText,
      decoration: InputDecoration(
        border: InputBorder.none,
        hintText: hintText,
        hintStyle: TextStyle(fontWeight: FontWeight.w300),
      ),
    );
  }
}
