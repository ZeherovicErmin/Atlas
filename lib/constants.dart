import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A file for frequently used widgets to clean up code

//Sign user out method
void signUserOut() async {
  await FirebaseAuth.instance.signOut();
}

// App Bar
AppBar myAppBar = AppBar(
    backgroundColor: const Color.fromARGB(255, 38, 97, 185),
    title: const Text(
      "Home",
      style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
    ),
    actions: const [
      IconButton(
        onPressed: signUserOut,
        icon: Icon(Icons.logout),
      )
    ]);

// Function to Create containers
Container myWidgCont(double width, double height, Color color) {
  return Container(
    margin: const EdgeInsets.all(8),
    width: width,
    height: height,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(10),
      color: color,
    ),
  );
}

// Creating A Drawer
var myDrawer = const Drawer(
    backgroundColor: Color.fromARGB(255, 169, 183, 255),
    child: Column(
      children: [
        DrawerHeader(child: Icon(Icons.fitness_center)),
      ],
    ));
