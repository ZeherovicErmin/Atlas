// The page that will allow users to edit the notes they create
import 'package:atlas/pages/notes.dart';
import 'package:atlas/pages/notes_data.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Creating the class to edit the notes
class EditingNotePage extends ConsumerStatefulWidget {
  final Note note;
  final bool isNewNote;

  // Constructing the new page
  const EditingNotePage({
    Key? key,
    required this.note,
    required this.isNewNote,
  }) : super(key: key);

  @override
  _EditingNotePageState createState() => _EditingNotePageState();
}

class _EditingNotePageState extends ConsumerState<EditingNotePage> {
  // Creating an instance of the Quill Controller
  late QuillController _controller;

  // Adding a reference to the firestore colleciton
  final CollectionReference notesCollection =
      FirebaseFirestore.instance.collection('Notes');

  final String userID = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void initState() {
    super.initState();
    loadExistingNote();
  }

  // Loading an existing note if it exists
  void loadExistingNote() {
    final doc = Document()..insert(0, widget.note.text);
    setState(() {
      _controller = QuillController(
          document: doc, selection: const TextSelection.collapsed(offset: 0));
    });
  }

  // Updating an existing note
  void savingNote() async {
    // Get text from the editor
    String text = _controller.document.toPlainText();

    // If the note doesn't already exist in Firestore
    if (widget.isNewNote) {
      if (text.isNotEmpty) {
        await notesCollection.add({
          'text': text,
          'uid': userID,
          'id': DateTime.now().millisecondsSinceEpoch,
        });
      }
    } else {
      await notesCollection
          .doc(widget.note.id.toString())
          .update({'text': text});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          elevation: 0,
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.black,
            ),
            onPressed: () {
              // Adding logic on how to navigate / proceed depending on whether or not its a new note or existing note

              savingNote(); // Going back to the notes screen
              Navigator.pop(context);
            },
          )),
      body: QuillProvider(
          configurations: QuillConfigurations(
            controller: _controller,
            sharedConfigurations: const QuillSharedConfigurations(
              locale: Locale('de'),
            ),
          ),
          child: Column(
            children: [
              // The toolbar
              const QuillToolbar(
                configurations: QuillToolbarConfigurations(
                  // Removing unnecessary elements
                  showAlignmentButtons: false,
                  showBackgroundColorButton: false,
                  showCenterAlignment: false,
                  showColorButton: false,
                  showCodeBlock: false,
                  showDirection: false,
                  showFontFamily: false,
                  showDividers: false,
                  showIndent: false,
                  showHeaderStyle: false,
                  showLink: false,
                  showSearchButton: false,
                  showInlineCode: false,
                  showQuote: false,
                  showListNumbers: false,
                  showListBullets: false,
                  showClearFormat: false,
                  showBoldButton: false,
                  showFontSize: false,
                  showItalicButton: false,
                  showUnderLineButton: false,
                  showStrikeThrough: false,
                  showListCheck: false,
                  showSubscript: false,
                  showSuperscript: false,
                ),
              ),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(25),
                  child: QuillEditor.basic(
                    configurations: const QuillEditorConfigurations(
                      readOnly: false,
                    ),
                  ),
                ),
              )
            ],
          )),
    );
  }
}
