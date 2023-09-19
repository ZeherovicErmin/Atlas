import 'package:atlas/components/product_card.dart';
import 'package:flutter/material.dart';

// variables that get pushed into generateTileCard
class generateTileCard extends StatelessWidget {
  const generateTileCard({
    super.key,
    required this.result,
    required this.productName,
    required this.productCalories,
    required this.carbsPserving,
    required this.proteinPserving,
    required this.fatsPserving,
    required this.filter,
  });

  final String result;
  final String productName;
  final double productCalories;
  final double carbsPserving;
  final double proteinPserving;
  final double fatsPserving;
  final String filter;

  @override
  Widget build(BuildContext context) {
    // Switch case based on the filter you select. Will be researching
    // how to make this more formless
    switch (filter) {
      case 'Barcode Result':
        return ProductCard(title: 'Barcode Result:', data: result);
      case 'Product Name':
        return ProductCard(
          title: 'Product Name:',
          data: productName,
        );
      case 'Calories':
        return ProductCard(title: 'Calories:', data: '$productCalories');
      case 'testMacros':
        return ProductCard(
            title: "Macros",
            data:
                'Carbs: $carbsPserving\nProtein: $proteinPserving\nFats: $fatsPserving');
      default:
        return SizedBox
            .shrink(); // Return an empty container if no filter matches
    }
  }
}
//AliChowdhury: 9/19/2023: Created Generate Tile Card which allows the user to make each product card and offloads
//the code from Product card and makes it easier to maintain in my opinion