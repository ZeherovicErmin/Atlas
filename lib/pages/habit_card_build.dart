//Author: Matthew McGowan
import 'package:atlas/pages/line_chart.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

class HabitCard extends StatefulWidget {
  final String title;
  final String unit;
  final IconData iconData;
  final Color backgroundColor;
  final Function(String) onTap;
  final String selectedDate;
  final String image;

  const HabitCard({
    required this.title,
    required this.unit,
    required this.backgroundColor,
    required this.onTap,
    required this.selectedDate,
    this.iconData = Icons.flutter_dash,
    this.image = '',
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
    habitStream = fetchHabits();
  }

  @override
  void didUpdateWidget(covariant HabitCard oldHabitData) {
    super.didUpdateWidget(oldHabitData);
    if (oldHabitData.selectedDate != widget.selectedDate) {
      setState(() {
        habitStream = fetchHabits();
      });
    }
  }


  //Fetches the habit cards from firebase to display to the user
  Stream<DocumentSnapshot> fetchHabits() {
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    //For debugging purposes, change the testdate to any date to test the
    //fetching of the correct data for the correct date.
    return FirebaseFirestore.instance
      .collection('Habits')
      .doc(uid)
      .collection(widget.selectedDate)
      .doc('habits')
      .snapshots();
  }

  //Opens the habit card for editing & habit card build
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: habitStream,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
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
                if (widget.image.isNotEmpty)
                Image.asset(
                  widget.image,
                  width: 60,
                  height: 60,
                ),
                if (widget.image.isEmpty)
                Icon(
                  widget.iconData,
                  size: 50,
                  color: Colors.white,
                ),
                const SizedBox(height: 10),
                AutoSizeText(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    maxLines: 1,
                    minFontSize: 12,
                  ),
                const SizedBox(height: 5),
                Text(
                  widget.unit,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  currentSubtitle,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
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
    TextEditingController textController = TextEditingController(text: currentSubtitle);
    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final uid = user?.uid;
    //Habit card popup for editing data
    showDialog(
      context: context,
        builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Edit $title'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: textController,
                    keyboardType: const TextInputType.numberWithOptions(signed: false, decimal: false),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      hintText: 'Enter a value',
                      ),
                    onChanged: (value) {
                      setState(() {
                        currentSubtitle = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                  width: 250,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HabitLineChartPage(
                            habitTitle: title,
                            habitCardColor: widget.backgroundColor,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[850],
                    ),
                    child: Center(
                      child: Text('View $title Graph',
                        style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                        ),
                      ),
                    ),
                    ),
                  )
                ],
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Save'),
                  onPressed: () async {
                      widget.onTap(currentSubtitle);
                      DocumentReference userDocRef = FirebaseFirestore.instance
                        .collection('Habits')
                        .doc(uid);
                      CollectionReference dateSubcollectionRef =
                          userDocRef.collection(widget.selectedDate);
                      await dateSubcollectionRef
                        .doc('habits')
                        .set({title.toLowerCase(): currentSubtitle,
                        },
                        SetOptions(merge: true));
                      Navigator.of(context).pop();
                      if (mounted) {
                        setState(() {
                          currentSubtitle = textController.text;
                        });
                      }
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