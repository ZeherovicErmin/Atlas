//Atlas Fitness App CSC 4996
import 'package:atlas/pages/settings_page.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

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
    //Saves the state of dark mode being on or off
    final lightDarkTheme = ref.watch(themeProvider);

    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;
    final themeColor2 = lightDarkTheme ? Color.fromARGB(255, 18, 18, 18) : Colors.white;

    // Container for the gradient of the application
    return Container(
      child: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          backgroundColor: themeColor2,
          //Home page for when a user logs in
          appBar: AppBar(
            title: Center(
              child: Text(
                "F i t n e s s C e n t e r",
                style: TextStyle(
                    fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
              ),
            ),
            backgroundColor: Color.fromARGB(255, 90, 86, 86),
            bottom: TabBar(
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
                              backgroundColor: Color.fromARGB(255, 90, 86, 86),
                              title: Text("Workouts for $muscle"),
                            ),
                            body: ListView.builder(
                              itemCount: exercisesData.length,
                              itemBuilder: (context, index) {
                                final exercise = exercisesData[index];
                                return ListTile(
                                  title: Text(exercise['name']),
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
                        border: Border.all(color: themeColor2),
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
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.bold),
                            ),
                            Icon(Icons.arrow_forward_ios, size: 34),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),

              Container(
                color: themeColor2,
                child: Center(
                  child: Text(muscle),
                ),
              ),
              Center(
                child: Text("Tab 3"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
