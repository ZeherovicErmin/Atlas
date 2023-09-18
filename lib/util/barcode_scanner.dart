//Code opens the barcode scanner portion
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'test.dart' as testAPI;

Future<void> scanBarcode(
    BuildContext context, Function(String) onBarcodeScanned) async {
  var scannedBarcode = await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => const SimpleBarcodeScannerPage(),
    ),
  );
  if (scannedBarcode is String) {
    final productData = await testAPI.getProduct(scannedBarcode);
    if (productData != null) {
      onBarcodeScanned(scannedBarcode, productData);
    }
  }
}
