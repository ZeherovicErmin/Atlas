import 'package:flutter/material.dart';

class MyTextfield extends StatefulWidget {
  final Function(String) onChanged;

  MyTextfield({super.key, required this.onChanged});

  @override
  _MyTextfieldState createState() => _MyTextfieldState();
}

class _MyTextfieldState extends State<MyTextfield> {
  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: const InputDecoration(
        labelText: 'Enter Barcode',
        border: OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
}
