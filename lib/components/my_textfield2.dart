//Author: Matthew McGowan
import 'package:flutter/material.dart';

class MyTextField2 extends StatelessWidget {
  final String hintText;

  const MyTextField2(String s, {
    super.key,
    required this.hintText,
  });

  //For the customizing the fields a user can use to type in
  //(username and password text field)
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0),
      child: TextField(
        style: const TextStyle(color: Colors.black),
        decoration: InputDecoration(
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey.shade400),
            ),
            fillColor: Colors.grey.shade200,
            filled: true,
            hintText: hintText,
            hintStyle: TextStyle(color: Colors.grey[500])),
      ),
    );
  }
}
