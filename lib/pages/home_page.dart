import 'package:atlas/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

// The home page that all our users will be greeted with upon succesful login.

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //Home page for when a user logs in
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
              /*GestureDetector(
                onDoubleTap: () {
                  Navigator.pushNamed(context, '/fitpage');
                },*/
              myWidgCont(150, 175, const Color.fromARGB(255, 224, 224, 224)),
              myWidgCont(150, 175, const Color.fromARGB(255, 193, 167, 226)),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              myWidgCont(150, 175, const Color.fromARGB(255, 193, 167, 226)),
              myWidgCont(150, 175, const Color.fromARGB(255, 224, 224, 224)),
            ],
          )
        ],
      ),
    );
  }
}
