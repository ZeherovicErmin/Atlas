import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';


class ProductCard extends StatelessWidget {
  final String title;
  final String data;
  final bool isVisible; // New property to control visibility

  ProductCard({
    required this.title,
    required this.data,
    this.isVisible = true, // Default is visible
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      // Return an empty container if it shouldn't be displayed
      return Container();
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AutoSizeText(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: AutoSizeText(
                data,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                maxLines:
                    10, // Specify the maximum number of lines before text ellipsis
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
