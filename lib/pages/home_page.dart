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
  late Stream<DocumentSnapshot> habitStream;

  @override
  void initState() {
    super.initState();
    currentSubtitle = '';
    habitStream = fetchData();
  }

  //Fetches the habit cards from firebase to display to the user
  Stream<DocumentSnapshot> fetchData() {
    var currentDate = DateTime.now();
    var formattedDate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    //For debugging purposes, change the testdate to any date to test the
    //fetching of the correct data for the correct date.
    var testDate = '2023-10-25';
    return FirebaseFirestore.instance.collection('Habits').doc(uid).collection(formattedDate).doc('habits').snapshots();
  }

  //Opens the habit card for editing & habit card build
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: habitStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        var data = snapshot.data?.data() as Map<String, dynamic>?;
        currentSubtitle = data?[widget.title.toLowerCase()] ?? '';
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
      },
    );
  }
  //Function for editing a habit card
  //Sends the data to firebase
  void editDialog(BuildContext context, String title) async {
    //Variables
    var currentDate = DateTime.now();
    TextEditingController textController = TextEditingController(text: currentSubtitle);
    String uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    var formattedDate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
    //Habit card popup for editing data
    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: TextField(
                controller: textController,
                decoration: const InputDecoration(hintText: 'Enter a value'),
                onChanged: (value) {
                  setState(() {
                    currentSubtitle = value;
                  });
                },
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                    widget.onTap(currentSubtitle);
                    DocumentReference userDocRef = FirebaseFirestore.instance.collection('Habits').doc(uid);
                    CollectionReference dateSubcollectionRef = userDocRef.collection(formattedDate);
                    await dateSubcollectionRef.doc('habits').set({
                      title.toLowerCase(): currentSubtitle,
                    }, SetOptions(merge: true));
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
      },
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late String selectedDate;
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    var currentDate = DateTime.now();
    selectedDate = "${currentDate.month}/${currentDate.day}";
    formattedDate = "${currentDate.year}-${currentDate.month}-${currentDate.day}";
  }

  //Function for choosing a date
  Future<void> chooseDate(BuildContext context) async {
    DateTime currentDate = DateTime.now();
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2023, 10),
      lastDate: DateTime(2026),
    );
  if (picked != null) {
      setState(() {
        currentDate = picked;
        var month = picked.month.toString().padLeft(2, '0');
        var day = picked.day.toString().padLeft(2, '0');
        formattedDate = "${currentDate.year}-$month-$day";
        selectedDate = "$month/$day";
      });
    }
  }

  //App Bar
  PreferredSize homePageAppBar(BuildContext context, String title) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(70),
      child: AppBar(
        automaticallyImplyLeading: false,
        leading: null,
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 0, 136, 204),
          actions: [
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
              Container (
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      chooseDate(context);
                    },
                    child: Text(
                      selectedDate,
                      style: const TextStyle(color: Color.fromARGB(255, 255, 255, 255), fontSize: 20),
                    ),
                  ),
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
                      saveHabitData(uid2, formattedDate, 'calories', value);
                    },
                    selectedDate: formattedDate,
                  ),
                  HabitCard(
                    title: 'Sleep',
                    iconData: Icons.nightlight_round,
                    backgroundColor: Colors.purple,
                    onTap: (value) {
                      saveHabitData(uid2, formattedDate, 'sleep', value);
                    },
                    selectedDate: formattedDate,
                  ),
                  HabitCard(
                    title: 'Water',
                    iconData: Icons.water_drop,
                    backgroundColor: Colors.blue,
                    onTap: (value) {
                      saveHabitData(uid2, formattedDate, 'water', value);
                    },
                    selectedDate: formattedDate,
                  ),
                  HabitCard(
                    title: 'Running',
                    iconData: Icons.directions_run,
                    backgroundColor: Colors.green,
                    onTap: (value) {
                      saveHabitData(uid2, formattedDate, 'running', value);
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
  //Function to save habit data in Firebase
  void saveHabitData(String uid, String formattedDate, String habit, String value) async {
    CollectionReference habitCollectionRef = FirebaseFirestore.instance
        .collection('Habits')
        .doc(uid)
        .collection(formattedDate)
        .doc('habits')
        .collection('habits');
    await habitCollectionRef.doc(habit).set({'data': value});
  }
}
