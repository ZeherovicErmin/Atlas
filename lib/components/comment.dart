import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Comment extends StatelessWidget {
  final String text;
  final String userId;
  final String time;

  const Comment({
    super.key,
    required this.text,
    required this.userId,
    required this.time,
  });

  Future<String?> fetchUsername() async {
    try {
      // Fetch the user's document from Firestore
      final userDoc = await FirebaseFirestore.instance
          .collection('Users')
          .doc(userId)
          .get();
      if (userDoc.exists) {
        // Get the 'username' field from the user's document
        final username = userDoc.get('username');
        return username;
      }
    } catch (e) {
      print('Error fetching username: $e');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String?>(
      future: fetchUsername(),
      builder: (context, snapshot) {
        final username = snapshot.data;

        if (snapshot.connectionState == ConnectionState.waiting) {
          // Show a loading indicator while fetching the username
          return const CircularProgressIndicator();
        } else if (snapshot.hasError || username == null) {
          // Handle the case where the username couldn't be fetched
          return const Text(
            'User not found',
            style: TextStyle(color: Colors.red),
          );
        } else {
          // Render the comment with the username
          return Container(
            decoration: BoxDecoration(
              color: const Color(0xFFFAF9F6),
              borderRadius: BorderRadius.circular(4),
            ),
            margin: const EdgeInsets.only(bottom: 5),
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //comment
                Text(
                  text,
                  style: const TextStyle(color: Colors.black),
                ),

                const SizedBox(height: 5),

                //user, time
                Row(
                  children: [
                    Text(
                      username, // Display the fetched username
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      " • ",
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    Text(
                      time,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          );
        }
      },
    );
  }
}
