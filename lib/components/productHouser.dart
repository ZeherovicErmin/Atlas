import 'package:atlas/components/product_card.dart';
import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/constants.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../util/test.dart' as testAPI;

// Define state providers for various data
final barcodeProvider = StateProvider<String?>((ref) => null);
final productNameProvider = StateProvider<String>((ref) => '');
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
  Future<void> _scanBarcode(BuildContext context, WidgetRef ref) async {
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
          final productData = await testAPI.getProduct(scannedBarcode);

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
            DataItem('sodiumPerServing', ref.read(sodiumPservingProvider)),
          ];

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
      }
    }
  }

  // Function to check if a barcode is valid
  bool isValidBarcode(String barcode) {
    final RegExp barcodePattern = RegExp(r'^\d{13}$');
    return barcodePattern.hasMatch(barcode);
  }

  // Function to normalize UPC code
  String isValidUPC(String barcode) {
    final RegExp barcodePattern = RegExp(r'^\d{12}$');
    if (barcodePattern.hasMatch(barcode)) {
      final modifiedBarcode = '0$barcode';
      return modifiedBarcode;
    }
    return barcode;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get data from state providers
    final barcode = ref.watch(barcodeProvider.notifier).state;
    final result = ref.watch(resultProvider.notifier).state;
    final productName = ref.watch(productNameProvider.notifier).state;
    final productCalories = ref.watch(productCaloriesProvider.notifier).state;
    final amtPerServing = ref.watch(amtServingsProvider.notifier).state;
    //fats
    final fatsPserving = ref.watch(fatsPservingProvider.notifier).state;
    final satfatsPserving = ref.watch(satfatsPservingProvider.notifier).state;
    final transfatsPserving =
        ref.watch(transfatsPservingProvider.notifier).state;
    final carbsPserving = ref.watch(carbsPservingProvider.notifier).state;
    final proteinPserving = ref.watch(proteinPservingProvider.notifier).state;
    final cholesterolPerServing = ref.watch(cholesterolProvider.notifier).state;
    final selectedFilters = ref.watch(selectedFiltersProvider);
    final selectedData = ref.watch(selectedDataProvider);
    final uid = ref.watch(uidProvider.notifier).state;

    // Filter data based on selected filters
    final filteredItems = selectedData
        .where((dataItem) => selectedFilters.contains(dataItem.category))
        .toList();

    return Scaffold(
        appBar: myAppBar2(context, ref, 'B a r c o d e   L o o k u p'),
        backgroundColor: const Color.fromARGB(0, 231, 0, 0),
        body: Stack(
          children: [
            //const SizedBox(height: 20),
            // Button to open the barcode scanner

            //const SizedBox(height: 20),
            // Button to navigate to barcode logs

            Padding(
              padding: const EdgeInsets.only(top: 200.0),
              child: BarcodeLogPage(),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton(
                onPressed: () async {
                  await _scanBarcode(context, ref);
                },
                child: const Text('Open Scanner'),
              ),
            ),
            NutrientsList(
              selectedFilters: selectedFilters,
              result: result,
              productName: productName,
              productCalories: productCalories,
              carbsPserving: carbsPserving,
              proteinPserving: proteinPserving,
              fatsPserving: fatsPserving,
              cholesterolPerServing: cholesterolPerServing,
              amtPerServing: amtPerServing,
              satfatsPserving: satfatsPserving,
              transfatsPserving: transfatsPserving,
            ),
          ],
        ));
  }

  Wrap FilterChips(
      List<String> selectedFilters, BuildContext context, WidgetRef ref) {
    return Wrap(
      spacing: 1,
      children: filterOptions.map((filter) {
        return FilterChip(
          label: Text(filter),
          selected: selectedFilters.contains(filter),
          onSelected: (isSelected) {
            _onFilterChanged(filter, context, ref);
          },
        );
      }).toList(),
    );
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
          print(dataMap);
        }
        // Add data to Firestore
        await FirebaseFirestore.instance
            .collection('Barcode_Lookup')
            .add(dataMap);
        print("Data to Firestore sent!!!");

        // Send a Snackbar when data is sent to database
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("$productName sent to Firestore"),
            duration: Duration(seconds: 2),
          ),
        );
      } else {
        print("No data selected");
      }
    } catch (e) {
      print('Error sending data: Error: $e');
    }
  }

  // Function to handle filter changes
  void _onFilterChanged(String newFilter, BuildContext context, WidgetRef ref) {
    final notifier = ref.read(selectedFiltersProvider.notifier);
    final currentFilters = notifier.state;
    print("Selected Filter: $newFilter");
    if (currentFilters.contains(newFilter)) {
      _removeFilter(notifier, currentFilters, newFilter);
    } else {
      _addFilter(notifier, currentFilters, newFilter);
    }
    notifier.state = notifier.state;
  }

  // Function to add a filter
  void _addFilter(StateController<List<String>> notifier,
      List<String> currentFilters, String newFilter) {
    notifier.state = [...currentFilters, newFilter];
    print("Filters after adding: ${notifier.state}");
    notifier.state = notifier.state;
  }

  // Function to remove a filter
  void _removeFilter(StateController<List<String>> notifier,
      List<String> currentFilters, String filterToRemove) {
    notifier.state = [
      for (final item in currentFilters)
        if (filterToRemove != item) item
    ];
    print("Filters after removing: ${notifier.state}");
    notifier.state = notifier.state;
  }
}

class NutrientsList extends StatelessWidget {
  const NutrientsList({
    super.key,
    required this.selectedFilters,
    required this.result,
    required this.productName,
    required this.productCalories,
    required this.carbsPserving,
    required this.proteinPserving,
    required this.fatsPserving,
    required this.cholesterolPerServing,
    required this.amtPerServing,
    required this.satfatsPserving,
    required this.transfatsPserving,
  });

  final List<String> selectedFilters;
  final String result;
  final String productName;
  final double productCalories;
  final double amtPerServing;
  final double carbsPserving;
  final double proteinPserving;
  final double fatsPserving;
  final double cholesterolPerServing;
  final double satfatsPserving;
  final double transfatsPserving;

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: .1,
        minChildSize: .1,
        maxChildSize: .8,
        builder: (BuildContext context, ScrollController _controller) {
          return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 151, 151, 151),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: SingleChildScrollView(
              controller: _controller,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  //Drag Handle
                  Center(
                    child: Container(
                        margin: EdgeInsets.all(8.0),
                        width: 40,
                        height: 5.0,
                        decoration: BoxDecoration(
                          color: Color.fromARGB(255, 104, 104, 104),
                          borderRadius: BorderRadius.all(
                            Radius.circular(12.0),
                          ),
                        )),
                  ),
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
                  Divider(
                      thickness: 1, color: Color.fromARGB(255, 118, 117, 117)),
                  Align(
                    child: Container(
                      height: 25,
                      // Stack to hold the fats and the fats variable
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "${amtPerServing.toInt()} Servings per container",
                            textAlign: TextAlign.start,
                            style: TextStyle(
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
                  Divider(thickness: 5, color: Color.fromARGB(255, 0, 0, 0)),
                  //Start of Nutrition rows
                  //
                  NutritionRow(title: 'Total Fats', value: '$fatsPserving'),
                  //saturated Fats
                  NutritionRow(
                    title: 'Saturated Fat',
                    value: '$satfatsPserving',
                    isSubcategory: true,
                    hideIfZero: true,
                  ),
                  NutritionRow(
                    title: 'Trans Fat',
                    value: '$transfatsPserving',
                    isSubcategory: true,
                    hideIfZero: true,
                  ),
                  //end fats

                  NutritionRow(
                      title: "Total Carbohydrates", value: '$carbsPserving'),
                  //end Protein

                  //protein per serving
                  NutritionRow(title: "Protein", value: "$proteinPserving"),

                  NutritionRow(
                      title: "Cholesterol", value: '$cholesterolPerServing'),
                  //end Protein
                ]),
              ),
            ),
          );
        });
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
      color: Color.fromARGB(255, 118, 117, 117),
    );
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
      return SizedBox.shrink(); // returns an empty widgetif value is 0
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

class DraggableScrollCard extends StatefulWidget {
  const DraggableScrollCard({Key? key});

  @override
  State<DraggableScrollCard> createState() => _DraggableScrollCardState();
}

class _DraggableScrollCardState extends State<DraggableScrollCard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 104, 104, 104),
        title: Text('Draggable Scrollable Sheet'),
        centerTitle: true,
      ),
      body: Center(
        child: productHouserSheet(),
      ),
    );
  }

  DraggableScrollableSheet productHouserSheet() {
    return DraggableScrollableSheet(
      builder: (BuildContext context, ScrollController _controller) {
        return Container(
          decoration: BoxDecoration(
            color: Color.fromARGB(255, 238, 238, 238),
          ),
          child: GridView.builder(
            controller: _controller,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // Number of columns in the grid
            ),
            itemCount: 50, // Adjust the number of items as needed
            itemBuilder: (BuildContext context, int index) {
              return ProductCard(
                title: 'Item $index',
                data: 'Some sample text for item $index.', // Sample data text
              );
            },
          ),
        );
      },
    );
  }
}
