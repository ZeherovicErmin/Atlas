import 'package:atlas/components/square_tile.dart';
import 'package:atlas/components/my_button.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Creating the necessary Registration States and text controllers
class RegistrationState {
  final auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  }

  // Function to clear the text boxes
  void clearTextControllers() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
  }
}

// Class to attempt to register a user
class RegisterPage extends ConsumerWidget {
  const RegisterPage({Key? key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final registrationState = ref.watch(registrationProvider);

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

    void signUserUp() async {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      if (registrationState.passwordController.text !=
          registrationState.confirmPasswordController.text) {
        Navigator.pop(context);
        showErrorMessage('Passowrds do not match');
        return;
      }

try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: registrationState.emailController.text,
          password: registrationState.passwordController.text,
        );

        FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
          'username': registrationState.emailController.text
              .split('@')[0], // initial username
          'bio': 'Empty Bio...' //initally empty bio
          //add additional fields as needed
        });

        Navigator.pop(context); // Closes the loading circle
        Navigator.of(context).pushReplacementNamed('/home');
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        if (e.code == 'weak-password') {
          showErrorMessage('Password is too weak');
        } else if (e.code == 'email-already-in-use') {
          showErrorMessage('An account already exists for that email');
        }
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
                      controller: registrationState.emailController,
                      hintText: 'Email',
                      obscureText: false,
                    ),

                    const SizedBox(height: 10),

                    //Password textfield
                    MyTextField(
                      controller: registrationState.passwordController,
                      hintText: 'Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 10),

                    //Confirm password textfield
                    MyTextField(
                      controller: registrationState.confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 25),

                    //Sign-in button
                    MyButton(
                      text: 'Sign Up',
                      onTap: signUserUp,
                    ),

                    const SizedBox(height: 10),

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
                        const Text (
                          'Already have an account?',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          child: const Text(
                            'Login now',
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
