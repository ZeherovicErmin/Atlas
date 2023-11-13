import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class newFeed extends ConsumerWidget {
  const newFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 229, 229),
      body: CustomScrollView(
        slivers: [
          // App bar with title
          SliverAppBar(
            title: Text(
              "F e e d",
              style: TextStyle(
                  fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
            ),
            backgroundColor: Color.fromARGB(255, 0, 136, 204),
            floating: false,
            pinned: false,
          ),
          // Sliver list to display posts
          SliverPadding(
            padding: EdgeInsets.only(bottom: 180),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return _buildPostItem(index, context);
                },
                childCount: 10, // Number of posts
              ),
            ),
          ),
        ],
      ),
      // Input section for posting new content
      bottomSheet: _buildPostInputSection(),
    );
  }

  // Method to build each post item
  Widget _buildPostItem(int index, BuildContext context) {
    // Post container with basic layout
    return Container(
      margin: const EdgeInsets.all(10),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with username and more options icon
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // User profile icon and username
              Row(
                children: [
                  Icon(Icons.account_circle, size: 40.0, color: Colors.grey),
                  SizedBox(width: 10),
                  Text(
                    "Username ${index + 1}",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ],
              ),
              // More options icon
              IconButton(
                icon: Icon(Icons.more_vert, color: Colors.grey),
                onPressed: () => _showPostOptions(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          // Post content section
          Text(
            "This is a sample post content. It can include text and images.",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          const SizedBox(height: 10),
          // Image placeholder
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text("Image Placeholder")),
          ),
          const SizedBox(height: 10),
          // Like and comment icons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Icon(Icons.thumb_up, color: Colors.blue),
              // Comment icon with action to show comments
              IconButton(
                icon: Icon(Icons.comment, color: Colors.grey),
                onPressed: () => _showCommentsModal(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showPostOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: 100,
          child: Column(
            children: <Widget>[
              ListTile(
                leading: Icon(Icons.report),
                title: Text('Report Post'),
                onTap: () {
                  // Add functionality for reporting a post
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildPostInputSection() {
    return Container(
      padding: const EdgeInsets.only(bottom: 75.0),
      margin: const EdgeInsets.all(15.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              maxLength: 150,
              decoration:
                  const InputDecoration(hintText: "Share your progress!"),
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_rounded,
                color: Color.fromARGB(255, 0, 136, 204)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_circle_up,
                color: Color.fromARGB(255, 0, 136, 204)),
          ),
        ],
      ),
    );
  }
}

void _showCommentsModal(BuildContext context) {
  TextEditingController commentController = TextEditingController();

  showModalBottomSheet(
    context: context,
    isScrollControlled:
        true, // Needed to prevent the keyboard from covering the text field
    builder: (BuildContext context) {
      return Padding(
        padding: MediaQuery.of(context)
            .viewInsets, // Adjusts padding based on the keyboard
        child: Container(
          height: 350, // Increased height to accommodate the comment input
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  'Comments',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('User 1'),
                subtitle: Text('Great post!'),
              ),
              ListTile(
                leading: Icon(Icons.account_circle),
                title: Text('User 2'),
                subtitle: Text('I totally agree!'),
              ),
              // Comments
              Divider(),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: commentController,
                        decoration:
                            InputDecoration(hintText: "Write a comment..."),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.send,
                          color: Color.fromARGB(255, 0, 136, 204)),
                      onPressed: () {
                        // handle the logic to post the comment

                        commentController.clear();
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
