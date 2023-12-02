// Creating the storage for saved recipes that will be stored in specific days of the week the user selects

// Creating the Saved Exercises class that will manage the state
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flip_card/flip_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

//Atlas Fitness App CSC 4996
// Author : Ermin Zeherovic
class SavedExercises extends StatefulWidget {
  // Creating a variable to pass a collection name as a parameter
  final String collectionName;

  const SavedExercises({Key? key, required this.collectionName})
      : super(key: key);

  @override
  State<SavedExercises> createState() => _SavedExercisesState();
}

// Creating the class that will manage the state of saved exercises and pull from the firestore collection Exercises
class _SavedExercisesState extends State<SavedExercises> {
  // Taking the collection name to pass into the function
  late final CollectionReference exercisesCollection;

  @override
  void initState() {
    super.initState();

    // Initializing the firestore collection
    exercisesCollection =
        FirebaseFirestore.instance.collection(widget.collectionName);
  }

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

    // Storing the currentUser into a variable
    final currentUser = FirebaseAuth.instance.currentUser!;

    // Getting the user id of the current user
    final userID = auth.currentUser?.uid;

    return Scaffold(
      body: StreamBuilder<QuerySnapshot>(
        stream: exercisesCollection.where("uid", isEqualTo: userID).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }

          List<DocumentSnapshot> savedExercises = snapshot.data!.docs;

          return ListView.builder(
            itemCount: savedExercises.length,
            itemBuilder: (context, index) {
              DocumentSnapshot exercisesSnapshot = savedExercises[index];
              Map<String, dynamic> exerciseData =
                  exercisesSnapshot.data() as Map<String, dynamic>;

              return Container(
                margin: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(12.0), // Add a border radius
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
                                exerciseData['exercise']['name'] ?? '',
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
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  /*Text(
                                    exerciseData['exercise']['type'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.red,
                                      fontSize: 18,
                                    ),
                                  ),*/
                                  Text(
                                    exerciseData['exercise']['difficulty'] ??
                                        '',
                                    style: const TextStyle(
                                      color: Colors.purple,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    exerciseData['exercise']['muscle'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.blue,
                                      fontSize: 18,
                                    ),
                                  ),
                                  Text(
                                    exerciseData['exercise']['equipment'] ?? '',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Positioned(
                            top: 0.0,
                            left: 0.0,
                            child: Row(
                              children: [
                                // Creating a button to share exercises to the feed
                                IconButton(
                                  onPressed: () {
                                    _showMessageInputDialog(
                                        context, exerciseData, currentUser);
                                  },
                                  // Delete from firebase and my workouts
                                  icon: const Icon(
                                    CupertinoIcons.share,
                                    size: 30,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            top: 0.0,
                            right: 0.0,
                            child: IconButton(
                              onPressed: () {
                                onRemove(exercisesSnapshot);
                              },
                              // Delete from firebase and my workouts
                              icon: const Icon(
                                CupertinoIcons.delete,
                                size: 30,
                              ),
                            ),
                          )
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
                            // Showing a gif for the exercise
                            Image.asset(exerciseData['exercise']['gif'] ?? '',
                                height: 150,
                                width: double.infinity,
                                fit: BoxFit.fitHeight),
                            // Returning a numbered list for the instructions of the workout
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: (exerciseData['exercise']
                                              ['instructions'] ??
                                          '')
                                      .split('.')
                                      .length -
                                  1,
                              itemBuilder: (BuildContext context, int index) {
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 8.0),
                                  child: Text(
                                    '${index + 1}. ${(exerciseData['exercise']['instructions'] ?? '').split('.')[index]}',
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
        },
      ),
    );
  }

  // Creating a button to remove a saved Exercise
  void onRemove(DocumentSnapshot exerciseSnapshot) async {
    try {
      await exercisesCollection.doc(exerciseSnapshot.id).delete();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercise Removed'),
        ),
      );
    } catch (e) {
      print('Error removing exercise: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error removing exercise'),
        ),
      );
    }
  }

// A function to enable adding a message when sharing workouts
  Future<void> _showMessageInputDialog(BuildContext context,
      Map<String, dynamic> exerciseData, User currentUser) async {
    // Initalizing an empty string
    String message = '';

    // Showing a dialog message
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add a Message'),

          // Appending the message to the value we set it to
          content: TextField(
            onChanged: (value) {
              message = value;
            },

            // Adding hint text to the text box
            decoration: InputDecoration(hintText: 'Enter your message here'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                // Using the onShare function previously created to share the exercise with the message we have created
                onShare(exerciseData, currentUser, message);
                Navigator.of(context).pop();
              },
              child: Text('Share'),
            ),
          ],
        );
      },
    );
  }

  // Creating a function to share workouts to the feed page
  void onShare(Map<String, dynamic> exerciseData, User currentUser,
      String message) async {
    // Gathering the exercise details to share
    String name = exerciseData['exercise']['name'] ?? '';
    String type = exerciseData['exercise']['type'] ?? '';
    String muscle = exerciseData['exercise']['muscle'] ?? '';
    String equipment = exerciseData['exercise']['equipment'] ?? '';
    String difficulty = exerciseData['exercise']['difficulty'] ?? '';
    String gif = exerciseData['exercise']['gif'] ?? '';
    String instructions = exerciseData['exercise']['instructions'] ?? '';

    // Creating a post in the feed collection with exercise details
    try {
      await FirebaseFirestore.instance.collection("User Posts").add({
        'Message': message,
        'UserEmail': currentUser.email,
        'TimeStamp': Timestamp.now(),
        'ExerciseName': name,
        'ExerciseType': type,
        'ExerciseMuscle': muscle,
        'ExerciseEquipment': equipment,
        'ExerciseDifficulty': difficulty,
        'ExerciseGif': gif,
        'ExerciseInstructions': instructions,
        'postImage': '',
        'barcodeData': {},
        'Likes': [],
      });

      // Adding a snackbar to notify the user an exercise has been succesfully shared
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Exercise Shared to Feed: $name'),
        ),
      );
    } catch (e) {
      print('Error sharing exercise: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing exercise'),
        ),
      );
    }
  }
}
