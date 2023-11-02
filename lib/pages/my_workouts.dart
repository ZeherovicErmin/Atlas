import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'saved_workouts.dart';

// The My Workouts tab which will hold users saved exercises in a digestible workout format

class DiscoverPage extends ConsumerWidget {
  const DiscoverPage({Key? key}) : super(key: key);

  // Creating a list of COntainers for the days of the week
  static const List<String> items = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday"
  ];

// Creating a map of colors to apply to each day
  static const Map<String, Color> dayContColors = {
    "Monday": Color.fromARGB(255, 63, 199, 202),
    "Tuesday": Color.fromARGB(255, 255, 107, 76),
    "Wednesday": Color.fromARGB(255, 131, 217, 131),
    "Thursday": Color.fromARGB(255, 112, 128, 144),
    "Friday": Color.fromARGB(255, 147, 112, 219),
    "Saturday": Color.fromARGB(255, 63, 199, 202),
    "Sunday": Color.fromARGB(255, 202, 63, 160),
  };

  // Creating A map of Icons for each specific day
  static const Map<String, Widget> dayIcons = {
    "Monday": Image(
      image: AssetImage(
        'lib/images/monday_icon.png',
      ),
      height: 50,
      width: 50,
    ),
    "Tuesday": Image(
      image: AssetImage(
        'lib/images/monday_icon.png',
      ),
      height: 50,
      width: 50,
    ),
    "Wednesday": Image(
      image: AssetImage(
        'lib/images/monday_icon.png',
      ),
      height: 50,
      width: 50,
    ),
    "Thursday": Image(
      image: AssetImage(
        'lib/images/monday_icon.png',
      ),
      height: 50,
      width: 50,
    ),
    "Friday": Image(
      image: AssetImage(
        'lib/images/monday_icon.png',
      ),
      height: 50,
      width: 50,
    ),
    "Saturday": Image(
      image: AssetImage(
        'lib/images/monday_icon.png',
      ),
      height: 50,
      width: 50,
    ),
    "Sunday": Image(
      image: AssetImage(
        'lib/images/monday_icon.png',
      ),
      height: 50,
      width: 50,
    ),
  };
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using gesture detector to navigate to each specific day of the week page which will house the saved collection of exercises for each day

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: ListView.builder(
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          final dayColors = dayContColors[item];
          final dayIcon = dayIcons[item];

          //Creating the gesture detector functionality for each page to navigate to another page
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    switch (item) {
                      case "Monday":
                        return MondaySavedExercises();
                      case "Tuesday":
                        return TuesdaySavedExercises();
                      case "Wednesday":
                        return WednesdaySavedExercises();
                      case "Thursday":
                        return ThursdaySavedExercises();
                      case "Friday":
                        return FridaySavedExercises();
                      case "Saturday":
                        return SaturdaySavedExercises();
                      case "Sunday":
                        return SundaySavedExercises();

                      default:
                        return Scaffold(
                          body: Center(
                            child: Text("Page not found."),
                          ),
                        );
                    }
                  },
                ),
              );
            },
            child: Container(
              decoration: BoxDecoration(
                color: dayColors,
                borderRadius: BorderRadius.circular(24.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              margin:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Adding an icon to each specific Day
                    dayIcon ?? Icon(Icons.fitness_center),

                    Text(
                      item,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 34,
                          fontWeight: FontWeight.bold),
                    ),

                    // Adding the icon to indicate the container is clickable
                    Icon(Icons.arrow_forward_ios,
                        size: 40, color: Colors.white),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

// Creating a class for Monday that will display the Monday saved workouts and be used as a baseline for other days of the week
class MondaySavedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Monday Workout"),
      ),
      body: SavedExercises(collectionName: "Monday_exercises"),
    );
  }
}

// Tuesday Exercises
class TuesdaySavedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tuesday Workout"),
      ),
      body: SavedExercises(collectionName: "Tuesday_exercises"),
    );
  }
}

// Wednesday - Sunday below, same format as previous two
class WednesdaySavedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Wednesday Workout"),
      ),
      body: SavedExercises(collectionName: "Wednesday_exercises"),
    );
  }
}

class ThursdaySavedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Thursday Workout"),
      ),
      body: SavedExercises(collectionName: "Thursday_exercises"),
    );
  }
}

class FridaySavedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Friday Workout"),
      ),
      body: SavedExercises(collectionName: "Friday_exercises"),
    );
  }
}

class SaturdaySavedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saturday Workout"),
      ),
      body: SavedExercises(collectionName: "Saturday_exercises"),
    );
  }
}

class SundaySavedExercises extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Sunday Workout"),
      ),
      body: SavedExercises(collectionName: "Sunday_exercises"),
    );
  }
}
