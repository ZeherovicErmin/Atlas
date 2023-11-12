// Creating a notes application
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

          // Function to create a new note
  void createNewNote(NoteData noteData){
    ref.read(noteDataProvider).addNewNote(
      Note(id: noteData.getAllNotes().length, text: 'New Note'),
    );
  }

  

 

    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F6),
      floatingActionButton: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 75.0, right: 8.0),
          child: FloatingActionButton(
            onPressed: () => createNewNote(noteData),
            elevation: 0,
            child: Icon(CupertinoIcons.pencil)
          ),
        ),
      ),
      body: 
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

          // Displaying the list of notes
          CupertinoListSection.insetGrouped(
            backgroundColor: const Color(0xFFFAF9F6),
            children: 
              List.generate(
                NoteData().getAllNotes().length,
                (index) => CupertinoListTile(
                  title: Text(ref.read(noteDataProvider).getAllNotes()[index].text),
                ),
              ),
          ),
               
          
             
            ],
          ),
    

        
      
    );
  }
}
