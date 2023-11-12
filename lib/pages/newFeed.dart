import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class newFeed extends ConsumerWidget {
  const newFeed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 232, 229, 229),
      appBar: AppBar(
        title: const Center(
          child: Text(
            "F e e d",
            style: TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
          ),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 136, 204),
      ),
      body: Column(
        children: [
          // Feed Content
          Expanded(
            child: ListView.builder(
              itemCount: 10, // Sample data count
              itemBuilder: (context, index) {
                return _buildPostItem(index);
              },
            ),
          ),

          // Post Message/Image Section
          _buildPostInputSection(),
        ],
      ),
    );
  }

  Widget _buildPostItem(int index) {
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
          // User Profile and Name
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
          const SizedBox(height: 10),
          Text(
            "This is a sample post content. It can include text and images.",
            style: TextStyle(color: Colors.black.withOpacity(0.6)),
          ),
          const SizedBox(height: 10),
          Container(
            height: 200,
            color: Colors.grey[300],
            child: const Center(child: Text("Image Placeholder")),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Icon(Icons.thumb_up, color: Colors.blue),
              Icon(Icons.comment, color: Colors.grey),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPostInputSection() {
    return Container(
      padding: const EdgeInsets.all(15.0),
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
              decoration: const InputDecoration(hintText: "Share your progress!"),
              obscureText: false,
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.add_a_photo_rounded, color: Color.fromARGB(255, 0, 136, 204)),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_circle_up, color: Color.fromARGB(255, 0, 136, 204)),
          ),
        ],
      ),
    );
  }
}
