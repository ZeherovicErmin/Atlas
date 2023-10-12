//Atlas Fitness App CSC 4996
import 'package:atlas/main.dart';
import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';


// Creating a list of target muscles
const List<String> list = <String>['biceps', 'triceps', 'chest'];


// Creating a state provider to return a string for selected muscle
final selectedMuscleProvider = StateProvider<String>((ref){
String muscle = 'biceps';
return muscle;
});


// Creating a drop down button to modify selectedMuscleProvider
class fitDropdown extends ConsumerWidget{
  

  @override
  Widget build(BuildContext context, WidgetRef ref){
  String dropdownVal = ref.watch(selectedMuscleProvider);
    
    // Creating the dropdown button to modify the value of the muscle in selectedMuscleProvider
    return DropdownButton<String>(
      value: dropdownVal,
      icon: const Icon(Icons.arrow_downward),
      elevation: 16,
      style: const TextStyle(color: Colors.deepPurple),
      underline: Container(
        height: 2,
        color: Colors.deepPurpleAccent,
      ),
      items: list.map<DropdownMenuItem<String>>((String value){
      return DropdownMenuItem<String>(
        value: value,
        child: Text(value),
      );
      }).toList(),
      onChanged: (String? value){
        if(value != null){
        ref.read(selectedMuscleProvider.state).state = value;}
      }
      
      );
  }
} 


class FitCenter extends ConsumerWidget {
  
  const FitCenter({Key? key}) : super(key: key);


  Future<List<dynamic>> getExercises() async{

    // The Api key from API NINJAS
    final String myApiKey = 'q48XgvLytBmNhVJHFzoZgg==QWOhrECybUKjiRR8';

    // Creating a muscle variable to pass to the api to specify the muscle group
    final muscle = 'biceps';

    // THe url to Api ninjas site, the $muscle will be provided from the muscle variable  
    final  apiUrl = 'https://api.api-ninjas.com/v1/exercises?muscle=$muscle';

    // waiting for a response from the api
    final response = await http.get(Uri.parse(apiUrl), headers: {'X-Api-Key': myApiKey});

    // if statement to catch errors
    if(response.statusCode == 200){
      final List<dynamic> data = json.decode(response.body);
      return data;
    } else {
      print("Error: ${response.statusCode} ${response.body}");
      return []; // Returning an empty list in case there is an error
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    var muscleval = ref.watch(selectedMuscleProvider);
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 90, 117, 255),
            Color.fromARGB(255, 161, 195, 250),
          ],
        ),
      ),
      child: DefaultTabController(
        initialIndex: 1,
        length: 3,
        child: Scaffold(
          //Home page for when a user logs in
          appBar: AppBar(
            title: Text(
              "F i t n e s s C e n t e r",
              style: TextStyle(
                  fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color.fromARGB(255, 38, 97, 185),
            bottom: TabBar(
              tabs: [
                Tab(text: "Discover"),
                Tab(text: "My Workouts"),
                Tab(text: "Progress"),
              ],
            ),
          ),

          body: TabBarView(
            children: [
              

              // The Discover Tab Of the workouts page
              GestureDetector (
                        onTap: () async {
                          // Calling the exercises API when tapping the button
                          final exercisesData = await getExercises();

                          // If the exercise data exists
                          if(exercisesData.isNotEmpty){
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => Scaffold(
                              appBar: AppBar(title: Text("Discovered Workouts"),),
                              body: ListView.builder(itemCount: exercisesData.length, itemBuilder: (context,index){
                                final exercise = exercisesData[index];
                                return ListTile(title: Text(exercise['name']),);
                              },),

                            ),

                          ),
                            );
                          
                          // Throwing a snackbar error if data isnt found
                        } else{ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No Workout Data Available."),),);
                        }
                        },

                        // Placing the Dropdown menu on the Discover Tab
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:[
                          fitDropdown(),
                          const Center(child: Text(
                          'Find Workouts',
                          style: TextStyle(color: Color.fromARGB(255, 0, 60, 255),
                          fontWeight: FontWeight.bold,
                          ),
                        ),),
                        ],
                      ),
              ),
              Center(
                child: Text(muscleval),
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
