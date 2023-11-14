import 'package:atlas/main.dart';
import 'package:atlas/pages/user_profile.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:developer';

// A file for frequently used widgets to clean up code

//App Bar for the homepage with the log out button
AppBar myAppBar(BuildContext context, WidgetRef ref, String title) {
  return AppBar(
      leading: const Icon(
        null,
      ),
      automaticallyImplyLeading: false,
      backgroundColor: Color.fromARGB(255, 0, 136, 204),
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
          icon: const Icon(Icons.logout),
        )
      ]);
}

//AppBar without the login button
AppBar myAppBar2(BuildContext context, WidgetRef ref, String title) {
  return AppBar(
    leading: const Icon(
      null,
    ),
    automaticallyImplyLeading: false,
    backgroundColor: Color.fromARGB(255, 0, 136, 204),
    title: Text(
      title,
      style:
          const TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
    ),
    actions: [
      IconButton(
        icon: const Icon(CupertinoIcons.profile_circled),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserProfile(),
            ),
          );
        },
      )
    ],
    centerTitle: true,
  );
}

AppBar myAppBar3(BuildContext context, String title) {
  return AppBar(
    leading: const Icon(
      null,
    ),
    automaticallyImplyLeading: false,
    backgroundColor: const Color.fromARGB(255, 0, 136, 204),
    title: Text(
      title,
      style:
          const TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
    ),
  );
}

//AppBar without the login button
AppBar myAppBar4(BuildContext context, WidgetRef ref, String title) {
  return AppBar(
    backgroundColor: Color.fromARGB(255, 0, 136, 204),
    title: Text(
      title,
      style:
          const TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
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

// Creating a list of target muscles
const List<String> list = <String>[
  "biceps",
  "forearms",
  "triceps",
  "abductors",
  "adductors",
  "calves",
  "quadriceps",
  "abdominals",
  "chest",
  "lats",
  "lower_back",
  "middle_back",
  "neck",
  "traps",
  "glutes",
  "hamstrings",
];
// Creating A map of Icons for each specific muscles
final Map<String, Widget> muscleIcons = {
  "biceps": Image.asset(
    'lib/images/bicepicon.png',
    height: 60,
    width: 60,
  ),
  "forearms": Image.asset(
    'lib/images/forearm.png',
    height: 60,
    width: 60,
  ),
  "triceps": Image.asset(
    'lib/images/triceps.png',
    height: 60,
    width: 60,
  ),
  "abdominals": Image.asset(
    'lib/images/abdominals.png',
    height: 60,
    width: 60,
  ),
  "calves": Image.asset(
    'lib/images/calves.png',
    height: 60,
    width: 60,
  ),
  "chest": Image.asset(
    'lib/images/chest.png',
    height: 60,
    width: 60,
  ),
  "neck": Image.asset(
    'lib/images/neck.png',
    height: 60,
    width: 60,
  ),
  "abductors": Image.asset(
    'lib/images/abductors.png',
    height: 60,
    width: 60,
  ),
  "adductors": Image.asset(
    'lib/images/adductors.png',
    height: 60,
    width: 60,
  ),
  "lower_back": Image.asset(
    'lib/images/lowerback.png',
    height: 60,
    width: 60,
  ),
  "middle_back": Image.asset(
    'lib/images/middleback.png',
    height: 60,
    width: 60,
  ),
  "lats": Image.asset(
    'lib/images/lats.png',
    height: 60,
    width: 60,
  ),
  "traps": Image.asset(
    'lib/images/traps.png',
    height: 60,
    width: 60,
  ),
  "quadriceps": Image.asset(
    'lib/images/quads.png',
    height: 60,
    width: 60,
  ),
  "hamstrings": Image.asset(
    'lib/images/hams.png',
    height: 60,
    width: 60,
  ),
  "glutes": Image.asset(
    'lib/images/glutes.png',
    height: 60,
    width: 60,
  ),
};
// Creating A map of icons for the exercise type i.e strength or cardio
final Map<String, IconData> exerciseTypeIcons = {
  "strength": Icons.fitness_center,
};
// Creating a map of colors to apply to each type of muscle
const Map<String, Color> muscleColors = {
  "abdominals": Color.fromARGB(255, 40, 84, 206),
  "abductors": Color.fromARGB(255, 25, 156, 127),
  "adductors": Color.fromARGB(255, 25, 156, 127),
  "biceps": Color.fromARGB(255, 63, 199, 202),
  "calves": Color.fromARGB(255, 25, 156, 127),
  "chest": Color.fromARGB(255, 131, 217, 131),
  "forearms": Color.fromARGB(255, 63, 199, 202),
  "glutes": Color.fromARGB(255, 112, 128, 144),
  "hamstrings": Color.fromARGB(255, 112, 128, 144),
  "lats": Color.fromARGB(255, 147, 112, 219),
  "lower_back": Color.fromARGB(255, 147, 112, 219),
  "middle_back": Color.fromARGB(255, 147, 112, 219),
  "neck": Color.fromARGB(255, 147, 112, 219),
  "quadriceps": Color.fromARGB(255, 25, 156, 127),
  "traps": Color.fromARGB(255, 147, 112, 219),
  "triceps": Color.fromARGB(255, 63, 199, 202),
};
