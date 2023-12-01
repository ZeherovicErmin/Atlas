//Author: Matthew McGowan
import 'package:atlas/components/my_button2.dart';
import 'package:atlas/components/my_textfield.dart';
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangePassword extends ConsumerWidget {
  const ChangePassword({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();

  //Success Message popup
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

  //Error message popup
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

  //Checks the user's current password
  Future<bool> getCurrentPassword(String password) async {
    var user = FirebaseAuth.instance.currentUser;
    var authLogin = EmailAuthProvider.credential(
      email: user!.email!,
      password: password
    );
    try {
      var firebasePassword = await user.reauthenticateWithCredential(authLogin);
      return firebasePassword.user != null;
    } catch (e) {
      return false;
    }
  }

  //Change password functionality
  void changePassword() async {
    if (!await getCurrentPassword(currentPasswordController.text)) {
      showErrorMessage('Current password is incorrect');
      return;
    }
    if (newPasswordController.text == confirmPasswordController.text && newPasswordController.text.isNotEmpty) {
      try {
        await FirebaseAuth.instance.currentUser?.updatePassword(newPasswordController.text);
        showSuccessMessage('Your password has been changed');
      } on FirebaseAuthException catch (e) {
        showErrorMessage(e.message ?? 'An error occurred');
      }
    }
    else {
      showErrorMessage('Passwords do not match');
    }
  }

  return Scaffold(
    appBar: myAppBar4(context, ref, 'Change Password'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //Current Password Textfield
            MyTextField(
              controller: currentPasswordController,
              hintText: 'Enter your current password',
              obscureText: true,
            ),

            const SizedBox(height: 10),

            //New Password Textfield
            MyTextField(
              controller: newPasswordController,
              hintText: 'Enter your new password',
              obscureText: true
            ),

            const SizedBox(height: 10),

            //Confirm Password Textfield
            MyTextField(
              controller: confirmPasswordController,
              hintText: 'Confirm your new password',
              obscureText: true
            ),

            const SizedBox(height: 15),

            //Change Password Button
            Center(
              child: MyButtonTwo(
                onPressed: changePassword,
                text: 'Change Password'
              ),
            ),
          ],
        ),
      ),
    );
  }
}
