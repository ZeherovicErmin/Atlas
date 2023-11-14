import 'package:atlas/pages/habit_card.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitToggle extends StatefulWidget {

  @override
  _HabitToggleState createState() => _HabitToggleState();
}

class _HabitToggleState extends State<HabitToggle> {
  Map<String, bool> selectedHabits = {};
  String searchBarText = '';
  final List<HabitInfo> habits = [
    HabitInfo(title: 'Calories',      image: 'lib/images/burger.png',       backgroundColor: Colors.red),
    HabitInfo(title: 'Sleep',         image: 'lib/images/bed.png',          backgroundColor: Colors.purple),
    HabitInfo(title: 'Water',         image: 'lib/images/water.png',        backgroundColor: Colors.lightBlue),
    HabitInfo(title: 'Protein',       image: 'lib/images/protein.png',      backgroundColor: Colors.brown),
    HabitInfo(title: 'Weight',        image: 'lib/images/weigh-scales.png', backgroundColor: Colors.grey[700] ?? Colors.grey),
    HabitInfo(title: 'Carbohydrates', image: 'lib/images/bread.png',        backgroundColor: Colors.cyan),
    HabitInfo(title: 'Sugar',         image: 'lib/images/sugar.png',        backgroundColor: const Color.fromARGB(255, 255, 116, 163)),
    HabitInfo(title: 'Running',       image: 'lib/images/jogging.png',      backgroundColor: Colors.green),
    HabitInfo(title: 'Pullups',       image: 'lib/images/pull-up-bar.png',  backgroundColor: const Color.fromARGB(255, 76, 165, 175)),
    HabitInfo(title: 'Pushups',       image: 'lib/images/push-up.png',      backgroundColor: const Color.fromARGB(255, 175, 142, 76)),
    HabitInfo(title: 'Situps',        image: 'lib/images/sit-up.png',       backgroundColor: const Color.fromARGB(255, 209, 116, 238)),
    HabitInfo(title: 'Sodium',        image: 'lib/images/sodium.png',       backgroundColor: const Color.fromARGB(255, 238, 116, 177)),
    HabitInfo(title: 'Fats',          image: 'lib/images/sodium.png',       backgroundColor: const Color.fromARGB(255, 116, 230, 238)),
  ];

  @override
  void initState() {
    super.initState();
    fetchToggledHabits();
  }

  //Gets the user's toggled habits bool value from firebase
  void fetchToggledHabits() async {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    //If the user exists, the selected habits will appear on the home page
    if (uid != null) {
      DocumentSnapshot usersHabits = await FirebaseFirestore.instance
        .collection('SelectedHabits')
        .doc(uid)
        .get();
      var data = usersHabits.data() as Map<String, dynamic>?;
      setState(() {
        selectedHabits = Map<String, bool>.from(data?['selectedHabits'] ?? {});
      });
    }
  }

    //Saves whether the user has a habit toggled or not to firebase
    void updateHabit(String habit, bool value) {
    setState(() {
      selectedHabits[habit] = value;
    });

    //Variables
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    //Updates the value in firebase
    if (uid != null) {
      FirebaseFirestore.instance
        .collection('SelectedHabits')
        .doc(uid)
        .set({'selectedHabits': selectedHabits},
        SetOptions(merge: true));
    }
  }

  //Habit Select App Bar
  PreferredSize habitSelectAppBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 136, 204),
        toolbarHeight: 60,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Habit Card Toggles',
              style: TextStyle(
                fontFamily: 'Open Sans',
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Search bar above the habit cards
  TextField searchBar(String hintText) {
    return TextField(
      onChanged: (value) {
        setState(() {
          searchBarText = value;
        });
      },
      decoration: InputDecoration(
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade400),
        ),
        fillColor: Colors.grey.shade200,
        filled: true,
        hintText: hintText,
        hintStyle: TextStyle(color: Colors.grey[500]),
        suffixIcon: const Icon(Icons.search),
      ),
    );
  }

  //Toggles back and forth whether the habit is
  //selected to be shown on the homepage or not.
  void toggleHabit(String habit) {
    setState(() {
      selectedHabits[habit] = !(selectedHabits[habit] ?? true);
    });

    //Variables
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;

    //Updates the value in firebase
    if (uid != null) {
      FirebaseFirestore.instance
          .collection('SelectedHabits')
          .doc(uid)
          .set({'selectedHabits': selectedHabits}, SetOptions(merge: true));
    }
  }

  @override
  Widget build(BuildContext context) {
    //List for searching through the habit card's titles
    List<HabitInfo> habitCardFilter = habits
      .where((habit) => habit.title
      .toLowerCase()
      .contains(searchBarText
      .toLowerCase()))
      .toList();

    return Scaffold(
      appBar: habitSelectAppBar(context),
      body: Column(
        children: [
          //Search bar
          Padding(
            padding: const EdgeInsets.only(
              left: 16,
              right: 16,
              top: 16,
              bottom: 16,
              ),
            child: searchBar('Search for a habit card'),
          ),
          //Habit Cards
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.5,
                mainAxisSpacing: 4,
              ),
              itemCount: habitCardFilter.length,
              itemBuilder: (context, index) {
                HabitInfo habit = habitCardFilter[index];
                bool isChosen = selectedHabits[habit.title] ?? true;
                return Padding(
                  padding: const EdgeInsets.only(
                    left: 8,
                    right: 8
                    ),
                  child: GestureDetector(
                    onTap: () => toggleHabit(habit.title),
                    child: Opacity(
                      opacity: isChosen ? 1 : .4,
                      child: Container(
                        decoration: BoxDecoration(
                          color: habit.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              habit.image,
                              width: 46,
                              height: 46,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              habit.title,
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
