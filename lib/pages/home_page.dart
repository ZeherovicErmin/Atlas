import 'package:atlas/pages/constants.dart';
import 'package:atlas/pages/habit_tracker.dart';
import 'package:atlas/pages/settings_page.dart';
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
            // Habit deletion goes here
          },
        ),
        // Habit marking goes here
      ),
    );
  }
}

class HomePage extends ConsumerWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final habits = ref.watch(habitListNotifierProvider);
    //Saves the state of dark mode being on or off
    final lightDarkTheme = ref.watch(themeProvider);

    //Holds the opposite theme color for the text
    final themeColor = lightDarkTheme ? Colors.white : Colors.black;
    final themeColor2 = lightDarkTheme ? Color.fromARGB(255, 18, 18, 18) : Colors.white;

    return Scaffold(
      backgroundColor: themeColor2,
      appBar: myAppBar2(context, ref, 'HomePage'),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
        ),
        itemCount: habits.habits.length,
        itemBuilder: (context, index) {
          final habit = habits.habits[index];
          return HabitTileWidget(habit: habit);
        },
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: "addHabit",
        onPressed: () {
          // Navigate to habit creation screen
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
