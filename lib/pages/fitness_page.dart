import 'package:atlas/components/text_box.dart';
import 'package:atlas/constants.dart';
import 'package:atlas/pages/home_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FitPage extends StatefulWidget {
  const FitPage({super.key});

  @override
  State<FitPage> createState() => _FitPageState();
}

// Creating tabs to navigate to other pages with navbar
final tabs = [
  const HomePage(),
  const FitPage(),
];

class _FitPageState extends State<FitPage> {
  final currentUser = FirebaseAuth.instance.currentUser!;
  int _currentIndex = 0;

//edit field
  Future<void> editField(String field) async {}

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
          //get user data
          if (snapshot.hasData && snapshot.data!.data() != null) {
            final userData = snapshot.data!.data() as Map<String, dynamic>;

            return ListView(
              children: [
                const SizedBox(height: 50),

                //profile pic
                const Icon(
                  Icons.fitness_center,
                  size: 72,
                ),

                const SizedBox(height: 10),

                //user email
                Text(currentUser.email!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Color.fromARGB(255, 38, 97, 185))),

                const SizedBox(height: 50),

                //user details
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Details',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),

                //username
                MyTextBox(
                  text: userData['Username'],
                  sectionName: 'Username',
                  onPressed: () => editField('Username'),
                ),

                //bio
                MyTextBox(
                  text: userData['Bio'],
                  sectionName: 'Bio',
                  onPressed: () => editField('Bio'),
                ),

                const SizedBox(height: 50),

                //user posts
                const Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: Text(
                    'My Posts',
                    style: TextStyle(color: Color.fromARGB(255, 255, 255, 255)),
                  ),
                ),
              ],
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error${snapshot.error}'),
            );
          }

          return const Center(
            child: CircularProgressIndicator(),
          );
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
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
            // Using Navigator to put a selected page onto the stack
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => tabs[index]),
            );
          }),
    );
  }
}
