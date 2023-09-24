import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:atlas/components/database_manager.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
      appBar: AppBar(actions: [
        IconButton(onPressed: signUserOut,
        icon: const Icon(Icons.logout),
            )
          ],
        ),
      body: Center(
        child: Text(
          "Logged in as ${user.email!}!",
          style: const TextStyle(fontSize: 20)
          )
        ),
    );

  }
}