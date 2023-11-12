//Atlas Fitness App CSC 4996
import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/my_workouts.dart';
import 'package:atlas/pages/notes.dart';
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
import 'package:loading_animation_widget/loading_animation_widget.dart';

// Creating a global variable to store the selected day
int selectedDay = 1;

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

// A variable to track selected days
final selectedDaysProvider =
    StateProvider<List<bool>>((ref) => List.generate(7, (index) => false));

class SavedExercisesNotifier extends Notifier<List<String>> {
  SavedExercisesNotifier() : super();

  @override
  List<String> build() {
    return state;
  }
}

// Adding an info button
final infoDialogProvider = StateProvider<bool>((ref) => false);

// Creating a loading provider
final loadingProvider = StateProvider<bool>((ref) => false);

class FitCenter extends ConsumerWidget {
  // A bool to prevent multiple clicks of a button
  const FitCenter({Key? key}) : super(key: key);

  //for saving to database
  final bool saved = false;
  Future<List<dynamic>> getExercises(String muscle) async {
    // The Api key from API NINJAS
    const String myApiKey =
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
            leading: const Icon(
              null,
            ),
            centerTitle: true,
              title: const Text(
                  "Fitness Center",
                  style: TextStyle(
                    fontFamily: 'Open Sans',
                    fontWeight: FontWeight.bold,
                  ),
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 0, 136, 204),
            bottom: const TabBar(
              indicatorColor: Color.fromARGB(255, 90, 86, 86),
              tabs: [
                Tab(
                  text: "Discover",
                ),
                Tab(text: "My Workouts"),
                Tab(
                  text: "Notes",
                )
              ],
            ),
            actions: [
              // Creating a button that will display information on how to use the page to the user
              IconButton(
                  icon: const Icon(CupertinoIcons.info_circle_fill),
                  onPressed: () {
                    final isInfoDialogOpen = ref.read(infoDialogProvider);

                    if (!isInfoDialogOpen) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Center(
                                child: Text('Discover Page Guide')),
                            content: const Text(
                                "Displayed is a list of muscles with icons depicting the muscle.\n"
                                "To find exercises for a muscle, tap on one of the muscles to view a list of exercises.\n"
                                "The muscles are color coded by general muscle group they belong to.\n"),
                            actions: <Widget>[
                              TextButton(
                                child: const Text('Close'),
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
            musclesList(ref),

            const DiscoverPage(),

            const NotesPage(),
          ],
        ),
      ),
    );
  }

  // the list of clickable muscles
  Widget musclesList(WidgetRef ref) {
    return ListView.builder(
      itemCount: list.length,
      itemBuilder: (context, index) {
        final muscle = list[index];
        final muscleColor = muscleColors[muscle];

        // Initalize each entry of the list to the muscle
        return GestureDetector(
          onTap: () async {
            // Loading indicator
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return LoadingAnimationWidget.inkDrop(
                    color: Color.fromARGB(255, 0, 136, 204),
                    size: 200,
                  );
                });

            final exercisesData = await getExercises(muscle);

            // Waiting 1 second
            await Future.delayed(Duration(milliseconds: 750));

            // Dismiss the loading indicator
            Navigator.pop(context);

            if (exercisesData.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: const Color(0xFFFAF9F6),
                  appBar: AppBar(
                  centerTitle: true,
                  backgroundColor:const Color.fromARGB(255, 0, 136, 204),
                    title: Text(
                      "${capitalizeFirstLetter(muscle)} Exercises",
                    ),
                  ),
                  body: exercisesList(exercisesData, ref),
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
                  offset: const Offset(0, 2),
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
                      const Icon(Icons.fitness_center,
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
}

// The function that returns the list view of exercises based on the muscle that the user classes
ListView exercisesList(List<dynamic> exercisesData, WidgetRef ref) {
  return ListView.builder(
    itemCount: exercisesData.length,
    itemBuilder: (context, index) {
      final exercise = exercisesData[index];

      // Map of exercises to be saved in firestore
      final exerciseData = {
        'name': exercise['name'],
        'type': exercise['type'],
        'muscle': exercise['muscle'],
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
                        // Display a pop up to see what days the user would like to save the exercise too

                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                                title: const Text(
                                    'What day would you like to save this exercise to?'),
                                content: Consumer(
                                  builder: (context, ref, child) {
                                    return Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: List.generate(7, (day) {
                                        // watching for the state of the provider to see if the specific day of the week is selected
                                        final isSelected = ref
                                            .watch(selectedDaysProvider)[day];
                                        return CheckboxListTile(
                                          title: Text(getDayName(day)),
                                          value: isSelected,

                                          // Updating the state of whether or not its selected by modifying the state of the provider notifier
                                          onChanged: (bool? value) {
                                            ref
                                                .read(selectedDaysProvider
                                                    .notifier)
                                                .update((state) {
                                              final newState =
                                                  List<bool>.from(state);
                                              newState[day] = value!;
                                              return newState;
                                            });
                                          },
                                        );
                                      }),
                                    );
                                  },
                                ),
                                // Adding the buttons to save / cancel
                                actions: [
                                  // Adding a button to cancel
                                  TextButton(
                                    child: const Text('Cancel'),
                                    onPressed: () {
                                      // Clearing the checklist
                                      ref
                                              .read(selectedDaysProvider.notifier)
                                              .state =
                                          List.generate(7, (index) => false);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                  TextButton(
                                    child: const Text('Save'),
                                    onPressed: () {
                                      final selectedDays =
                                          ref.read(selectedDaysProvider);
                                      // Iterating through each selected day to save it to the particular collection
                                      for (int i = 0;
                                          i < selectedDays.length;
                                          i++) {
                                        if (selectedDays[i]) {
                                          saveExerciseToFirestore(
                                              exerciseData, context, i);
                                        }
                                      }

                                      // Resetting the checklist after saving
                                      ref
                                              .read(selectedDaysProvider.notifier)
                                              .state =
                                          List.generate(7, (index) => false);
                                      Navigator.of(context).pop();
                                    },
                                  ),
                                ]);
                          },
                        );
                      },
                      icon: const Icon(
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
                    // Returning a numbered list for the instructions of the workout
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: exercise['instructions'].split('.').length - 1,
                      itemBuilder: (BuildContext context, int index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Text(
                            '${index + 1}. ${exercise['instructions'].split('.')[index]}',
                            style: const TextStyle(fontSize: 18),
                          ),
                        );
                      },
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

String getDayName(int day) {
  switch (day) {
    case 0:
      return "Sunday";
    case 1:
      return "Monday";
    case 2:
      return "Tuesday";
    case 3:
      return "Wednesday";
    case 4:
      return "Thursday";
    case 5:
      return "Friday";
    case 6:
      return "Saturday";
    default:
      throw ArgumentError("Invalid day: $day");
  }
}

//save exercise
void saveExerciseToFirestore(Map<String, dynamic> exercisesData,
    BuildContext context, int selectedDay) async {
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

    // Creating a name for the FIrestore collection based on the day the user selects
    final collectionName = getDayName(selectedDay) + "_exercises";

    // Make a reference to the Exercises collection in Firebase based on the day selected
    final exerciseCollection =
        FirebaseFirestore.instance.collection(collectionName);

    // Check if the exercise with the same name is already saved by the user
    final existingExerciseQuery = await exerciseCollection
        .where("uid", isEqualTo: userID)
        .where("exercise.name", isEqualTo: exercisesData["name"])
        .limit(1)
        .get();

    // Checking if context is still valid
    if (!Navigator.of(context).mounted) {
      return;
    }

    if (existingExerciseQuery.docs.isNotEmpty) {
      print('Exercise already saved.');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise already saved.'),
        ),
      );
    } else {
      // If the exercise is not already saved, add it to the Exercises collection
      await exerciseCollection.add(
        {
          "uid": userID,
          "exercise": exercisesData,
          "saveDate": DateTime.now(),
          "selectedDay": getDayName(selectedDay),
        },
      );

      print('Exercise saved to Firestore.');
      // Save workout to FireStore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise saved to Firestore.'),
        ),
      );
    }
  } catch (e) {
    print('Error adding exercise to Firestore: $e');
    // if there is an error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error adding exercise to Firestore.'),
      ),
    );
  }
}
