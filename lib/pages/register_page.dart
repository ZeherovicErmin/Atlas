import 'package:atlas/components/my_button.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/main.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:atlas/components/password_textfield.dart';

// Creating the necessary Registration States and text controllers
class RegistrationState {
  final auth = FirebaseAuth.instance;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  // Riverpod Provider
  final profilePictureProvider = StateProvider<Uint8List?>((ref) => null);
  // Variable for initial profile image data
  final Uint8List initialProfileImageData =
      Uint8List.fromList(List<int>.generate(1024, (index) => index % 256));
  RegistrationState();
}

RegistrationState registrationState = RegistrationState();

// Class to attempt to register a user
class RegisterPage extends ConsumerWidget {
  const RegisterPage({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Obtain the registration provider state
    final registrationState = ref.watch(registrationProvider);

    //Error message function for displaying an error message to the user
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

    //Makes the collection for storing user habits
    void makeHabitCollection() async {
      var currentDate = DateTime.now();
      var formattedDate = "${currentDate.month}/${currentDate.day}";
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user?.uid;

      await FirebaseFirestore.instance
          .collection("Habits")
          .doc(uid)
          .collection(formattedDate)
          .add({
            'uid': uid,
      });
    }

    //Makes the collection for storing user habits
    void makeUsernameCollection() async {
      final FirebaseAuth auth = FirebaseAuth.instance;
      final User? user = auth.currentUser;
      final uid = user?.uid;

      if (uid != null) {
        await FirebaseFirestore.instance.collection("Users2").doc(uid).set({
          'username': registrationState.emailController.text,
        });
      }
    }

    //Attempts to sign the user up for Atlas
    void signUserUp() async {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(child: CircularProgressIndicator());
        },
      );

      //Checks that the passwords match when confirming a password
      if (registrationState.passwordController.text !=
          registrationState.confirmPasswordController.text) {
        Navigator.pop(context);
        showErrorMessage('Passwords do not match');
        return;
      }

      //Attempts to create an account for a user with their email address and password
      try {
        UserCredential userCredential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: registrationState.emailController.text,
          password: registrationState.passwordController.text,
        );
        final User? user2 = userCredential.user;
        if (user2 != null && !user2.emailVerified) {
          await user2.sendEmailVerification();
        }
        final FirebaseAuth auth = FirebaseAuth.instance;
        final User? user = auth.currentUser;
        final uid = user?.uid;
        //Uploads a collection containing all user's email addresses when they register with Atlas
        await FirebaseFirestore.instance
            .collection("Users")
            .doc(userCredential.user!.email)
            .set({
          'username': registrationState.emailController.text
            .split('@')[0], // initial username
          'bio': 'Empty Bio...', // initially empty bio
          'profilePicture':
            registrationState.initialProfileImageData, // profile pic
        });
        makeHabitCollection();
        makeUsernameCollection();

        //Error handling for registering for Atlas
        Navigator.of(context); // Closes the loading circle
        Navigator.of(context).pushReplacementNamed('/start');
      } on FirebaseAuthException catch (e) {
        Navigator.pop(context);
        if (e.code == 'email-already-in-use') {
          showErrorMessage('An account already exists for that email');
        } else if (e.code == 'weak-password') {
          showErrorMessage('Password is too weak');
        } else {
          showErrorMessage('The email address is badly formatted');
        }
      }
    }

    //Builds the page
    return Scaffold(
      backgroundColor: Color.fromARGB(255, 232, 229, 229),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // White space above logo
                const SizedBox(height: 5),

                // Logo
                SizedBox(
                  height: 220,
                  width: 220,
                  child: Image.asset('lib/images/atlas.png'),
                ),

                const SizedBox(height: 10),

                // Username textfield
                MyTextField(
                  controller: registrationState.emailController,
                  hintText: 'Email',
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                //Password textfield
                PasswordTextField(
                  controller: registrationState.passwordController,
                  hintText: 'Password',
                  obscureText: true,
                  registrationState: registrationState,
                  passwordTextField: true,
                ),

                const SizedBox(height: 10),

                //Confirm Password textfield
                PasswordTextField(
                  controller: registrationState.confirmPasswordController,
                  hintText: 'Confirm Password',
                  obscureText: true,
                  registrationState: registrationState,
                  passwordTextField: false,
                ),

                const SizedBox(height: 25),

                //Sign-in button
                MyButton(
                  text: 'Sign Up',
                  onTap: signUserUp,
                ),

                const SizedBox(height: 10),

                // Register now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
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
                          fontWeight: FontWeight.bold,
                        ),
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
