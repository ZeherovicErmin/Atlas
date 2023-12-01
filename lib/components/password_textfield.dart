//Author: Matthew McGowan
import 'package:flutter/material.dart';
import 'package:atlas/pages/register_page.dart';

class PasswordTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final bool obscureText;
  final RegistrationState registrationState;
  final bool passwordTextField;

  const PasswordTextField({
    required this.controller,
    required this.hintText,
    required this.obscureText,
    required this.registrationState,
    this.passwordTextField = true,
  });

  @override
  _PasswordTextFieldState createState() => _PasswordTextFieldState();
}

class _PasswordTextFieldState extends State<PasswordTextField> {
  String errorMessage = '';

  //Initializes the text field
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(confirmPassword);
  }

  //Stores the password and confirm password
  void confirmPassword() {
    final text = widget.controller.text;
    final password = widget.registrationState.passwordController.text.trim();
    final confirmPassword = widget.registrationState.confirmPasswordController.text.trim();

    //Checks the password requirements and that the confirm password field matches
    setState(() {
      if (widget.passwordTextField) {
        if (text.length < 6) {
          errorMessage = 'Password must contain 6 or more characters';
        } else {
          errorMessage = '';
        }
      } else {
        if (password == confirmPassword) {
          errorMessage = '';
        } else {
          errorMessage = 'Passwords do not match';
        }
      }
    });
  }

  //For the customizing the fields a user can use to type in
  //(password text field and confirm password text field)
  //Builds the text field
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        controller: widget.controller,
        obscureText: widget.obscureText,
        onChanged: (_) {
          confirmPassword();
        },
        decoration: InputDecoration(
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: widget.hintText,
            hintStyle: TextStyle(color: Colors.grey[500]),
            errorText: errorMessage.isNotEmpty ? errorMessage : null,
        ),
      ),
    );
  }

  //Removes the listener for the confirmPassword function
  @override
  void dispose() {
    widget.controller.removeListener(confirmPassword);
    super.dispose();
  }
}