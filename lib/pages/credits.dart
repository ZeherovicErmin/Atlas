//Author: Matthew McGowan
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Credits extends ConsumerWidget {
  const Credits({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: myAppBar4(context, ref, 'Credits and Disclaimer'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Title
            Text(
              'Copyright',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            //Rights Reserved
            Text(
              '© 2023, Atlas. All rights reserved.',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 16),

            //Home page icon credits
            Text(
              'All the icons used on the home page are from, https://www.flaticon.com/',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 16),

            //Openfoodfacts credits
            Text(
              'All the barcode log nutrition facts are pulled from, https://world.openfoodfacts.org/',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 16),

            //Spoonacular credits
            Text(
              'All the recipes are pulled from, https://spoonacular.com/',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 16),

            Text(
              'All the exercises are pulled from, https://api-ninjas.com/api/exercises',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 16),

            Text(
              'All exercise gifs are property of Fitness Programmer and Gym Visual. We do not own any of the intellectual property.',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 16),

            Text(
              'Disclaimer',
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),

            SizedBox(height: 16),

            Text(
              'The exercise information in Atlas is intended for general guidance and shout not replace personalized fitness advice from qualified professionals. We are not liable for any injuries that may arise from following these execise instructions.',
              style: TextStyle(fontSize: 16),
            ),

            SizedBox(height: 16),

            Text(
              'The recipes provided in Atlas are for informational purposes only. We are not responsible for any allergies, illnesses, or adverse reactions that may result from the consumption of the recipes. Users should be aware of their dietary restrictions and consult with healthcare professionals if needed.',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
