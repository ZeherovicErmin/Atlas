//Atlas Fitness App CSC 4996
import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/my_workouts.dart';
import 'package:atlas/pages/notes.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:carousel_slider/carousel_slider.dart';
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

class FitCenter2 extends ConsumerWidget {
  // A bool to prevent multiple clicks of a button
  const FitCenter2({Key? key}) : super(key: key);

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
      return []; // Returning an empty list in case there is an error
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        backgroundColor: const Color(0xFFFAF9F6),
        //Home page for when a user logs in
        appBar: AppBar(
            centerTitle: true,
            title: const Text(
              "Fitness Center",
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 0, 136, 204),
            leading: IconButton(
                icon: const Icon(CupertinoIcons.info_circle_fill),
                onPressed: () {
                  final isInfoDialogOpen = ref.read(infoDialogProvider);

                  if (!isInfoDialogOpen) {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Center(
                            child: Text(
                              'Fitness Center Guide',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          content: const SingleChildScrollView(
                            child: ListBody(
                              children: <Widget>[
                                Text(
                                  "Discover Page",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  "Find targeted exercises for each muscle, muscles are seperated into color categories. Tap on a muscle icon to view related exercises.",
                                  style: TextStyle(fontSize: 14),
                                ),
                                SizedBox(height: 10),
                                Text(
                                  "My Workouts",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "View the workout plans you've customized. Clicking each day will bring up your plan of exercises for that day!",
                                    style: TextStyle(fontSize: 14)),
                                SizedBox(height: 10),
                                Text(
                                  "Notes",
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                Text(
                                    "Jot down anything that comes to mind in the notes page!",
                                    style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                          // adding space between the entries

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
                }),
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
            actions: const []),

        body: TabBarView(
          children: [
            // The Discover Tab Of the workouts page

            // Listing each muscle that will dynamically show a list of exercises for the clicked workout on a different page
            musclesList(ref),

            const DiscoverPage(),

            NotesPage(),
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
                    color: const Color.fromARGB(255, 0, 136, 204),
                    size: 200,
                  );
                });

            final exercisesData = await getExercises(muscle);

            // Waiting 1 second
            await Future.delayed(const Duration(milliseconds: 750));

            // Dismiss the loading indicator
            Navigator.pop(context);

            if (exercisesData.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: const Color(0xFFFAF9F6),
                  appBar: AppBar(
                    centerTitle: true,
                    backgroundColor:
                        //Workouts for each muscle group
                        const Color.fromARGB(255, 0, 136, 204),
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

// The function that returns the carousel view of exercises based on the muscle that the user clicks
Widget exercisesList(List<dynamic> exercisesData, WidgetRef ref) {
  return Center(
    child: CarouselSlider(
      options: CarouselOptions(
        height: 650,
        aspectRatio: 16 / 9,
        enlargeCenterPage: true,
        scrollDirection: Axis.horizontal,
        autoPlay: false,
      ),
      items: exercisesData.map((exercise) {
        // Map of exercises to use
        final exerciseData = {
          'name': exercise['name'],
          'type': exercise['type'],
          'muscle': exercise['muscle'],
          'equipment': exercise['equipment'],
          'difficulty': exercise['difficulty'],
          'instructions': exercise['instructions'],
          'gif': 'lib/gifs/${exercise['name']}.gif',
        };
        return ExerciseCard(
          exercise: exerciseData,
          ref: ref,
        );
      }).toList(),
    ),
  );
}

Future<dynamic> showing(
    context, WidgetRef ref, Map<String, dynamic> exerciseData) {
  return showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
          title:
              const Text('What day would you like to save this exercise to?'),
          content: Consumer(
            builder: (context, ref, child) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(7, (day) {
                  // watching for the state of the provider to see if the specific day of the week is selected
                  final isSelected = ref.watch(selectedDaysProvider)[day];
                  return CheckboxListTile(
                    title: Text(getDayName(day)),
                    value: isSelected,

                    // Updating the state of whether or not its selected by modifying the state of the provider notifier
                    onChanged: (bool? value) {
                      ref.read(selectedDaysProvider.notifier).update((state) {
                        final newState = List<bool>.from(state);
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
                ref.read(selectedDaysProvider.notifier).state =
                    List.generate(7, (index) => false);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                final selectedDays = ref.read(selectedDaysProvider);
                // Iterating through each selected day to save it to the particular collection
                for (int i = 0; i < selectedDays.length; i++) {
                  if (selectedDays[i]) {
                    saveExerciseToFirestore(exerciseData, context, i);
                  }
                }

                // Resetting the checklist after saving
                ref.read(selectedDaysProvider.notifier).state =
                    List.generate(7, (index) => false);
                Navigator.of(context).pop();
              },
            ),
          ]);
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
void saveExerciseToFirestore(Map<String, dynamic> exerciseData,
    BuildContext context, int selectedDay) async {
  try {
    // Create an instance of FirebaseAuth
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Get the current user
    final User? user = auth.currentUser;

    if (user == null) {
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
        .where("exercise.name", isEqualTo: exerciseData["name"])
        .limit(1)
        .get();

    // Checking if context is still valid
    if (!Navigator.of(context).mounted) {
      return;
    }

    if (existingExerciseQuery.docs.isNotEmpty) {
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
          "exercise": exerciseData,
          "saveDate": DateTime.now(),
          "selectedDay": getDayName(selectedDay),
        },
      );

      // Save workout to FireStore
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Exercise saved to Firestore.'),
        ),
      );
    }
  } catch (e) {
    // if there is an error
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Error adding exercise to Firestore.'),
      ),
    );
  }
}

// Exercise Card class that will be utilized to provide a more modern carousel slider view for exercises utilizing the carousel slider flutter package

class ExerciseCard extends StatelessWidget {
  final dynamic exercise;
  final WidgetRef ref;

  const ExerciseCard({Key? key, required this.exercise, required this.ref})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrapping with a container to add flavor to the carousel
    return Container(
      // Set a fixed height and width or use MediaQuery to make it responsive
      height: 360,
      width: MediaQuery.of(context).size.width * 0.87,
      margin: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        // Adding a colored gradient border radius to the container of the carousel
        gradient: const LinearGradient(
          colors: [
            Colors.blue,
            Colors.red,
            Colors.green,
            Colors.purple
          ], // Adding colors for a rainbow border
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      // Adding a container to the actual carousel card so that a gradient can be added to the border
      child: Container(
        height: 350,
        margin: const EdgeInsets.all(
            1), // This creates an illusion of a border by overlaying the containers
        decoration: BoxDecoration(
          color: Colors.white, // White background for the actual card
          borderRadius: BorderRadius.circular(
              15), // Smaller radius than the styling container
        ),
        child: Column(
          children: [
            // Wrapping with gesture detector to allow for clicking the card to display exercise instructions
            GestureDetector(
              onTap: () => _showInstructionsModal(context, exercise),
              child: Container(
                margin: const EdgeInsets.all(10),
                child: Column(
                  children: [
                    // Displaying the exercise name at the very top
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Center(
                            child: AutoSizeText(
                              exercise['name'],
                              style: const TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.bold),
                              maxLines: 1,
                            ),
                          ),
                        ),
                      ],
                    ),

                    IconButton(
                      icon: const Icon(
                        CupertinoIcons.add,
                        color: Colors.blue,
                        size: 30,
                      ),
                      // Converting the original implemntation of day selection from the flippable card to carousel
                      onPressed: () => _showSavingDialog(context, exercise),
                    ),

                    const SizedBox(height: 60),

                    // Displaying the gif as the main focus
                    Image.asset(
                      exercise['gif'],
                      height: 275,
                      fit: BoxFit.fitHeight,
                    ),

                    const SizedBox(height: 50),

                    // Displaying the exercise diff, muscle, and equip
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text(exercise['difficulty'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.purple,
                            )),
                        Text(exercise['muscle'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.blue,
                            )),
                        Text(exercise['equipment'],
                            style: const TextStyle(
                              fontSize: 18,
                              color: Colors.green,
                            )),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Building a modal sheet similar to barcode implementation
  void _showInstructionsModal(BuildContext context, dynamic exercise) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              // Implemnting splitting the instructions by periods into new lines and utilizing the previous logic used for numbering the steps
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  // Max length - 1 to avoid another entry for the very last period
                  itemCount: exercise['instructions'].split('.').length - 1,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      // Iterating through the instruction string and splitting at each period
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
        );
      },
    );
  }

  // Function to allow saving on the new carousel view
  void _showSavingDialog(BuildContext context, dynamic exerciseData) {
    showing(context, ref, exerciseData);
  }
}
