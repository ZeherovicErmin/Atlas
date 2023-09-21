import 'package:atlas/main.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:atlas/pages/home_page2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// A file for frequently used widgets to clean up code

// App Bar
AppBar myAppBar(BuildContext context, WidgetRef ref) {
  return AppBar(
      backgroundColor: const Color.fromARGB(255, 38, 97, 185),
      title: const Text(
        "Home",
        style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          onPressed: () async {
            await ref.read(signOutProvider);
            // After succesful logout redirect to logout page
            Navigator.of(context).pushReplacementNamed('/login');
          },
          icon: Icon(Icons.logout),
        )
      ]);
}

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

/* Creating a bottom navigation bar
class myBottomNavigationBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(selectedIndexProvider);

    // Creating the pages we will redirect to
    final List<Widget> pages = [
      HomePage(),
      HomePage2(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text('Atlas'),
      ),
      body: pages[selectedIndex.state],
      bottomNavigationBar: BottomNavigationBar(
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: "Profile",
            ),
          ],
          currentIndex: selectedIndex.state,
          selectedItemColor: Colors.blue,
          onTap: (index) {
            selectedIndex.state = index;
          }),
    );
  }
} */
