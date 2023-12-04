//Author: Matthew McGowan
import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class Credits extends ConsumerWidget {
  const Credits({super.key});

@override
Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: myAppBar4(context, ref, 'Credits'),
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            //Title
            Text(
              'Copyright',
              style:
              TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold
              ),
            ),

            SizedBox(height: 16),

            //Rights Reserved
            Text(
              '© 2023, Atlas. All rights reserved.',
              style:
              TextStyle(
                fontSize: 16
              ),
            ),

            SizedBox(height: 16),

            //Home page icon credits
            Text(
              'All the icons used on the home page are from, https://www.flaticon.com/',
              style:
              TextStyle(
                fontSize: 16
              ),
            ),

            SizedBox(height: 16),

            //Openfoodfacts credits
            Text(
              'All the barcode log nutrition facts are pulled from, https://world.openfoodfacts.org/',
              style:
              TextStyle(
                fontSize: 16
              ),
            ),

            SizedBox(height: 16),

            //Spoonacular credits
            Text(
              'All the recipes are pulled from, https://spoonacular.com/',
              style:
              TextStyle(
                fontSize: 16
              ),
            ),
          ],
        ),
      ),
    );
  }
}