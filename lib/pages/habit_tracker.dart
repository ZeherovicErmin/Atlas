import 'package:flutter_riverpod/flutter_riverpod.dart';

class Habit {
  // ID of the Habit
  final String id;
  // Name of the Habit
  final String name;
  // Description of the habit (optional)
  final String? description;
  // Habit StartDate
  final DateTime startDate;
  // final String Frequency
  final String frequency;
  // completed Dates
  final List<DateTime> completedDates;
  Habit({
    required this.id,
    required this.name,
    this.description, // optional
    required this.startDate,
    required this.frequency,
    required this.completedDates,
  });
}

//for creating a Habit to State
final habitListProvider = StateProvider<List<Habit>>((ref) => []);
final habitListNotifierProvider =
    StateNotifierProvider<HabitListNotifier, HabitListState>((ref) {
  return HabitListNotifier([]);
});

final habitAdditionProvider = Provider.family<void, Habit>((ref, habit) {
  // Instead of modifying the state directly during initialization,
  // schedule the state modification using Future.delayed.
  Future.delayed(Duration.zero, () {
    final habits = ref.watch(habitListProvider.notifier).state;
    ref.watch(habitListProvider.notifier).state = [...habits, habit];
  });
});

// States of providers
class HabitListState {
  final List<Habit> habits;

  HabitListState(this.habits);

  get length => null;
}

class HabitListNotifier extends StateNotifier<HabitListState> {
  HabitListNotifier(List<Habit> habits) : super(HabitListState(habits));

  void addHabit(Habit habit) {
    state = HabitListState([...state.habits, habit]);
  }
}
