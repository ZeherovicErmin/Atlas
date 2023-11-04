import 'package:atlas/components/comment.dart';
import 'package:atlas/components/comment_button.dart';
import 'package:atlas/components/delete_button.dart';
import 'package:atlas/components/like_button.dart';
import 'package:atlas/components/productHouser.dart';
import 'package:atlas/helper/helper_method.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FeedPost extends StatefulWidget {
  final String message;
  final String user;
  final String time;
  final String postId;
  final List<String> likes;
  final Map<String, dynamic>? barcodeData;
  final String email;
  const FeedPost(
      {super.key,
      required this.message,
      required this.user,
      required this.postId,
      required this.likes,
      required this.time,
    required this.email,
      this.barcodeData});

  @override
  State<FeedPost> createState() => _FeedPostState();
}

class _FeedPostState extends State<FeedPost> {
  //user
  final currentUser = FirebaseAuth.instance.currentUser!;

  bool isLiked = false;
  final _commentTextController = TextEditingController();
  //List of widgets to include in the barcode sharing

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
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      margin: const EdgeInsets.only(top: 25, left: 25, right: 25),
      padding: const EdgeInsets.all(25),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // feed post
        Wrap(
          spacing: 8.0,
          direction: Axis.horizontal,
          //mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.start,
          children: [
            // group of text (message + username)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                //message
                Text(
                  widget.message,
                  style: const TextStyle(color: Colors.black),
                  maxLines: null,
                ),
                // Only display specific barcode data entries
                Card(
                  shape: RoundedRectangleBorder(
                      side: const BorderSide(color: Colors.black, width: 3.0),
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: 16, top: 16, bottom: 8, right: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.barcodeData != null &&
                            widget.barcodeData!.isNotEmpty)
                          ...widget.barcodeData!.entries
                              .where((entry) =>
                                  entry.key == 'productName' ||
                                  entry.key == 'proteinPerServing' ||
                                  entry.key == 'carbsPerServing' ||
                                  entry.key == 'fatsPerServing' ||
                                  entry.key ==
                                      'cholesterolPerServing') // Filter specific keyshere
                              .map(socialBarcode)
                              .toList(),
                        const SizedBox(height: 5),
                      ],
                    ),
                  ),
                ),

                //user + day
                Row(
                  children: [
                    Text(
                      widget.user.trim(),
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Text(
                      " • ",
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                    Text(
                      widget.time,
                      style: TextStyle(color: Colors.grey[500]),
                    ),
                  ],
                ),
              ],
            ),

            //delete button
            //  if (currentUser.email == widget.email)
            //    DeleteButton(onTap: deletePost),

            Align(
              alignment: Alignment.topRight,
              child: currentUser.email == widget.email
                  ? DeleteButton(onTap: deletePost)
                  : const SizedBox(),
            ),
          ],
        ),

        const SizedBox(height: 20),

        // buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            //LIKE
            Column(
              children: [
                //like button
                LikeButton(
                  isLiked: isLiked,
                  onTap: toggleLike,
                ),

                const SizedBox(height: 5),

                //like count
                Text(
                  widget.likes.length.toString(),
                  style: const TextStyle(color: Colors.grey),
                ),
              ],
            ),

            const SizedBox(width: 15),

            //COMMENT
            Column(
              children: [
                //comment button
                CommentButton(onTap: showCommentDialog),

                const SizedBox(height: 5),

                //comment count
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      //Calculate the comment count
                      final commentCount = snapshot.data?.docs.length;
                      return Text(
                        commentCount.toString(),
                        style: const TextStyle(color: Colors.grey),
                      );
                    } else {
                      // show a loading indicator while fetching data
                      return const CircularProgressIndicator();
                    }
                  },
                )
              ],
            ),
          ],
        ),

        const SizedBox(height: 20),

        //comments under the post
        Column(
          children: [
            ExpansionTile(
              backgroundColor: Colors.grey[200],
              title: Text('View Comments',
                  style: TextStyle(color: Colors.grey[500])),
              children: [
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection("User Posts")
                      .doc(widget.postId)
                      .collection("Comments")
                      .orderBy("CommentTime", descending: true)
                      .snapshots(),
                  builder: (context, snapshot) {
                    //show loading circle if theres no data
                    if (!snapshot.hasData) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }

                    return ListView(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      children: snapshot.data!.docs.map((doc) {
                        //get the comment
                        final commentData = doc.data() as Map<String, dynamic>;

                        //return the comment
                        return Comment(
                          text: commentData["CommentText"],
                          user: commentData["CommentedBy"],
                          time: formatDate(commentData["CommentTime"]),
                        );
                      }).toList(),
                    );
                  },
                )
              ],
            ),
          ],
        ),
      ]),
    );
  }

  Column socialBarcode(MapEntry<String, dynamic> entry) {
    // Capitalize the first letter of each word, and remove 'PerServing'
    String keyText = entry.key
        .replaceAll(RegExp(r'PerServing'), '')
        .split(' ')
        .map((str) => str[0].toUpperCase() + str.substring(1))
        .join(' ');

    // Check if the entry is 'productName' and format it differently
    if (entry.key == 'productName') {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        AutoSizeText(
          '${entry.value.toString()}',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          textAlign: TextAlign.left,
        ),
      ]);
    } else {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Divider(),
        AutoSizeText(
          '$keyText: ${entry.value}',
          style: const TextStyle(fontWeight: FontWeight.bold),
          maxLines: 1,
          textAlign: TextAlign.left,
        ),
      ]);
    }
  }

  //show dialog box to add a comment
  void showCommentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        //title: const Text("Add Comment"),
        content: TextField(
          maxLength: 100,
          controller: _commentTextController,
          decoration: const InputDecoration(hintText: "Add a comment..."),
        ),
        actions: [
          //cancel button
          TextButton(
            onPressed: () {
              //pop box
              Navigator.pop(context);

              //clear controller
              _commentTextController.clear();
            },
            child: const Text("Cancel"),
          ),

          //post button
          TextButton(
            onPressed: () {
              //add comment
              addComment(_commentTextController.text);

              //pop box
              Navigator.pop(context);

              //clear controller
              _commentTextController.clear();
            },
            child: const Text("Post"),
          ),
        ],
      ),
    );
  }

  // delete a post
  void deletePost() {
    //show a dialog box for asking for confirmation before deleting the post
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Delete Post"),
        content: const Text("Are you sure you want to delete this post?"),
        actions: [
          //CANCEL BUTTON
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),

          //DELETE BUTTON
          TextButton(
            onPressed: () async {
              //delete the comments from firestore first
              //(if you only delete the post, the comments will still be stored in firestore)
              final commentDocs = await FirebaseFirestore.instance
                  //Change back to User Posts
                  .collection("User Posts")
                  .doc(widget.postId)
                  .collection("Comments")
                  .get();

              for (var doc in commentDocs.docs) {
                await FirebaseFirestore.instance
                    //Change back to User Posts
                    .collection("User Posts")
                    .doc(widget.postId)
                    .collection("Comments")
                    .doc(doc.id)
                    .delete();
              }

              // delete the post
              FirebaseFirestore.instance

                  ///Change back to User Posts
                  .collection("User Posts")
                  .doc(widget.postId)
                  .delete()
                  .then((value) => print("post deleted"))
                  .catchError(
                      (error) => print("failed to delete post: $error"));

              // dismiss the dialog
              Navigator.pop(context);
            },
            child: const Text("Delete"),
          ),
        ],
      ),
    );
  }

  addComment(String commentText) {
    // write the comment to firestore
    FirebaseFirestore.instance
        .collection("User Posts")
        .doc(widget.postId)
        .collection("Comments")
        .add({
      "CommentText": commentText,
      "CommentedBy": currentUser.email,
      "CommentTime": Timestamp.now() //format when displaying
    });
  }
}
