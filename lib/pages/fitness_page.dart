import 'package:atlas/constants.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FitPage extends StatefulWidget {
  FitPage({super.key});

  @override
  _FitPageState createState() => _FitPageState();
}

// Creating tabs to navigate to other pages with navbar
final tabs = [
  HomePage(),
  FitPage(),
];

class _FitPageState extends State<FitPage> {
  final user = FirebaseAuth.instance.currentUser!;
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 183, 255),
      appBar: myAppBar,
      drawer: myDrawer,
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
