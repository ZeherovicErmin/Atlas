//Atlas Fitness App CSC 4996
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flip_card/flip_card.dart';

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

// Creating a method to capitalize the first letter of each muscle
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

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
  "quadriceps": Image.asset(
    'lib/images/quads.png',
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
  "abdominals": Color.fromARGB(255, 64, 224, 208),
  "abductors": Color.fromARGB(255, 255, 107, 76),
  "adductors": Color.fromARGB(255, 255, 107, 76),
  "biceps": Color.fromARGB(255, 255, 230, 128),
  "calves": Color.fromARGB(255, 255, 107, 76),
  "chest": Color.fromARGB(255, 152, 251, 152),
  "forearms": Color.fromARGB(255, 255, 230, 128),
  "glutes": Color.fromARGB(255, 112, 128, 144),
  "hamstrings": Color.fromARGB(255, 112, 128, 144),
  "lats": Color.fromARGB(255, 147, 112, 219),
  "lower_back": Color.fromARGB(255, 147, 112, 219),
  "middle_back": Color.fromARGB(255, 147, 112, 219),
  "neck": Color.fromARGB(255, 147, 112, 219),
  "quadriceps": Color.fromARGB(255, 255, 107, 76),
  "traps": Color.fromARGB(255, 147, 112, 219),
  "triceps": Color.fromARGB(255, 255, 230, 128)
};

// Creating a state provider to return a string for selected muscle
final selectedMuscleProvider = StateProvider<String>((ref) {
  String muscle = 'biceps';
  return muscle;
});

class FitCenter extends ConsumerWidget {
  const FitCenter({Key? key}) : super(key: key);

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
        initialIndex: 1,
        length: 2,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 232, 229, 229),
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
            backgroundColor: const Color.fromARGB(255, 0, 136, 204),
            bottom: const TabBar(
              indicatorColor: Color.fromARGB(255, 90, 86, 86),
              tabs: [
                Tab(
                  text: "Discover",
                ),
                Tab(text: "My Workouts"),
              ],
            ),
          ),

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
        final icon = muscleIcons[
            muscle]; // Initalize each entry of the list to the muscle
        return GestureDetector(
          onTap: () async {
            final exercisesData = await getExercises(muscle);

            if (exercisesData.isNotEmpty) {
              Navigator.of(context).push(MaterialPageRoute(
                builder: (context) => Scaffold(
                  backgroundColor: Color.fromARGB(255, 232, 229, 229),
                  appBar: AppBar(
                    backgroundColor:

                        //Workouts for each muscle group
                        const Color.fromARGB(255, 0, 136, 204),
                    title: Text("$muscle Exercises"),
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
                  Text(
                    capitalizeFirstLetter(muscle.replaceAll('_', ' ')),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      exercise['name'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 32,
                      ),
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
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Icon(
                          exerciseTypeIcon ?? Icons.category,
                          color: Colors.red,
                          size: 18,
                        ),
                        Icon(
                          exerciseTypeIcon ?? Icons.category,
                          color: Colors.blue,
                          size: 18,
                        ),
                        Icon(
                          exerciseTypeIcon ?? Icons.category,
                          color: Colors.green,
                          size: 18,
                        ),
                        Icon(
                          exerciseTypeIcon ?? Icons.category,
                          color: Colors.purple,
                          size: 18,
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            back: Card(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    exercise['instructions'],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
