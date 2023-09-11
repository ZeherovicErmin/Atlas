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
        

// Widget Container
var myWidgCont = Container(
                  margin: EdgeInsets.all(8.0),
                  width: 150,
                  height: 175,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: const Color.fromARGB(255, 224, 224, 224)),

                  );
                



