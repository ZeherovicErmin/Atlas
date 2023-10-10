import 'package:atlas/pages/habit_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> addHabitToFirestore(String userId, Habit habit) async {
  try {
    final CollectionReference usersCollection =
        FirebaseFirestore.instance.collection('Users');

    final DocumentReference userDocRef = usersCollection.doc(userId);

    final CollectionReference habitsCollection =
        userDocRef.collection('habits');

    // Create a new document for the habit
    await habitsCollection.add({
      'name': habit.name,
      'description': habit.description ?? '',
      'startDate': habit.startDate,
      'frequency': habit.frequency,
      'completedDates': habit.completedDates,
    });
  } catch (e) {
    print('Error adding habit to Firestore: $e');
  }
}

class HabitCreationScreen extends ConsumerWidget {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String _habitName = '';
    String _description = '';
    DateTime _startDate = DateTime.now();
    String _frequency = 'daily'; // Default frequency value

    return Scaffold(
      appBar: AppBar(
        title: Text('Create a New Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Habit Name'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a habit name';
                  }
                  return null;
                },
                onSaved: (value) {
                  _habitName = value!;
                },
              ),
              TextFormField(
                decoration:
                    InputDecoration(labelText: 'Description (Optional)'),
                onSaved: (value) {
                  _description = value!;
                },
              ),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    final newHabit = Habit(
                      id: UniqueKey().toString(), // Unique ID for the habit
                      name: _habitName,
                      description:
                          _description.isNotEmpty ? _description : null,
                      startDate: _startDate,
                      frequency: _frequency,
                      completedDates: [],
                      // Initialize new habit data here
                    );

                    // Replace 'yourUserId' with the actual user ID
                    await addHabitToFirestore('yourUserId', newHabit);

                    // Add the habit to the state using HabitListNotifier (if needed)
                    ref
                        .read(habitListNotifierProvider.notifier)
                        .addHabit(newHabit);

                    // Navigate back to the homepage after adding the habit
                    Navigator.pop(context);
                  }
                },
                child: Text('Create Habit'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
