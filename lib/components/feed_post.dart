import 'package:atlas/components/like_button.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedPost extends StatefulWidget {
  final String message;
  final String user;
  final String postId;
  final List<String> likes;
  const FeedPost({
    super.key,
    required this.message,
    required this.user,
    required this.postId,
    required this.likes,
  });

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;
  bool isLiked = false;

  @override
  void initState() {
    super.initState();
    isLiked = widget.likes.contains(currentUser.email);
  }

  //toggle like
  void toggleLike() {
    setState(() {
      isLiked = !isLiked;
    });

    //Access the document in Firebase
    DocumentReference postRef =
        FirebaseFirestore.instance.collection('User Posts').doc(widget.postId);

    if (isLiked) {
      //if post is liked add users email to Likes field
      postRef.update({
        'Likes': FieldValue.arrayUnion([currentUser.email])
      });
    } else {
      //if post is unliked remove the users email from the Likes field
      postRef.update({
        'Likes': FieldValue.arrayRemove([currentUser.email])
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Column(
            children: [
              //like button
              LikeButton(
                isLiked: isLiked,
                onTap: toggleLike,
              ),

              const SizedBox(height: 5),

              //like count
              Text(widget.likes.length.toString(),
                  style: const TextStyle(color: Colors.grey)),
            ],
          ),
          const SizedBox(width: 20),
          //message and user email
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.user,
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Text(widget.message),
            ],
          )
        ],
      ),
    );
  }
}
