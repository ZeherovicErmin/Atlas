import 'package:atlas/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FitPage extends StatelessWidget {
  FitPage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        appBar: AppBar(title: Text("Fitness")),
        drawer: myDrawer,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myWidgCont(150, 175, Color.fromARGB(255, 224, 224, 224)),
                myWidgCont(150, 175, Color.fromARGB(255, 193, 167, 226)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myWidgCont(150, 175, Color.fromARGB(255, 193, 167, 226)),
                myWidgCont(150, 175, Color.fromARGB(255, 224, 224, 224)),
              ],
            )
          ],
        ));
  }
}
