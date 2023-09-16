import 'package:atlas/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FitPage extends StatefulWidget {
  FitPage({super.key});

  @override
  _FitPageState createState() => _FitPageState();
}

class _FitPageState extends State<FitPage> {
  final user = FirebaseAuth.instance.currentUser!;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 183, 255),
      appBar: AppBar(title: Text("Fitness")),
      drawer: myDrawer,
    );
  }
}
