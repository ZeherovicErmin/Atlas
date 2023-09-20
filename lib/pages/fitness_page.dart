import 'package:atlas/components/text_box.dart';
import 'package:atlas/constants.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FitPage extends StatefulWidget {
  const FitPage({Key? key});

  @override
  State<FitPage> createState() => _FitPageState();
}

// Creating tabs to navigate to other pages with navbar
final tabs = const [
  HomePage(),
  FitPage(),
];

class _FitPageState extends State<FitPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  final usersCollection = FirebaseFirestore.instance.collection("Users");
  int _currentIndex = 0;

  // Edit field
  Future<void> editField(String field) async {
    String newValue = "";
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Edit $field",
          style: const TextStyle(color: Colors.blue),
        ),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.white), // Change text color to white
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Colors.black),
          ),
          onChanged: (value) {
            newValue = value;
          },
        ),
        actions: [
          // Cancel button
          TextButton(
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.grey[700]),
            ),
            onPressed: () => Navigator.pop(context),
          ),

          // Save button
          TextButton(
            child: Text(
              'Save',
              style: TextStyle(color: Colors.grey[700]),
            ),
            onPressed: () => Navigator.of(context).pop(newValue),
          ),
        ],
      ),
    );

    // Update in Firestore
    if (newValue.trim().length > 0) {
      // Only update if there is something in the text field
      await usersCollection.doc(currentUser.email).update({field: newValue});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 183, 255),
      appBar: AppBar(
        title: const Text("Profile Page"),
        backgroundColor: const Color.fromARGB(255, 38, 97, 185),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection("Users")
            .doc(currentUser.email)
            .snapshots(),
        builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }

          if (!snapshot.hasData || snapshot.data == null) {
            return Center(
              child: const Text('User data not found.'),
            );
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>?;

          if (userData != null) {
            return ListView(
              children: [
                const SizedBox(height: 50),

                // Profile pic
                const Icon(
                  Icons.fitness_center,
                  size: 72,
                ),

                const SizedBox(height: 10),

                // User email
                Text(
                  currentUser.email!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),

                const SizedBox(height: 50),

                // User details
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),

                // Username
                MyTextBox(
                  text: userData['username'],
                  sectionName: 'username',
                  onPressed: () => editField('username'),
                ),

                // Bio
                MyTextBox(
                  text: userData['bio'],
                  sectionName: 'bio',
                  onPressed: () => editField('bio'),
                ),

                const SizedBox(height: 50),

                // User posts
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Posts',
                    style: TextStyle(
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Handle the case where userData is null
            return Center(
              child: const Text('User data is null.'),
            );
          }
        },
      ),
      drawer: myDrawer,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 38, 97, 185),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          // Using Navigator to put a selected page onto the stack
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => tabs[index]),
          );
        },
      ),
    );
  }
}
