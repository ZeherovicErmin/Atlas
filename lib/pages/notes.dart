// Creating a notes application
import 'package:atlas/pages/editing_note_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

  // Converting a note to a map to store in FireStore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'uid': FirebaseAuth.instance.currentUser?.uid ?? '', // Adding the user ID
    };
  }

  // Creating a note from the map
  static Note fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'],
      text: map['text'],
    );
  }
}

class NotesPage extends ConsumerWidget {
  NotesPage({Key? key}) : super(key: key);

  // Creating the collection on Firestore for the notes
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('Notes');

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String userID = FirebaseAuth.instance.currentUser?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 75.0, right: 8.0),
          child: FloatingActionButton(
              onPressed: () {
                // Creating a blank new note
                final newNote =
                    Note(id: DateTime.now().millisecondsSinceEpoch, text: '');

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditingNotePage(note: newNote, isNewNote: true),
                  ),
                ).then((_) {
                  if (newNote.text.isNotEmpty) {
                    notesCollection.add(newNote.toMap());
                  }
                });
              },
              child: const Icon(CupertinoIcons.add)),
        ),
      ),
      body:

          // Padded Title list to match ios
          Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(left: 25.0, top: 25),
            child: Text('Notes',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                )),
          ),

          // Returning an Ios Style List view for the notes
          Expanded(
            child:
                // Gathering the data from Firestore
                StreamBuilder<QuerySnapshot>(
              stream:
                  notesCollection.where("uid", isEqualTo: userID).snapshots(),
              builder: (context, snapshot) {
                // If the data doesn't exist
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                List<DocumentSnapshot> notes = snapshot.data!.docs;
                return ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    DocumentSnapshot doc = notes[index];
                    Note note =
                        Note.fromMap(doc.data() as Map<String, dynamic>);

                    return Dismissible(
                      key: Key(doc.id
                          .toString()), // A key to use in the dismissible function
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        child: const Padding(
                          padding: EdgeInsets.only(right: 20.0),
                          child:
                              Icon(CupertinoIcons.trash, color: Colors.white),
                        ),
                      ),
                      direction: DismissDirection.endToStart,
                      confirmDismiss: (direction) async {
                        // Adding a confirmation popup before the user deletes a workout
                        return await showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text("Confirm"),
                              content: const Text(
                                  "Are you sure you want to delete this note?"),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(false),
                                  child: const Text("CANCEL"),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      Navigator.of(context).pop(true),
                                  child: const Text("DELETE"),
                                ),
                              ],
                            );
                          },
                        );
                      },

                      // After the user confirms they want to delete the note will delete
                      onDismissed: (direction) {
                        // Removing the note when the action is completed
                        notesCollection.doc(doc.id).delete();
                      },
                      child: CupertinoListTile(
                        title: Text(note.text),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  EditingNotePage(note: note, isNewNote: false),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
