import 'package:atlas/components/my_textfield.dart';
import 'package:atlas/components/text_box.dart';
import 'package:atlas/pages/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:atlas/main.dart';

class UserProfile extends ConsumerWidget {
  const UserProfile({Key? key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final usersCollection = FirebaseFirestore.instance.collection("Users");
    final _currentIndex = ref.watch(selectedIndexProvider);

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
            style: TextStyle(
                color: const Color.fromARGB(
                    255, 0, 0, 0)), // Change text color to white
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
      if (newValue.trim().isNotEmpty) {
        // Only update if there is something in the text field
        await usersCollection.doc(currentUser.email).update({field: newValue});
      }
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 169, 183, 255),
      appBar: myAppBar2(context, ref, 'User Profile'),
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
                  text: userData?['username']?.toString() ??
                      '', // Safely access username
                  sectionName: 'Username',
                  onPressed: () => editField('username'),
                ),

                // Bio
                MyTextBox(
                  text: userData?['bio']?.toString() ?? '', // Safely access bio
                  sectionName: 'Bio',
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
      /*drawer: myDrawer,
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
          ref.read(selectedIndexProvider.notifier).state = index;
          // Using Navigator to put a selected page onto the stack
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => tabs[index]),
          );
        },
      ),*/
    );
  }
}
