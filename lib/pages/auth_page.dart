import 'package:atlas/main.dart';
import 'package:atlas/pages/login_page.dart';
import 'package:flutter/material.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthPage extends ConsumerWidget {
  const AuthPage({Key? key});

  //Checks if a user is not signed in or not when the app is ran
  //If a user is not signed in, then they go to the login Page
  //If a user is signed in, they go to the home page
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProvider);

    return Scaffold(
      body: user.when(
        data: (user) {
          // User is logged in
          if (user != null) {
            return HomePage();
          }
          // User isn't logged in
          else {
            return LoginPage();
          }
        },
        loading: () {
          return Center(
            child: CircularProgressIndicator(),
          );
        },
        error: (error, stackTrace) {
          return Text('Error: $error');
        },
      ),
    );
  }
}
