import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '/../util/test.dart' as testAPI;
import '../../components/product_card.dart';
import '../../components/dropdown.dart';

class BarcodeLookupPage extends StatefulWidget {
  @override
  State<BarcodeLookupPage> createState() => _BarcodeLookupPageState();
}

class _BarcodeLookupPageState extends State<BarcodeLookupPage> {
  String? barcodeData;

  String productName = '';
  String result = '';
  double productCalories = 0.0;
  String selectedFilter = 'Barcode Result';
  List<String> filterOptions = ['Barcode Result', 'Product Name', 'Calories'];

  Future<void> _scanBarcode() async {
    var scannedBarcode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );
    if (scannedBarcode is String) {
      final productData = await testAPI.getProduct(scannedBarcode);
      setState(() {
        result = scannedBarcode;
        if (productData != null) {
          productName = productData.productName!;
          productCalories = productData.nutriments
                  ?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ??
              0.0;
        } else {
          productName = 'Please try again';
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Lookup'),
        backgroundColor: Color(0xFF83B0FA),
      ),
      body: Container(
        decoration: BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA9B7FF), Color(0xFF83B0FA)],
        )),
        child: Center(
          //will contain widgets
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _scanBarcode,
              child: const Text('Open Scanner'),
            ),

            const SizedBox(height: 20),
            //if (barcodeData != null) Text('Barcode Data: $barcodeData')
            GridView.count(
              crossAxisCount: 2, //makes 2 columns
              //content wrapper
              shrinkWrap: true,

              children: [
                if (result.isNotEmpty)
                  ProductCard(title: 'Barcode Result:', data: result),

                if (productName.isNotEmpty)
                  ProductCard(title: 'Product Name:', data: productName),

                if (productCalories != 0.0)
                  ProductCard(
                      title: "Calories", data: productCalories.toString())

                //Text('Product Name: $productName'),
                //const SizedBox(height: 10),
                //Text('Product Calories: $productCalories')
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
