import 'package:atlas/main.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

// A file for frequently used widgets to clean up code

// App Bar for the homepage
AppBar myAppBar(BuildContext context, WidgetRef ref, String title) {
  return AppBar(
      backgroundColor: Color.fromARGB(255, 90, 86, 86),
      title: Text(
        title,
        style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () async {
            
            
            await ref.read(signOutProvider);
            // After succesful logout redirect to logout page

            Navigator.of(context).pushReplacementNamed('/login');
            //attempt to reset profile picture state to null after logout
            ref.read(profilePictureProvider.notifier).state = null;
          },
          icon: Icon(Icons.logout),
        )
      ]);
}

// App Bar for the homepage
AppBar myAppBar2(BuildContext context, WidgetRef ref, String title) {
  return AppBar(
    backgroundColor: Color.fromARGB(255, 90, 86, 86),
    title: Text(
      title,
      style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
    ),
    centerTitle: true,
  );
}

// Function to Create containers
Container myWidgCont(double width, double height, Color color,
    IconData iconData, Color iconColor) {
  return Container(
      margin: const EdgeInsets.all(8),
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
      ),
      child: Center(
        child: Icon(iconData, size: 50, color: iconColor),
      ));
}

// Creating A Drawer
var myDrawer = const Drawer(
    backgroundColor: Color.fromARGB(255, 169, 183, 255),
    child: Column(
      children: [
        DrawerHeader(child: Icon(Icons.fitness_center)),
      ],
    ));

// A gradient for our application

var myGradient = LinearGradient(
  begin: Alignment.topCenter,
  end: Alignment.bottomCenter,
  colors: [
    Color.fromARGB(255, 90, 117, 255),
    Color.fromARGB(255, 161, 195, 250),
  ],
);
