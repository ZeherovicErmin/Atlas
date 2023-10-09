import 'package:atlas/pages/habit_tracker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _formKey.currentState!.save();

                    // Create a Habit object with the form data
                    final newHabit = Habit(
                      id: UniqueKey().toString(),
                      name: _habitName,
                      description:
                          _description.isNotEmpty ? _description : null,
                      startDate: _startDate,
                      frequency: _frequency,
                      completedDates: [],
                    );

                    // Add the habit to the state using HabitListNotifier
                    ref
                        .read(habitListNotifierProvider.notifier)
                        .addHabit(newHabit);
                    final habits = ref.watch(habitListNotifierProvider);

                    print('Number of habits: ${habits}');

                    // Navigate back to the homepage after adding the habit
                    Navigator.pop(context);
                  }
                },
                child: Text('Create Habit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
