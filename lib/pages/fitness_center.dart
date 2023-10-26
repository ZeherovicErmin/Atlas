//Atlas Fitness App CSC 4996
import 'package:atlas/pages/constants.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flip_card/flip_card.dart';
import 'package:stroke_text/stroke_text.dart';

//final SavedExercisesProvider = NotifierProvider<SavedExercisesNotifier,List<String>>((ref) => null);

// Creating a method to capitalize the first letter of each muscle
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

// Creating a state provider to return a string for selected muscle
final selectedMuscleProvider = StateProvider<String>((ref) {
  String muscle = 'biceps';
  return muscle;
});

class SavedExercisesNotifier extends Notifier<List<String>> {
  SavedExercisesNotifier() : super();

  @override
  List<String> build() {
    return state;
  }

  void toggleExercise(String exerciseName) {
    if (state.contains(exerciseName)) {
      state = [...state]..remove(exerciseName);
    } else {
      state = [...state, exerciseName];
    }
  }
}

// Adding an info button
final infoDialogProvider = StateProvider<bool>((ref) => false);

class FitCenter extends ConsumerWidget {
  // A bool to prevent multiple clicks of a button
  const FitCenter({Key? key}) : super(key: key);

  //for saving to database
  final bool saved = false;
  Future<List<dynamic>> getExercises(String muscle) async {
    // The Api key from API NINJAS
    final String myApiKey =
        'q48XgvLytBmNhVJHFzoZgg==QWOhrECybUKjiRR8'; // Need to hide

    // THe url to Api ninjas site, the $muscle will be provided from the muscle variable
    final apiUrl = 'https://api.api-ninjas.com/v1/exercises?muscle=$muscle';

    // waiting for a response from the api
    final response =
        await http.get(Uri.parse(apiUrl), headers: {'X-Api-Key': myApiKey});

    // if statement to catch errors
    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      print("Error: ${response.statusCode} ${response.body}");
      return []; // Returning an empty list in case there is an error
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Setting the muscle variable to watch whatever the user selects in the drop down
    var muscle = ref.watch(selectedMuscleProvider);

    return Container(
      child: DefaultTabController(
        initialIndex: 0,
        length: 2,
        child: Scaffold(
          backgroundColor: const Color(0xFFFAF9F6),
          //Home page for when a user logs in
          appBar: AppBar(
              title: const Center(
                child: Text(
                  "F i t n e s s   C e n t e r",
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              backgroundColor: Color.fromARGB(255, 0, 136, 204),
              bottom: const TabBar(
                indicatorColor: Color.fromARGB(255, 90, 86, 86),
                tabs: [
                  Tab(
                    text: "Discover",
                  ),
                  Tab(text: "My Workouts"),
                ],
              ),
              actions: [
                IconButton(
                    icon: Icon(Icons.info),
                    onPressed: () {
                      final isInfoDialogOpen = ref.read(infoDialogProvider);

                      if (!isInfoDialogOpen) {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Center(child: Text('Discover Page Guide')),
                              content: Text(
                                  "Displayed is a list of muscles with icons depicting the muscle.\n"
                                  "To find exercises for a muscle, tap on one of the muscles to view a list of exercises.\n"
                                  "The muscles are color coded by general muscle group they belong to.\n"),
                              actions: <Widget>[
                                TextButton(
                                  child: Text('Close'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                ),
                              ],
                            );
                          },
                        );
                      }
                    })
              ]),

          body: TabBarView(
            children: [
              // The Discover Tab Of the workouts page

              // Listing each muscle that will dynamically show a list of exercises for the clicked workout on a different page
              musclesList(),

              Container(
                color: const Color.fromARGB(255, 232, 229, 229),
                child: Center(
                  child: Text(muscle),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  ListView musclesList() {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final muscle = list[index];
        final muscleColor = muscleColors[muscle];
        final icon = muscleIcons[muscle];

        // Initalize each entry of the list to the muscle
        return GestureDetector(
          onTap: () async {
            final exercisesData = await getExercises(muscle);

            if (exercisesData.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Color(0xFFFAF9F6),
                  appBar: AppBar(
                    backgroundColor:

                        //Workouts for each muscle group
                        const Color.fromARGB(255, 0, 136, 204),
                    title: Text(
                      "${capitalizeFirstLetter(muscle)} Exercises",
                    ),
                  ),
                  body: exercisesList(exercisesData),
                ),
              ));
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text("No Workout Data is Available for $muscle."),
                ),
              );
            }
          },

          // Styling elements for each specific muscle
          child: Container(
            decoration: BoxDecoration(
              color: muscleColor,
              borderRadius: BorderRadius.circular(24.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 4,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Adding an icon to each specific muscle
                  muscleIcons[muscle] ??
                      Icon(Icons.fitness_center,
                          size:
                              34), // Setting the default Icon if one does not exist
                  StrokeText(
                    text: capitalizeFirstLetter(muscle.replaceAll('_', ' ')),
                    textStyle: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    strokeColor: Colors.black12,
                  ),
                  const Icon(Icons.arrow_forward_ios,
                      size: 34, color: Colors.white),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  ListView exercisesList(List<dynamic> exercisesData) {
    return ListView.builder(
      itemCount: exercisesData.length,
      itemBuilder: (context, index) {
        final exercise = exercisesData[index];
        final exerciseType = exercise['type'];

        // Finding the icon for each exercise type
        final exerciseTypeIcon = exerciseTypeIcons[exerciseType];

        // Map of exercises to be saved in firestore
        final exerciseData = {
          'name': exercise['name'],
          'type': exercise['type'],
          'equipment': exercise['equipment'],
          'difficulty': exercise['difficulty'],
          'instructions': exercise['instructions'],
        };

        return Container(
          margin: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0), // Add a border radius
            border: Border.all(
              width: .5,
              style: BorderStyle.solid,
              color: Colors.transparent,
              // Set the border color and width
            ),
          ),
          child: FlipCard(
            fill: Fill.fillBack,
            direction: FlipDirection.VERTICAL,
            speed: 400,
            front: Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: SizedBox(
                width: double.infinity,
                height: 150.0,
                child: Stack(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        AutoSizeText(
                          exercise['name'],
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 32,
                          ),
                          maxLines: 1,
                          minFontSize: 20,
                          overflow: TextOverflow.clip,
                        ),
                        const SizedBox(height: 8.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              exercise['type'],
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              exercise['muscle'],
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              exercise['equipment'],
                              style: const TextStyle(
                                color: Colors.green,
                                fontSize: 18,
                              ),
                            ),
                            Text(
                              exercise['difficulty'],
                              style: const TextStyle(
                                color: Colors.purple,
                                fontSize: 18,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    //Plus icon that saves to database
                    Positioned(
                      top: 0.0,
                      right: 0.0,
                      child: //Save To FireStore button
                          IconButton(
                        onPressed: () {
                          // Display a pop up first to ask if the user would like to save the workout

                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: Text('Save Exercise?'),
                                content:
                                    Text('Do you want to save this execise?'),
                                actions: <Widget>[
                                  TextButton(
                                    child: Text('Cancel'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: Text('Save'),
                                    onPressed: () {
                                      // This command saves to the Firestore
                                      saveExerciseToFirestore(
                                          exerciseData, context);
                                    },
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        icon: Icon(
                          CupertinoIcons.add_circled,
                          size: 30,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            back: Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var sentence in exercise['instructions'].split('.'))
                        Text(
                          '\u2022 $sentence',
                          style: const TextStyle(fontSize: 18),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

//save exercise
  void saveExerciseToFirestore(
      Map<String, dynamic> exercisesData, BuildContext context) async {
    try {
      // Create an instance of FirebaseAuth
      final FirebaseAuth auth = FirebaseAuth.instance;

      // Get the current user
      final User? user = auth.currentUser;

      if (user == null) {
        print('User not logged in.');
        return;
      }

      // Get the current user's UID
      final userID = user.uid;

      // Make a reference to the Exercises collection in Firebase
      final exerciseCollection =
          FirebaseFirestore.instance.collection("Exercises");

      // Check if the exercise with the same name is already saved by the user
      final existingExerciseQuery = await exerciseCollection
          .where("uid", isEqualTo: userID)
          .where("exercise.name", isEqualTo: exercisesData["name"])
          .limit(1)
          .get();

      if (existingExerciseQuery.docs.isNotEmpty) {
        print('Exercise already saved.');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Exercise already saved.'),
          ),
        );
        Navigator.of(context).pop();
        return;
      }

      // If the exercise is not already saved, add it to the Exercises collection
      await exerciseCollection.add(
        {
          "uid": userID,
          "exercise": exercisesData,
          "saveDate": DateTime.now(),
        },
      );

      print('Exercise saved to Firestore.');
      // Save workout to FireStore
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercise saved to Firestore.'),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      print('Error adding exercise to Firestore: $e');
      // if there is an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding exercise to Firestore.'),
        ),
      );
    }
  }
}
