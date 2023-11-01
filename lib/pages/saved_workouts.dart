// Creating the storage for saved recipes that will be stored in specific days of the week the user selects

// Creating the Saved Exercises class that will manage the state
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SavedExercises extends StatefulWidget {
  const SavedExercises({Key? key}) : super(key: key);

  @override
  State<SavedExercises> createState() => _SavedExercisesState();
}

// Creating the class that will manage the state of saved exercises and pull from the firestore collection Exercises
class _SavedExercisesState extends State<SavedExercises> {
  final CollectionReference exercisesCollection =
      FirebaseFirestore.instance.collection("Exercises");

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth auth = FirebaseAuth.instance;

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

              return ListTile(
                title: Text(exerciseData['name'] ?? ''),

                // Add other exercise details here
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () => onRemove(exercisesSnapshot),
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
}
