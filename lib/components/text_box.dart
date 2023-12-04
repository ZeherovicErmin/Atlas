//Hussein
import "package:flutter/material.dart";

class MyTextBox extends StatelessWidget {
  final String text;
  final String sectionName;
  final void Function()? onPressed;

  const MyTextBox({
    super.key,
    required this.text,
    required this.sectionName,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 232, 229, 229),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: const EdgeInsets.only(left: 15, bottom: 15),
      margin: const EdgeInsets.only(left: 20, right: 20, top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // section name
              Text(
                sectionName,
                style: TextStyle(
                  color: Colors.grey[700],
                ),
              ),

              //edit button
              IconButton(
                onPressed: onPressed,
                icon: const Icon(
                  Icons.edit,
                  color: Color.fromARGB(255, 0, 136, 204),
                ),
              ),
            ],
          ),

          //text
          Text(text),
        ],
      ),
    );
  }
}
