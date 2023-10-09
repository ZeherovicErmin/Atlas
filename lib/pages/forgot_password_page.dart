import 'package:flutter/material.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atlas/components/my_button.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}
class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();

  void showErrorMessage(String message) {
  showDialog(
    context: context,
    builder: (context) {
      return AlertDialog(
        backgroundColor:
        Colors.red,
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

  void showSuccessMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: Colors.green,
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

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }

  Future passwordReset() async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text.trim());
      showSuccessMessage('A password reset link has been sent to your email');
    } on FirebaseAuthException catch (e) {
      print(e);
      showErrorMessage('An account for that email address does not exist');
    }
  }

@override
Widget build(BuildContext context) {
  return Scaffold(
    body: gradient(context), // Use the gradient function here
  );
}
Widget gradient (BuildContext context) {
  return Container (
    decoration: const BoxDecoration (
      gradient: LinearGradient (
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          Color.fromARGB(255, 90, 117, 255),
            Color.fromARGB(255, 161, 195, 250),
        ],
      ),
    ),
    child: SafeArea (
      child: Center (
        child: SingleChildScrollView (
          child: Column (
            mainAxisAlignment: MainAxisAlignment.center,
              children: [
              //White Space above logo
              const SizedBox (height: 5),

              //Logo
              SizedBox (
                height: 220,
                width: 220,
                child: Image.asset('lib/images/atlas.png')),
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

                    //Email textfield
                    MyTextField(
                    controller: emailController,
                    hintText: 'Email',
                    obscureText: false,
                    ),

                    const SizedBox(height: 20),

                    //Reset password button
                    MyButton (
                      text: ('Reset Password'),
                      onTap: passwordReset,
                    ),

                    const SizedBox(height: 20),

                    //Back to Login page button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Back to Login: ',
                          style: TextStyle(color: Colors.black),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {
                            Navigator.of(context).pushNamed('/login');
                          },
                          child: const Text(
                            'Login Page',
                            style: TextStyle(
                                color: Color.fromARGB(255, 0, 60, 255),
                                fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}