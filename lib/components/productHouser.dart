import 'package:atlas/components/product_card.dart';
import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/constants.dart';
//import 'package:atlas/util/custom_scanner.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../util/test.dart' as testAPI;

// Define state providers for various data
final barcodeProvider = StateProvider<String?>((ref) => null);
final productNameProvider = StateProvider<String>((ref) => '');
final productNamelowercaseProvider = StateProvider<String>((ref) => '');

final resultProvider = StateProvider<String>((ref) => '');
final productCaloriesProvider = StateProvider<double>((ref) => 0.0);
//amount of servings a container has provider
final amtServingsProvider = StateProvider<double>((ref) => 0.0);

// Defining fats
final fatsPservingProvider = StateProvider<double>((ref) => 0.0);
final satfatsPservingProvider = StateProvider<double>((ref) => 0.0);
final transfatsPservingProvider = StateProvider<double>((ref) => 0.0);
// Carbs Per Serving
final carbsPservingProvider = StateProvider<double>((ref) => 0.0);
final proteinPservingProvider = StateProvider<double>((ref) => 0.0);
final cholesterolProvider = StateProvider<double>((ref) => 0.0);

// Sodium per serving
final sodiumPservingProvider = StateProvider<double>((ref) => 0.0);
final selectedFiltersProvider = StateProvider<List<String>>((ref) => []);
final selectedDataProvider = StateProvider<List<DataItem>>((ref) => []);
final uidProvider = StateProvider<String>((ref) => '');

//sugar
final sugarsPservingProvider = StateProvider<double>((ref) => 0.0);

// Create an instance of FirebaseAuth
final FirebaseAuth auth = FirebaseAuth.instance;

// Get the current user (if logged in)
final user = auth.currentUser;

// Get the user's UID (if available)
final uid = user?.uid;

// Define a data item class
class DataItem {
  final String category;
  final dynamic value;

  DataItem(this.category, this.value);
}

class BarcodeLookupComb extends ConsumerWidget {
  // Define a list of filter options
  final List<String> filterOptions = [
    'Barcode Result',
    'Product Name',
    'Calories',
    'Macros',
    'Cholesterol'
  ];

  BarcodeLookupComb({Key? key}) : super(key: key);
  // Function to scan a barcode
  Future<void> scanBarcode(BuildContext context, WidgetRef ref) async {
    // Use the barcode scanner page from the simple_barcode_scanner library
    var scannedBarcode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (scannedBarcode is String) {
      // Normalize UPC code if needed
      scannedBarcode = isValidUPC(scannedBarcode);

      // Check if the barcode is valid
      if (isValidBarcode(scannedBarcode)) {
        try {
          // Retrieve product data using the openfoodfacts library
          final productData = await testAPI.getProduct(scannedBarcode, context);

          // Set the scanned barcode as the result
          ref.watch(resultProvider.notifier).state = scannedBarcode;

          if (productData != null) {
            // Set product name or 'Unknown product name' if not available
            ref.watch(productNameProvider.notifier).state =
                productData.productName != null
                    ? productData.productName!
                    : "Unknown product name";
            // Set product calories, carbs, protein, and fats per serving
            ref.watch(productCaloriesProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.energyKCal, PerSize.serving) ??
                0.0;

            ref.watch(carbsPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.carbohydrates, PerSize.serving) ??
                0.0;
            ref.watch(proteinPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.proteins, PerSize.serving) ??
                0.0;
            // Fats per serving
            ref.watch(fatsPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.fat, PerSize.serving) ??
                0.0;

            ref.watch(satfatsPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.saturatedFat, PerSize.serving) ??
                0.0;

            ref.watch(transfatsPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.transFat, PerSize.serving) ??
                0.0;

            ref.watch(cholesterolProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.cholesterol, PerSize.serving) ??
                0.0;
            ref.watch(amtServingsProvider.notifier).state =
                productData.servingQuantity != null
                    ? productData.servingQuantity!
                    : 0.0;
            ref.watch(sodiumPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.sodium, PerSize.serving) ??
                0.0;
            // Sugar per serving
            ref.watch(sugarsPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.sugars, PerSize.serving) ??
                0.0;

            // Set the user's UID as a state
            ref.watch(uidProvider.notifier).state = uid.toString();
          } else {
            // Set error messages if product data is not found
            ref.watch(productNameProvider.notifier).state = 'Please try again';
            ref.watch(productCaloriesProvider.notifier).state = 0.0;
            throw Exception(
                'Product not found, please insert data for $scannedBarcode');
          }

          // Create a list of data items and set it as a state
          ref.read(selectedDataProvider.notifier).state = [
            DataItem('uid', ref.read(uidProvider.notifier).state),
            DataItem('Barcode', scannedBarcode),
            DataItem(
                'productName', ref.read(productNameProvider.notifier).state),
            DataItem('productCalories',
                ref.read(productCaloriesProvider.notifier).state),
            DataItem('carbsPerServing',
                ref.read(carbsPservingProvider.notifier).state),
            DataItem('proteinPerServing',
                ref.read(proteinPservingProvider.notifier).state),
            DataItem('fatsPerServing',
                ref.read(fatsPservingProvider.notifier).state),
            DataItem('cholesterolPerServing',
                ref.read(cholesterolProvider.notifier).state),
            DataItem('amtServingsProvider',
                ref.read(amtServingsProvider.notifier).state),
            DataItem('satfatsPserving',
                ref.read(satfatsPservingProvider.notifier).state),
            DataItem('transfatsPserving',
                ref.read(transfatsPservingProvider.notifier).state),
            DataItem('sodiumPerServing', ref.read(sodiumPservingProvider.notifier).state),
            DataItem('productName_lowercase',
                ref.read(productNameProvider).toLowerCase()),
            DataItem(
              'sugarsPerServing',
              ref.read(sugarsPservingProvider.notifier).state,
            )
          ];
          
          showModalBottomSheet(
            context: context,
            builder: (context) {
              return NutritionContainer(amtPerServing: 0.0,
              productCalories:  ref.read(productCaloriesProvider.notifier).state,
              carbsPserving: ref.read(carbsPservingProvider.notifier).state,
              fatsPserving: ref.read(fatsPservingProvider.notifier).state,
              transfatsPserving: ref.read(transfatsPservingProvider.notifier).state,
              proteinPserving: ref.read(proteinPservingProvider.notifier).state,
              sodiumPerServing: ref.read(sodiumPservingProvider.notifier).state,
              cholesterolPerServing: ref.read(cholesterolProvider.notifier).state,
              satfatsPserving: ref.read(satfatsPservingProvider.notifier).state,
              sugarsPerServing: ref.read(sugarsPservingProvider.notifier).state,
              
              );
            },
          );
          // Send data to Firestore
          sendDataToFirestore(
              context, ref, {}, ref.read(productNameProvider.notifier).state);
        } catch (e) {
          // Set error messages if an exception occurs
          ref.watch(resultProvider.notifier).state =
              'Product not found'; // Set an appropriate message
          ref.watch(productNameProvider.notifier).state = 'Please try again';
          ref.watch(productCaloriesProvider.notifier).state = 0.0;
          ref.watch(proteinPservingProvider.notifier).state = 0.0;
          ref.watch(carbsPservingProvider.notifier).state = 0.0;
          ref.watch(fatsPservingProvider.notifier).state = 0.0;
          ref.watch(cholesterolProvider.notifier).state = 0.0;
          ref.watch(amtServingsProvider.notifier).state = 0.0;
          ref.watch(satfatsPservingProvider.notifier).state = 0.0;
          ref.watch(transfatsPservingProvider.notifier).state = 0.0;
          ref.watch(sodiumPservingProvider.notifier).state = 0.0;
          ref.watch(sugarsPservingProvider.notifier).state = 0.0;
        }
      } else {
        // Set error messages for an invalid barcode
        ref.watch(resultProvider.notifier).state = 'Invalid Barcode/UPC Code';
        ref.watch(productNameProvider.notifier).state = 'Please try again';
        ref.watch(productCaloriesProvider.notifier).state = 0.0;
        ref.watch(proteinPservingProvider.notifier).state = 0.0;
        ref.watch(carbsPservingProvider.notifier).state = 0.0;
        ref.watch(fatsPservingProvider.notifier).state = 0.0;
        ref.watch(cholesterolProvider.notifier).state = 0.0;
        ref.watch(amtServingsProvider.notifier).state = 0.0;
        ref.watch(satfatsPservingProvider.notifier).state = 0.0;
        ref.watch(transfatsPservingProvider.notifier).state = 0.0;
        ref.watch(sodiumPservingProvider.notifier).state = 0.0;
        ref.watch(sugarsPservingProvider.notifier).state = 0.0;
      }
    }
  }

  // Function to check if a barcode is valid
  bool isValidBarcode(String barcode) {
    final RegExp barcodePattern = RegExp(r'^\d{13}$');
    //UPC -E
    final RegExp upcE = RegExp(r'^\d{8}$');
    return barcodePattern.hasMatch(barcode) || upcE.hasMatch(barcode);
  }

  // Function to normalize UPC code
  String isValidUPC(String barcode) {
    final RegExp barcodePattern = RegExp(r'^\d{12}$');
    //UPC -E
    final RegExp upcE = RegExp(r'^\d{8}$');

    if (barcodePattern.hasMatch(barcode)) {
      final modifiedBarcode = '0$barcode';
      return modifiedBarcode;
    } else if (upcE.hasMatch(barcode)) {
      return barcode;
    } else {
      return barcode;
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {


    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
          leading: const Icon(
            null,
          ),
        title: const Text(
          "Barcode Lookup",
          style:
              TextStyle(fontFamily: 'Open Sans', fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color.fromARGB(255, 0, 136, 204),
      ),
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          //const SizedBox(height: 20),
          // Button to open the barcode scanner

          //const SizedBox(height: 20),
          // Button to navigate to barcode logs

          BarcodeLogPage(),
          Positioned(
              right: 16,
              bottom: 100,
              child: ElevatedButton(
                onPressed: () => scanBarcode(context, ref),
                child: const Icon(
                  CupertinoIcons.barcode_viewfinder,
                  size: 50,
                ),
              )),
          // NutrientsList(
          //     selectedFilters: selectedFilters,
          //     result: result,
          //     productName: productName,
          //     productCalories: productCalories,
          //     carbsPserving: carbsPserving,
          //     proteinPserving: proteinPserving,
          //     fatsPserving: fatsPserving,
          //     cholesterolPerServing: cholesterolPerServing,
          //     amtPerServing: amtPerServing,
          //     satfatsPserving: satfatsPserving,
          //     transfatsPserving: transfatsPserving,
          //     sodiumPerServing: sodiumPerServing,
          //     sugarsPerServing: sugarsPerServing),
        ],
      ),
    );
  }
}

// Function to send data to Firestore
Future<void> sendDataToFirestore(BuildContext context, WidgetRef ref,
    Map<String, dynamic> data, String productName) async {
  try {
    final List<DataItem> selectedData =
        ref.read(selectedDataProvider.notifier).state;
    if (selectedData.isNotEmpty) {
      final Map<String, dynamic> dataMap = {};
      dataMap['uid'] = uid;
      for (final item in selectedData) {
        dataMap[item.category] = item.value;
      }

      bool exists = await isBarcodeExists(dataMap['Barcode']);

      if (!exists) {
        // Add data to Firestore
        await FirebaseFirestore.instance
            .collection('Barcode_Lookup')
            .add(dataMap);
        print("Data to Firestore sent!!!");

        // Send a Snackbar when data is sent to database
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data added to Firestore!')));
      } else {
        print("Barcode already exists in Firestore.");

        // Send a Snackbar indicating barcode already exists
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Barcode already exists!')));
      }
    }
  } catch (e) {
    print('Error sending data to Firestore: $e');
  }
}

Future<bool> isBarcodeExists(String barcode) async {
  try {
    final snapshot = await FirebaseFirestore.instance
        .collection('Barcode_Lookup')
        .where('Barcode', isEqualTo: barcode)
        .where('uid', isEqualTo: uid)
        .limit(1) // Ma
        .get();

    // If the snapshot contains any documents, then a document with the provided barcode already exists
    return snapshot.docs.isNotEmpty;
  } catch (e) {
    print('Error checking barcode existence in Firestore: $e');
    return false; // Return false in case of any error
  }
}



class NutritionContainer extends StatelessWidget {

  const NutritionContainer(
    carbsPerServing, {

    super.key,
    required this.amtPerServing,
    required this.productCalories,
    required this.fatsPserving,
    required this.satfatsPserving,
    required this.transfatsPserving,
    required this.carbsPserving,
    required this.sugarsPerServing,
    required this.proteinPserving,
    required this.sodiumPerServing,
    required this.cholesterolPerServing,
  });

  final double amtPerServing;
  final double productCalories;
  final double fatsPserving;
  final double satfatsPserving;
  final double transfatsPserving;
  final double carbsPserving;
  final double sugarsPerServing;
  final double proteinPserving;
  final double sodiumPerServing;
  final double cholesterolPerServing;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 255, 252, 252),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(12.0),
          topRight: Radius.circular(12.0),
        ),
      ),
      child: SingleChildScrollView(
        //controller: _controller,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(children: [
 
            //NutriGridView(selectedFilters: selectedFilters, result: result, productName: productName, productCalories: productCalories, carbsPserving: carbsPserving, proteinPserving: proteinPserving, fatsPserving: fatsPserving,secondController: ScrollController()),
            //Nutritional Facts Column Sheet
            const Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  child: Text(
                    'Nutrition Facts',
                    textAlign: TextAlign.start,
                    style: TextStyle(
                        fontFamily: 'Helvetica Black',
                        fontSize: 44,
                        fontWeight: FontWeight.w900),
                  ),
                ),
              ],
            ),
            const Divider(
                thickness: 1, color: Color.fromARGB(255, 118, 117, 117)),
            Align(
              child: Container(
                height: 25,
                // Stack to hold the fats and the fats variable
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "${amtPerServing.toInt()}g per container",
                      textAlign: TextAlign.start,
                      style: const TextStyle(
                          fontFamily: 'Helvetica Black',
                          fontSize: 20,
                          fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
              ),
            ),
            NutritionRow(
              title: "Calories",
              value: '$productCalories',
              fontSize: 24,
              dividerThickness: 5,
              showDivider: false,
            ),
            //Nutritional Column Dividers
            //End NUTRITION FACTS ROW
            const Divider(thickness: 5, color: Color.fromARGB(255, 0, 0, 0)),
            //Start of Nutrition rows
            //
            NutritionRow(title: 'Total Fats', value: '$fatsPserving'),
            //saturated Fats
            NutritionRow(
              title: 'Saturated Fat',
              value: '$satfatsPserving',
              isSubcategory: true,
              hideIfZero: false,
            ),
            NutritionRow(
              title: 'Trans Fat',
              value: '$transfatsPserving',
              isSubcategory: true,
              hideIfZero: false,
            ),
            //end fats

            NutritionRow(title: "Total Carbohydrates", value: '$carbsPserving'),
            //Sugars
            NutritionRow(
                title: "Total Sugars",
                isSubcategory: true,
                value: '$sugarsPerServing'),
            //end Protein

            //protein per serving
            NutritionRow(title: "Protein", value: "$proteinPserving"),

            //sodium
            NutritionRow(title: "Sodium", value: "$sodiumPerServing"),

            NutritionRow(
                title: "Cholesterol",
                value: '${cholesterolPerServing.toStringAsFixed(1)}'),
            //end Protein
          ]),
        ),
      ),
    );
  }
}

class NutritionDivider extends StatelessWidget {
  final double thickness;
// constructor/ Default Value
  NutritionDivider({this.thickness = 1.0});
  @override
  Widget build(BuildContext context) {
    return Divider(
      thickness: thickness,
      color: const Color.fromARGB(255, 118, 117, 117),
    );
  }
}

//NutritionalModalClass
// This is the class that will pop up a sheet of nutritional information

class NutritionalModalClass {
  static void show(BuildContext context, Widget content) {
    //Function that will pop a modal sheet to the middle of the screen
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return content;
        });
  }
}

class NutritionRow extends StatelessWidget {
  final String title;
  final String value;
  final bool isSubcategory;
  final bool hideIfZero;
  final double fontSize;
  final FontWeight titleFontWeight;
  final FontWeight valueFontWeight;
  final double dividerThickness;
  final bool showDivider;

  const NutritionRow(
      {Key? key,
      required this.title,
      required this.value,
      this.isSubcategory = false,
      this.hideIfZero = false,
      this.fontSize = 20, // default font size value
      this.titleFontWeight = FontWeight.w900, // default Title weight
      this.valueFontWeight = FontWeight.bold, // default textWeight
      this.showDivider = true,
      this.dividerThickness = 1.0 //default Divider thickmess
      })
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (hideIfZero && value == '0.0') {
      return const SizedBox.shrink(); // returns an empty widgetif value is 0
    }

    return Column(
      children: [
        Container(
          height: fontSize * 1.25, // roughly aligns with text height
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: EdgeInsets.only(left: isSubcategory ? 30.0 : 0.0),
                child: Text(
                  title,
                  textAlign: isSubcategory ? TextAlign.start : TextAlign.end,
                  style: TextStyle(
                    // if SubCategory (sat fats) then use different font
                    fontFamily: isSubcategory ? 'Arial' : 'Helvetica Black',
                    fontSize: fontSize,
                    fontWeight:
                        isSubcategory ? valueFontWeight : titleFontWeight,
                  ),
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Helvetica Black',
                  fontSize: fontSize,
                  fontWeight: valueFontWeight,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          NutritionDivider(
            thickness: dividerThickness,
          )
      ],
    );
  }
}
