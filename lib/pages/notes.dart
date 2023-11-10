// Creating a notes application
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Note {
  int id;
  String text;

  Note({
    required this.id,
    required this.text,
  });
}

class NotesPage extends ConsumerWidget {
  const NotesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Using gesture detector to navigate to each specific day of the week page which will house the saved collection of exercises for each day

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(25.0),
            child: Center(
              child: Text('Notes',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ),

          // Displaying the list of notes
          CupertinoListSection.insetGrouped(
            children: [
              CupertinoListTile(
                title: Text('yolo'),
              )
            ],
          )
        ],
      ),
    );
  }
}
