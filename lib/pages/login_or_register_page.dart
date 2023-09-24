import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/register_page.dart';
import 'package:flutter/material.dart';

class LoginOrRegisterPage extends StatefulWidget {
  const LoginOrRegisterPage({super.key});

  @override
  State<LoginOrRegisterPage> createState() => _LoginOrRegisterState();
}

class _LoginOrRegisterState extends State<LoginOrRegisterPage> {

  //Shows login page when true
  bool showLoginPage = true;

  //Goes back and forth from login and register page
  void togglePages() {
    setState(() {
      showLoginPage = !showLoginPage;
    });
  }

  //Toggles between logging in or signing up
  @override
  Widget build(BuildContext context) {
    if (showLoginPage) {
      return LoginPage (
        onTap: togglePages,
      );
    } else {
      return RegisterPage(
        onTap: togglePages,
      );
    }
  }
}