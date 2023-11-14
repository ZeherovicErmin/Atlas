// The notes data class

import 'package:atlas/pages/notes.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NoteData extends ChangeNotifier {
  // The list of notes
  List<Note> allNotes = [
    // Default first note
    Note(id: 0, text: 'First Note'),
    Note(id: 1, text: 'Second Note'),
  ];

  // Getting the notes
  List<Note> getAllNotes() {
    return List.from(allNotes);
  }

  // Adding a new note
  void addNewNote(Note note) {
    allNotes.add(note);
    notifyListeners();
    print(allNotes);
  }

  // Updating the note
  void updateNote(Note note, String newText) {
    // Iterating through the list of the notes
    for (int i = 0; i < allNotes.length; i++) {
      // matching to find the note we want to edit
      if (allNotes[i].id == note.id) {
        // Replacing the text with the new text
        allNotes[i] = Note(id: note.id, text: newText);
        break;
      }
    }
    notifyListeners();
  }

  // Deleting the note
  void deleteNote(Note note) {
    allNotes.remove(note);
    notifyListeners();
  }
}

// Creating a notes provider using riverpods
final noteDataProvider = ChangeNotifierProvider<NoteData>((ref) {
  // Initializing NoteData
  return NoteData();
});
