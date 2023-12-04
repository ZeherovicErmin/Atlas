//Author: Matthew McGowan
import 'package:flutter/material.dart';

class SignoutButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  const SignoutButton({required this.onPressed, required this.text});

  //Adds button functionality
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.all(25),
        margin: const EdgeInsets.symmetric(horizontal: 125),
        decoration: BoxDecoration(
          color: const Color.fromARGB(255, 246, 81, 81),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }
}