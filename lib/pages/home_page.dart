import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final user = FirebaseAuth.instance.currentUser!;

  //Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }

  //Home page for when a user logs in
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: const Color.fromARGB(255, 169, 183, 255),
        appBar: AppBar(
          backgroundColor: const Color.fromARGB(255, 38, 97, 185),
          title: const Text(
            "Home",
            style:
                TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
          ),
          actions: [
            IconButton(
              onPressed: signUserOut,
              icon: const Icon(Icons.logout),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.all(8.0),
                  width: 150,
                  height: 175,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 224, 224, 224)),
                  child: Text(
                    'Steps ',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18.0,
                      fontFamily: 'San Francisco',
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                Container(
                    margin: EdgeInsets.all(8.0),
                    width: 150,
                    height: 175,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 193, 167, 226))),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                    margin: EdgeInsets.all(8.0),
                    width: 150,
                    height: 175,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 193, 167, 226))),
                Container(
                    margin: EdgeInsets.all(8.0),
                    width: 150,
                    height: 175,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: const Color.fromARGB(255, 224, 224, 224))),
              ],
            )
          ],
        ));
  }
}
