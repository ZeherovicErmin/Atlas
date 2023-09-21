import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/register_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginOrRegisterPage extends ConsumerWidget {
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