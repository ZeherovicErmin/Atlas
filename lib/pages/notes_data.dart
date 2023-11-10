// The notes data class

import 'package:atlas/pages/notes.dart';

class NoteData {
  // The list of notes
  List<Note> allNotes = [
    // Default first note
    Note(id: 0, text: 'First Note'),
  ];

  // Getting the notes
  List<Note> getAllNotes() {
    return allNotes;
  }

  // Adding a new note
  void addNewNote(Note note) {
    allNotes.add(note);
  }

  // Updating the note
  void updateNote(Note note, String text) {
    // Iterating through the list of the notes
    for (int i = 0; i < allNotes.length; i++) {
      // matching to find the note we want to edit
      if (allNotes[i].id == note.id) {
        // Replacing the text with the new text
        allNotes[i].text = text;
      }
    }
  }

  // Deleting the note
  void deleteNote(Note note) {
    allNotes.remove(note);
  }
}
