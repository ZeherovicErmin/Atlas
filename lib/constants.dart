import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

// A file for frequently used widgets to clean up code

//Sign user out method
  void signUserOut() {
    FirebaseAuth.instance.signOut();
  }
  
// App Bar
var myAppBar = AppBar(
          backgroundColor: const Color.fromARGB(255, 38, 97, 185),
          title: const Text(
            "Home",
            style:
                TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
          ),
          actions: const [
            IconButton(
              onPressed: signUserOut,
              icon: Icon(Icons.logout),
            )
          ]);
        

              
// Function to Create containers
Container myWidgCont(double width, double height, Color color){
  return Container(
    margin: EdgeInsets.all(8),
    width: width,
    height: height,

    decoration: BoxDecoration(
      borderRadius : BorderRadius.circular(10),
      color: color,
    ),
  );
}
                



