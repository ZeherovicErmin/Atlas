import 'package:atlas/pages/habit_tracker.dart';
import 'package:atlas/util/habit_creation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HabitTileWidget extends StatelessWidget {
  final Habit habit;

  HabitTileWidget({required this.habit});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: ListTile(
        title: Text(habit.name),
        subtitle: habit.description != null ? Text(habit.description!) : null,
        trailing: IconButton(
          icon: Icon(Icons.delete),
          onPressed: () {
            // Implement habit deletion logic here using Riverpod
          },
        ),
        // You can add more actions like marking habit as completed here
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitListNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
      ),
      body: ListView.builder(
        itemCount: habits.habits.length, // Use habits.habits.length
        itemBuilder: (context, index) {
          final habit =
              habits.habits[index]; // Access the habit from habits.habits
          return HabitTileWidget(habit: habit);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addHabit",
        onPressed: () {
          // Navigate to the habit creation screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => HabitCreationScreen(),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
