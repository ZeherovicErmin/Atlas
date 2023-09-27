import 'package:atlas/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cupertino_icons/cupertino_icons.dart';

// A file for frequently used widgets to clean up code

// App Bar
AppBar myAppBar(BuildContext context, WidgetRef ref, String title) {
  return AppBar(
      backgroundColor: const Color.fromARGB(255, 38, 97, 185),
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
          },
          icon: Icon(Icons.logout),
        )
      ]);
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
