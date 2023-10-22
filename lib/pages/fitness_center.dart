//Atlas Fitness App CSC 4996
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flip_card/flip_card.dart';

// Creating a list of target muscles
const List<String> list = <String>[
  "abdominals",
  "abductors",
  "adductors",
  "biceps",
  "calves",
  "chest",
  "forearms",
  "glutes",
  "hamstrings",
  "lats",
  "lower_back",
  "middle_back",
  "neck",
  "quadriceps",
  "traps",
  "triceps",
];

// Creating a method to capitalize the first letter of each muscle
String capitalizeFirstLetter(String text) {
  if (text.isEmpty) return text;
  return text[0].toUpperCase() + text.substring(1);
}

// Creating A map of Icons for each specific muscles
final Map<String, IconData> muscleIcons = {
  "abdominals": Icons.star,
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
    final String myApiKey = 'q48XgvLytBmNhVJHFzoZgg==QWOhrECybUKjiRR8';

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

    // Container for the gradient of the application
    return Container(
      child: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          backgroundColor: const Color.fromARGB(255, 232, 229, 229),
          //Home page for when a user logs in
          appBar: AppBar(
            title: const Center(
              child: Text(
                "F i t n e s s C e n t e r",
                style: TextStyle(
                    fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: const Color.fromARGB(255, 90, 86, 86),
            bottom: const TabBar(
              indicatorColor: Color.fromARGB(255, 90, 86, 86),
              tabs: [
                Tab(
                  text: "Discover",
                ),
                Tab(text: "My Workouts"),
                Tab(text: "Progress"),
              ],
            ),
          ),

          body: TabBarView(
            children: [
              // The Discover Tab Of the workouts page

              // Listing each muscle that will dynamically show a list of exercises for the clicked workout on a different page
              ListView.builder(
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final muscle = list[index];
                  final icon = muscleIcons[
                      muscle]; // Initalize each entry of the list to the muscle
                  return InkWell(
                    onTap: () async {
                      final exercisesData = await getExercises(muscle);

                      if (exercisesData.isNotEmpty) {
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Scaffold(
                            appBar: AppBar(
                              backgroundColor:
                                  const Color.fromARGB(255, 90, 86, 86),
                              title: Text("Workouts for $muscle"),
                            ),
                            body: ListView.builder(
                              itemCount: exercisesData.length,
                              itemBuilder: (context, index) {
                                final exercise = exercisesData[index];
                                return Container(
                                  margin: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [Colors.blue, Colors.green],
                                    ),
                                    borderRadius: BorderRadius.circular(12.0),
                                  ),

                                  /* The API will return the exercise data which will be stylized with the FlipCard widget to display Exercise name and parameters
                                    while on the back it will present instructions for the workout.
                                  */

                                  // The Following widget tree stylizes the container and elements of the flippable card
                                  child: FlipCard(
                                    fill: Fill.fillBack,
                                    direction: FlipDirection.VERTICAL,
                                    speed: 400,
                                    front: Card(
                                      elevation: 4.0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                      child: SizedBox(
                                        width: double.infinity,
                                        height: 150.0,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              exercise['name'],
                                              textAlign: TextAlign.center,
                                              style: const TextStyle(
                                                fontSize: 32,
                                              ),
                                            ),
                                            const SizedBox(height: 8.0),
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
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
                                            style:
                                                const TextStyle(fontSize: 18),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ));
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "No Workout Data is Available for $muscle."),
                          ),
                        );
                      }
                    },

                    // Styling elements for each specific muscle
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Adding an icon to each specific muscle
                            Icon(icon ?? Icons.fitness_center,
                                size:
                                    34), // Setting the default Icon if one does not exist
                            Text(
                              capitalizeFirstLetter(
                                  muscle.replaceAll('_', ' ')),
                              style: const TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            const Icon(Icons.arrow_forward_ios, size: 34),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              Container(
                color: const Color.fromARGB(255, 232, 229, 229),
                child: Center(
                  child: Text(muscle),
                ),
              ),
              const Center(
                child: Text("Tab 3"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
