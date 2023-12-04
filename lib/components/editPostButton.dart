//Hussein 
import 'package:flutter/material.dart';

class editButton extends StatelessWidget {
  final void Function()? onTap;
  const editButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: const Icon(
        Icons.edit,
        color: Colors.grey,
      ),
    );
  }
}
