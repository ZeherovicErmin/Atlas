import 'package:atlas/constants.dart';
import 'package:atlas/pages/fitness_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final user = FirebaseAuth.instance.currentUser!;

  int _currentIndex = 0;

  // Creating tabs to navigate to other pages with navbar
  final tabs = [
    HomePage(),
    FitPage(),
  ];

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
              GestureDetector(
                onDoubleTap: () {
                  Navigator.pushNamed(context, '/fitpage');
                },
                child: myWidgCont(150, 175, Color.fromARGB(255, 224, 224, 224)),
              ),
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
      ),
      bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          type: BottomNavigationBarType.fixed,
          backgroundColor: const Color.fromARGB(255, 38, 97, 185),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Using Navigator to put a selected page onto the stack
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => tabs[index]),
            );
          }),
    );
  }
}
