// test.dart

import 'package:openfoodfacts/openfoodfacts.dart';

Future<Product?> getProduct(String barcode) async {
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
    throw Exception('Product not found, please insert data for $barcode');
  }
}
