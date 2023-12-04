//Hussein 
import "package:flutter/material.dart";

class MyTextBox2 extends StatelessWidget {
  final String text;
  final String sectionName;

  const MyTextBox2({
    super.key,
    required this.text,
    required this.sectionName,
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
            ],
          ),

          const SizedBox(height: 10),

          //text
          Text(text),
        ],
      ),
    );
  }
}
