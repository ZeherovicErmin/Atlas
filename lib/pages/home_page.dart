import 'package:atlas/pages/user_profile.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HabitCard extends StatefulWidget {
  final String title;
  final IconData iconData;
  final Color backgroundColor;
  final Function(String) onTap;
  final String selectedDate;

  const HabitCard({
    required this.title,
    required this.iconData,
    required this.backgroundColor,
    required this.onTap,
    required this.selectedDate,
  });

  @override
  HabitCardState createState() => HabitCardState();
}

class HabitCardState extends State<HabitCard> {
  late String currentSubtitle;

  @override
  void initState() {
    super.initState();
    currentSubtitle = '';
    fetchData();
  }

  //Gets the data back from firebase
  void fetchData() async {
    var currentDate = DateTime.now();
    var formattedDate = "${currentDate.month}/${currentDate.day}/${currentDate.year}";
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    var data = await FirebaseFirestore.instance
        .collection('Habits')
        .doc(uid)
        .get();
    if (data.exists) {
      setState(() {
        currentSubtitle = data.data()?[widget.title] ?? '';
      });
    }
  }

  //Opens the habit card for editing & habit card build
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        editDialog(context, widget.title);
      },
      child: Container(
        decoration: BoxDecoration(
          color: widget.backgroundColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              widget.iconData,
              size: 50,
              color: Colors.white,
            ),
            const SizedBox(height: 10),
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              currentSubtitle,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  //Function for editing a habit card
  //Sends the data to firebase
  void editDialog(BuildContext context, String title) {
    TextEditingController textController = TextEditingController(text: currentSubtitle);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit $title'),
          content: TextField(
            controller: textController,
            decoration: const InputDecoration(hintText: 'Enter a value'),
            onChanged: (value) {
              currentSubtitle = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () async {
                widget.onTap(currentSubtitle);
                String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
                DocumentReference docRef = FirebaseFirestore.instance
                    .collection('Habits')
                    .doc(uid);
                await docRef.set(
                  {title: currentSubtitle, 'uid': uid},
                  SetOptions(merge: true),
                );
                Navigator.of(context).pop();
                setState(() {
                  currentSubtitle = textController.text;
                });
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({Key? key});

  //App Bar
  PreferredSize homePageAppBar(BuildContext context, String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        leading: null,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 90, 86, 86),
          actions: [
          //Settings icon button
          IconButton (
          icon: const Icon(Icons.person_rounded),
          onPressed: () {
              Navigator.push (
                context,
                MaterialPageRoute(builder: (context) => const UserProfile()),
              );
            },
          ),
        ],
        title: Text(
          title,
          style: const TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {

    //Variables
    var currentDate = DateTime.now();
    var formattedDate = "${currentDate.month}/${currentDate.day}";
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    String uid2 = uid.toString();

    //Returns the app bar & habit cards
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: homePageAppBar(context, 'H o m e  P a g e'),
        body: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              const SizedBox(height: 10),
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(14),
                  color: const Color.fromARGB(255, 255, 149, 1),
                ),
                child: TabBar(
                  unselectedLabelColor: const Color.fromARGB(255, 255, 149, 1),
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                  color: const Color.fromARGB(255, 255, 149, 1),
                  ),
                  tabs: [
                    Tab(text: formattedDate),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    HabitCard(
                      title: 'Calories',
                      iconData: Icons.fastfood,
                      backgroundColor: Colors.red,
                      onTap: (value) {
                      },
                      selectedDate: formattedDate,
                    ),
                    HabitCard(
                      title: 'Sleep',
                      iconData: Icons.nightlight_round,
                      backgroundColor: Colors.purple,
                      onTap: (value) {
                      },
                      selectedDate: formattedDate,
                    ),
                    HabitCard(
                      title: 'Water',
                      iconData: Icons.water_drop,
                      backgroundColor: Colors.blue,
                      onTap: (value) {
                      },
                      selectedDate: formattedDate,
                    ),
                    HabitCard(
                      title: 'Running',
                      iconData: Icons.directions_run,
                      backgroundColor: Colors.green,
                      onTap: (value) {
                      },
                      selectedDate: formattedDate,
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
