// The page that will allow users to edit the notes they create
import 'package:atlas/pages/notes.dart';
import 'package:atlas/pages/notes_data.dart';
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

  // Adding a new note
  void addNewNote(int id) {
    // Getting the text from the editor
    String text = _controller.document.toPlainText();

    // adding the new note
    ref.read(noteDataProvider).addNewNote(
          Note(id: id, text: text),
        );
  }

  // Updating an existing note
  void updateNote() {
    // Get text from the editor
    String text = _controller.document.toPlainText();
    // Update the note
    ref.read(noteDataProvider).updateNote(widget.note, text);
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

              // Its a new note
              if (widget.isNewNote && !_controller.document.isEmpty()) {
                addNewNote(ref.read(noteDataProvider).getAllNotes().length);
              }

              // Else the note is an existing note being edited
              else {
                updateNote();
              }

              // Going back to the notes screen
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
