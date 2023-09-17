/*
import 'package:atlas/components/square_tile.dart';
import 'package:atlas/components/my_button.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  //Text Editing Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //Sign user in method
  void signUserUp() async {
    //Displays a loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    //Checks to make sure the password is confirmed when making an account
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      showErrorMessage('Passwords do not match');
      return;
    }

    //Atempts to create a new user
    try {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );
      //Gets rid of the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //Gets rid of the loading circle
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        showErrorMessage('Password is too weak');
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage('An account already exists for that email');
      }
    }
  }

  //Error Message Popup
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
        });
  }

  //Login Page setup
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
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
                        height: 120,
                        width: 120,
                        //color: Colors.blue,
                        child: Image.asset('lib/icons/fitness.png')),

                    //const SizedBox(height: 5),

                    //Atlas title
                    Text(
                      'Atlas',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 32,
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

                    //Confirm password textfield
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 15),

                    //Sign-in button
                    MyButton(
                      text: 'Sign Up',
                      onTap: signUserUp,
                    ),

                    const SizedBox(height: 10),

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

                    const SizedBox(height: 25),

                    //Register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Login now',
                            style: TextStyle(
                                color: Colors.blue,
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
*/
import 'package:atlas/components/square_tile.dart';
import 'package:atlas/components/my_button.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterPage extends StatefulWidget {
  final Function()? onTap;
  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPage();
}

class _RegisterPage extends State<RegisterPage> {
  //Text Editing Controllers
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  //Sign user in method
  void signUserUp() async {
    //Displays a loading circle
    showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        });

    //Checks to make sure the password is confirmed when making an account
    if (passwordController.text != confirmPasswordController.text) {
      Navigator.pop(context);
      showErrorMessage('Passwords do not match');
      return;
    }

    //Atempts to create a new user
    try {
      //creating the user
      UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      //after creating the user, create a doc in the cloud firebase
      FirebaseFirestore.instance
          .collection("Users")
          .doc(userCredential.user!.email)
          .set({
        'username': emailController.text.split('@')[0], // initial username
        'bio': 'Empty Bio...' //initally empty bio
        //add additional fields as needed
      });

      //Gets rid of the loading circle
      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      //Gets rid of the loading circle
      Navigator.pop(context);
      if (e.code == 'weak-password') {
        showErrorMessage('Password is too weak');
      } else if (e.code == 'email-already-in-use') {
        showErrorMessage('An account already exists for that email');
      }
    }
  }

  //Error Message Popup
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
        });
  }

  //Login Page setup
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[300],
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
                        height: 120,
                        width: 120,
                        //color: Colors.blue,
                        child: Image.asset('lib/icons/fitness.png')),

                    //const SizedBox(height: 5),

                    //Atlas title
                    Text(
                      'Atlas',
                      style: TextStyle(
                        color: Colors.blue[700],
                        fontSize: 32,
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

                    //Confirm password textfield
                    MyTextField(
                      controller: confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: true,
                    ),

                    const SizedBox(height: 15),

                    //Sign-in button
                    MyButton(
                      text: 'Sign Up',
                      onTap: signUserUp,
                    ),

                    const SizedBox(height: 10),

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

                    const SizedBox(height: 25),

                    //Register now
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: widget.onTap,
                          child: const Text(
                            'Login now',
                            style: TextStyle(
                                color: Colors.blue,
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
