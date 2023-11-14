// Creating a notes application
import 'package:atlas/pages/editing_note_page.dart';
import 'package:atlas/pages/notes_data.dart';
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
    final noteData = ref.watch(noteDataProvider); // instance of note data

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 75.0, right: 8.0),
          child: FloatingActionButton(
              onPressed: () {
                // Creating a blank new note
                final newNote = Note(id: noteData.allNotes.length, text: '');
                // Adding the new note
                noteData.addNewNote(newNote);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        EditingNotePage(note: newNote, isNewNote: true),
                  ),
                );
              },
              child: Icon(CupertinoIcons.add)),
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
            child: CupertinoListSection.insetGrouped(
              backgroundColor: const Color(0xFFFAF9F6),
              children: List.generate(
                noteData.allNotes.length,
                (index) {
                  final note = noteData.allNotes[index];
                  return CupertinoListTile(
                    title: Text(note.text),

                    // If the note is note a new note we simply edit the existing note and navigate accordingly
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              EditingNotePage(note: note, isNewNote: false),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
