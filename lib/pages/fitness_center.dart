//Atlas Fitness App CSC 4996
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Creating a list of target muscles
const List<String> list = <String>['biceps', 'triceps', 'chest'];

// Creating a state provider to return a string for selected muscle
final selectedMuscleProvider = StateProvider<String>((ref) {
  String muscle = 'biceps';
  return muscle;
});

// Creating a drop down button to modify selectedMuscleProvider
class fitDropdown extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String dropdownVal = ref.watch(selectedMuscleProvider);

    // Creating the dropdown button to modify the value of the muscle in selectedMuscleProvider
    return Center(
      child: DropdownButtonHideUnderline(
        child: DropdownButton2<String>(
            isExpanded: true,
            value: dropdownVal,
            style: const TextStyle(color: Colors.deepPurple),
            underline: Container(
              height: 2,
              color: Colors.deepPurpleAccent,
            ),
            hint: const Row(
              children: [
                Icon(
                  Icons.list,
                  size: 16,
                  color: Colors.yellow,
                ),
                SizedBox(
                  width: 4,
                ),
                Expanded(
                  child: Text(
                    'Select Item',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.yellow,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            items: list.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value,
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: const Color.fromARGB(255, 0, 0, 0)),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList(),
            onChanged: (String? value) {
              if (value != null) {
                ref.read(selectedMuscleProvider.notifier).state = value;
              }
            },
            //changes how the button looks AC
            buttonStyleData: ButtonStyleData(
              height: 50,
              width: 160,
              padding: const EdgeInsets.only(left: 14, right: 14),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: Colors.black26,
                ),
                color: Color.fromARGB(255, 90, 86, 86),
              ),
              elevation: 2,
            ),
            iconStyleData: const IconStyleData(
              icon: Icon(
                Icons.arrow_forward_ios_outlined,
              ),
              iconSize: 14,
              iconEnabledColor: Colors.yellow,
              iconDisabledColor: Colors.grey,
            ),
            dropdownStyleData: DropdownStyleData(
              maxHeight: 200,
              width: 200,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                color: Color.fromARGB(255, 232, 229, 229),
              ),
              offset: const Offset(-20, 0),
              scrollbarTheme: ScrollbarThemeData(
                radius: const Radius.circular(40),
                thickness: MaterialStateProperty.all(6),
                thumbVisibility: MaterialStateProperty.all(true),
              ),
            ),
            menuItemStyleData: const MenuItemStyleData(
              height: 40,
              padding: EdgeInsets.only(left: 14, right: 14),
            )),
      ),
    );
  }
}

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
      decoration: const BoxDecoration(),
      child: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          backgroundColor: Color.fromARGB(255, 232, 229, 229),
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
              Container(
                color: Color.fromARGB(255, 232, 229, 229),
                child: GestureDetector(
                  onTap: () async {
                    // Calling the exercises API when tapping the button
                    final muscle =
                        ref.watch(selectedMuscleProvider.notifier).state;
                    final exercisesData = await getExercises(muscle);

                    // If the exercise data exists
                    if (exercisesData.isNotEmpty) {
                      Navigator.of(context).push(MaterialPageRoute(
                          builder: (context) => Scaffold(
                                appBar: AppBar(
                                  title: Text("Discovered Workouts"),
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
                              )));

                      // Throwing a snackbar error if data isnt found
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("No Workout Data Available."),
                        ),
                      );
                    }
                  },

                  // Placing the Dropdown menu on the Discover Tab
                  child: Column(
                    children: [
                      fitDropdown(),
                      const Center(
                        child: Text(
                          'Find Workouts',
                          style: TextStyle(
                              color: Color.fromARGB(255, 0, 0, 0),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                color: Color.fromARGB(255, 232, 229, 229),
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
