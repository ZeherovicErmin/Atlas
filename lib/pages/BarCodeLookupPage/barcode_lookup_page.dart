import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/../util/test.dart' as testAPI;
import '../../components/product_card.dart';
import 'barcode_log_page.dart';

class BarcodeLookupPage extends StatefulWidget {
  @override
  State<BarcodeLookupPage> createState() => _BarcodeLookupPageState();
}

class _BarcodeLookupPageState extends State<BarcodeLookupPage> {
  // Variables for barcode lookup
  String? barcodeData;

  String productName = '';
  String result = '';
  double productCalories = 0.0;
  double fatsPserving = 0.0;
  double carbsPserving = 0.0;
  double proteinPserving = 0.0;
  // List of selectedFilters the user wants to see
  List<String> selectedFilters = [];
  // List of filter options the user can select
  List<String> filterOptions = [
    'Barcode Result',
    'Product Name',
    'Calories',
    'testMacros',
  ];
  //hold selectedData from the User
  Map<String, dynamic> selectedData = {};

  //Code opens the barcode scanner portion
  Future<void> _scanBarcode() async {
    var scannedBarcode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    //Functionality to determine if Scanned code is UPC or barcode
    if (scannedBarcode is String) {
      //debugging UPC
      //
      print("UPC before: " + scannedBarcode);
      scannedBarcode = isValidUPC(scannedBarcode);
      print("UPC after: " + scannedBarcode);
      if (isValidBarcode(scannedBarcode)) {
        final productData = await testAPI.getProduct(scannedBarcode);
        setState(() {
          //inform program of these changes
          result = scannedBarcode;
          if (productData != null) {
            productName = productData.productName!;
            productCalories = productData.nutriments
                    ?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ??
                0.0;
            carbsPserving = productData.nutriments?.getValue(
                    Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
                0.0;
            proteinPserving = productData.nutriments
                    ?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ??
                0.0;
            fatsPserving = productData.nutriments
                    ?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ??
                0.0;
          } else {
            productName = 'Please try again';
          }
          //store data
          selectedData = {
            'Barcode': result,
            'productName': productName,
            'productCalories': productCalories,
            'carbsPerServing': carbsPserving,
            'proteinPerServing': proteinPserving,
            'fatsPerServing': fatsPserving,
          };
          sendDataToFirestore({});
        });
      } else {
        //Handle invalid barcode or UPC code
        setState(() {
          result = 'Invalid Barcode/UPC Code';
          productName = 'Please try again';
        });
      }
    }
  }

  // isValidBarcode Function
  bool isValidBarcode(String barcode) {
    print("barcode: $barcode");
    //RegExp for valid barcode
    //12 digit barcode
    // RegExp assigns 12 digit string to barcodePattern
    final RegExp barcodePattern = RegExp(r'^\d{13}$');
    // Does barcodePattern match the barcode?
    return barcodePattern.hasMatch(barcode);
  }

// Function to check for UPC code
  String isValidUPC(String barcode) {
    print("UPC: $barcode");
    // Define the regExp pattern
    final RegExp barcodePattern =
        RegExp(r'^\d{12}$'); // Updated pattern to match 11 digits
    // Check if the UPC code matches the pattern
    if (barcodePattern.hasMatch(barcode)) {
      // Add "0" in the beginning and check again
      final modifiedBarcode = '0$barcode';
      print("UPC modified: " + modifiedBarcode);
      return modifiedBarcode;
    }
    //returns barcodePattern.hasMatch(modifiedBarcode);
    print("UPC barcode(not transitioned): $barcode");
    return barcode;
  }

  // Function for changing the filters
  void _onFilterChanged(String newFilter) {
    //? = null check
    setState(() {
      //This chunk lets you filter out which portions you want in the code
      if (selectedFilters.contains(newFilter)) {
        selectedFilters.remove(newFilter);
      } else {
        selectedFilters.add(newFilter);
      }
    });
  }

  // Function to send data to Firebase/FireStore
  Future<void> sendDataToFirestore(Map<String, dynamic> data) async {
    try {
      if (selectedData.isNotEmpty) {
        await FirebaseFirestore.instance
            //Collection in Firebase for the Barcode logs and lookup
            .collection('Barcode_Lookup')
            .add(selectedData);
        print("Data to FireStore sent!!!");
      } else {
        print("No data selected");
      }
    } catch (e) {
      print('Error sending data: Error: $e');
    }
  }
// Function to generate a sample card based on the selected filter

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Barcode Lookup'),
        backgroundColor: Color(0xFF83B0FA),
      ),
      body: Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA9B7FF), Color(0xFF83B0FA)],
        )),
        child: SingleChildScrollView(
          child: Center(
            //will contain widgets
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                //FilterChip widget here
                Wrap(
                  children: filterOptions.map((filter) {
                    return FilterChip(
                      // This filter allows the user to select the nutritional information they want to see
                      label: Text(filter),
                      selected: selectedFilters.contains(filter),
                      onSelected: (isSelected) {
                        _onFilterChanged(filter);
                      },
                    );
                  }).toList(),
                ),
                // Button that opens the barcode scanner portion
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _scanBarcode,
                  child: const Text('Open Scanner'),
                ),
                const SizedBox(height: 20),
                //Button to send user to a log of barcodes page
                ElevatedButton(
                    //Navigator to create the log page
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => BarcodeLogPage()),
                      );
                    },
                    child: const Text("Barcode logs")),
                //if (barcodeData != null) Text('Barcode Data: $barcodeData')
                GridView.count(
                  crossAxisCount: 2, //makes 2 columns

                  //content wrapper
                  shrinkWrap: true,

                  //reads off the results of the callback
                  //9/16/2023: Adding selected Filter into the mix
                  children: [
                    if (selectedFilters.isNotEmpty)
                      ...selectedFilters.map((filter) {
                        //print('here');
                        return Container(
                          child: generateTileCard(
                              result: result,
                              productName: productName,
                              productCalories: productCalories,
                              carbsPserving: carbsPserving,
                              proteinPserving: proteinPserving,
                              fatsPserving: fatsPserving,
                              filter: filter),
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
//AliChowdhury: 9/16/2023: added barcode and filter dropdown
//AliChowdhury: 9/19/2023: Added Generate Tile card and creating firebase collection

class generateTileCard extends StatelessWidget {
  const generateTileCard({
    //variables for each of the components
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
        return const SizedBox
            .shrink(); // Return an empty container if no filter matches
    }
  }
}
//AliChowdhury: 9/16/2023: added barcode and filter dropdown