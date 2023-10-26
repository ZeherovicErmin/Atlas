// test.dart

import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

Future<Product?> getProduct(String barcode, BuildContext context) async {
  final ProductQueryConfiguration configuration = ProductQueryConfiguration(
    barcode,
    language: OpenFoodFactsLanguage.ENGLISH,
    version: ProductQueryVersion.v3,
    fields: [ProductField.ALL],
  );

  final ProductResultV3 apiResponse =
      await OpenFoodAPIClient.getProductV3(configuration);

  if (apiResponse.status == ProductResultV3.statusSuccess) {
    return apiResponse.product;
  } else {
    print("test I have failed");
    _showErrorDialog(context, "Wrong Barcode", "Please try again");
    throw Exception('Product not found, please insert data for $barcode');
  }
}

// In case a wrong barcode is scanned
void _showErrorDialog(BuildContext context, String title, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      //Timer to close dialog
      Future.delayed(Duration(seconds: 2), () {
        Navigator.of(context).pop();
      });
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            child: Text('Close'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
