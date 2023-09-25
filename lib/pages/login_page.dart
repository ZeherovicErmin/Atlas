import 'package:atlas/components/square_tile.dart';
import 'package:atlas/components/my_button.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:atlas/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Converting loginPage to use Providers created in main.dart
class LoginPage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watching the provider in main.dart for user changes
    final user = ref.watch(userProvider);
    final emailController = ref.watch(emailControllerProvider);
    final passwordController = ref.watch(passwordControllerProvider);
    final auth = FirebaseAuth.instance;

    void showErrorMessage(String message) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.red,
            title: Center(
              child: Text(
                message,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          );
        },
      );
    }

    // Function to handle signing in to firebase
    Future<void> signIn(BuildContextcontext) async {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

        // Successful login
        Navigator.of(context).pushReplacementNamed('/home');
      } catch (e) {
        showErrorMessage('Email or password is incorrect');
        print("Sign-in failed: $e");
      }
    }

    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    //White space above logo
                    const SizedBox(height: 5),

                    //Logo
                    SizedBox(
                        height: 220,
                        width: 220,
                        //color: Colors.blue,
                        child: Image.asset('lib/images/atlas.png')),

                    //const SizedBox(height: 5),

                    //Atlas title
                    const Text(
                      'Atlas',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    //Username textfield
                    MyTextField(
                      controller: emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    //Password textfield
                    MyTextField(
                      controller: passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 10),

                    /*
                    NOT FUNCTIONAL YET
                    //Forgot Password
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            'Forgot Password?',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),

                  */

                    const SizedBox(height: 15),

                    //Sign-in button
                    MyButton(
                      text: 'Sign In',
                      onTap: () => signIn(context),
                    ),

                    const SizedBox(height: 25),

                  /*
                  NOT FUNCTIONAL YET
                    //Continue
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 25.0),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                          Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                            child: Text(
                              'Or continue with',
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          Expanded(
                            child: Divider(
                              thickness: 0.5,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    //Apple and Google sign-in
                    const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        //Google button
                        SquareTile(
                            imagePath:
                                'lib/images/google-logo-transparent.png'),

                        SizedBox(width: 30),

                        //Apple button
                        SquareTile(
                            imagePath: 'lib/images/apple-logo-transparent.png')
                      ],
                    ),

                  */

                    const SizedBox(height: 25),

                    //Register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Not a member?',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/register');
                          },
                          child: const Text(
                            'Register now',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 60, 255),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ]),
            ),
          ),
        ));
  }
}
