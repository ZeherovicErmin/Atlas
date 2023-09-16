import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:atlas/pages/home_page.dart';

class AuthPage extends StatelessWidget {
  const AuthPage({super.key});

  //Checks if a user is not signed in or not when the app is ran
  //If a user is not signed in, then they go to the login Page
  //If a user is signed in, they go to the home page
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          //User is logged in
          if (snapshot.hasData) {
            return const HomePage();
          }
          //User is not logged in
          else {
            return const LoginPage();
          }
        }
      ),
    );
  }
}