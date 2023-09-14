import 'package:atlas/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  //Home page for when a user logs in
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        appBar: myAppBar,
        drawer: myDrawer,
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myWidgCont(150,175,Color.fromARGB(255,224,224,224)),
                myWidgCont(150,175,Color.fromARGB(255, 193, 167, 226)),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                myWidgCont(150,175,Color.fromARGB(255, 193, 167, 226)),
                myWidgCont(150,175,Color.fromARGB(255,224,224,224)),
              ],
            )
          ],
        ));
  }
}
