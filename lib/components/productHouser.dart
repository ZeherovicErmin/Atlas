import 'package:atlas/pages/barcode_log_page.dart';
import 'package:atlas/pages/barcode_lookup_page.dart';
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
final fatsPservingProvider = StateProvider<double>((ref) => 0.0);
final carbsPservingProvider = StateProvider<double>((ref) => 0.0);
final proteinPservingProvider = StateProvider<double>((ref) => 0.0);
final cholesterolProvider = StateProvider<double>((ref) => 0.0);
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
            ref.watch(productNameProvider.notifier).state = productData.productName != null ?productData.productName! : "Unknown product name";
            // Set product calories, carbs, protein, and fats per serving
            ref.watch(productCaloriesProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.energyKCal, PerSize.serving) ??
                0.0;
            ref.watch(carbsPservingProvider.notifier).state =
                productData.nutriments?.getValue(
                        Nutrient.carbohydrates, PerSize.serving) ??
                    0.0;
            ref.watch(proteinPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.proteins, PerSize.serving) ??
                0.0;
            ref.watch(fatsPservingProvider.notifier).state = productData
                    .nutriments
                    ?.getValue(Nutrient.fat, PerSize.serving) ??
                0.0;
            ref.watch(cholesterolProvider.notifier).state = productData
                    .nutriments 
                    ?.getValue(Nutrient.cholesterol, PerSize.serving) ?? 
                0.0;
            ref.watch(amtServingsProvider.notifier).state = productData.servingQuantity!=null ?productData.servingQuantity! : 0.0;

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
            ref.read(amtServingsProvider.notifier).state)
          ];

          // Send data to Firestore
          sendDataToFirestore(
              context, ref, {}, ref.read(productNameProvider.notifier).state);
        } catch (e) {
          // Set error messages if an exception occurs
          ref.watch(resultProvider.notifier).state =
              'Product not found'; // Set an appropriate message
          ref.watch(productNameProvider.notifier).state = 'Product not found';
          ref.watch(productCaloriesProvider.notifier).state = 0.0;
          ref.watch(proteinPservingProvider.notifier).state = 0.0;
          ref.watch(carbsPservingProvider.notifier).state = 0.0;
          ref.watch(fatsPservingProvider.notifier).state = 0.0;
          ref.watch(cholesterolProvider.notifier).state = 0.0;
          ref.watch(amtServingsProvider.notifier).state = 0.0;
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
    final fatsPserving = ref.watch(fatsPservingProvider.notifier).state;
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

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color.fromARGB(255, 90, 117, 255),
            Color.fromARGB(255, 161, 195, 250),
          ],
        ),
      ),
      child: Scaffold(
        appBar: myAppBar2(context, ref, 'B a r c o d e   L o o k u p'),
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            Container(
              child: SingleChildScrollView(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Display filter chips for user selection
                      //FilterChips(selectedFilters, context, ref),
                      const SizedBox(height: 20),
                      // Button to open the barcode scanner
                      ElevatedButton(
                        onPressed: () async {
                          await _scanBarcode(context, ref);
                        },
                        child: const Text('Open Scanner'),
                      ),
                      const SizedBox(height: 20),
                      // Button to navigate to barcode logs
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BarcodeLogPage(),
                            ),
                          );
                        },
                        child: const Text("Barcode logs"),
                      ),
                      // Display selected data based on filters in a grid
                      //GridViewProductCards(selectedFilters: selectedFilters, result: result, productName: productName, productCalories: productCalories, carbsPserving: carbsPserving, proteinPserving: proteinPserving, fatsPserving: fatsPserving),
                    ],
                  ),
                ),
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
            amtPerServing:amtPerServing),
          ],
        ),
      ),
    );
  }

  Wrap FilterChips(List<String> selectedFilters, BuildContext context, WidgetRef ref) {
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

class GridViewProductCards extends StatelessWidget {
  const GridViewProductCards({
    super.key,
    required this.selectedFilters,
    required this.result,
    required this.productName,
    required this.productCalories,
    required this.carbsPserving,
    required this.proteinPserving,
    required this.fatsPserving,
  });

  final List<String> selectedFilters;
  final String result;
  final String productName;
  final double productCalories;
  final double carbsPserving;
  final double proteinPserving;
  final double fatsPserving;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      children: [
        if (selectedFilters.isNotEmpty)
          ...selectedFilters.map((filter) {
            return GenerateTileCard(
              result: result,
              productName: productName,
              productCalories: productCalories,
              carbsPserving: carbsPserving,
              proteinPserving: proteinPserving,
              fatsPserving: fatsPserving,
              filter: filter,
            );
          }),
      ],
    );
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
  

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
        initialChildSize: .1,
        minChildSize: .1,
        maxChildSize: .8,
        builder: (BuildContext context, ScrollController _controller) {
          return Container(
            decoration: BoxDecoration(
              color: Color.fromARGB(255, 255, 255, 255),
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12.0),
                topRight: Radius.circular(12.0),
              ),
            ),
            child: SingleChildScrollView(
              controller: _controller,
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
                Column(
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Align(child: Text('Nutrition Facts',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 48,fontWeight: FontWeight.w900),
                    ),),
                  ],
                  

                ),
                Divider(thickness: 1,color: Color.fromARGB(255, 118, 117, 117)),
                Align(
                  child: Container(
                    height: 25,
                    // Stack to hold the fats and the fats variable
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text("${amtPerServing.toInt()} Servings per container",
                        textAlign: TextAlign.start,
                        style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.w800),
                        ),
                        
                      ],

                      ),
                      
                    
                  ),
                ),
                Container(
                  height: 50,
                  //holds the Serving Size Row
                  child: Stack(
                    children:[ Row(
                      mainAxisAlignment:MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Calories',
                    textAlign: TextAlign.start,
                    style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 40,fontWeight: FontWeight.w900),),
                    Text('${carbsPserving.toInt()}',
                            style: TextStyle(fontFamily: 'Arial',fontSize: 50,fontWeight: FontWeight.w800),
                            ),
                      ],
                      ),
              ],),
                ),
                //Nutritional Column Dividers
                //End NUTRITION FACTS ROW
                Divider(thickness: 5,color: Color.fromARGB(255, 0, 0, 0)),
                Align(
                  child: Container(
                    height: 25,
                    // Stack to hold the fats and the fats variable
                    child: Stack(
                      children: [
                        //Fats row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Fats",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.w900),
                            ),
                            // Fats variable
                            Text('$fatsPserving',
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ],

                      )],
                    ),
                    
                  ),
                ),

                //end fats
                Divider(thickness: 1,color: Color.fromARGB(255, 118, 117, 117)),
                Align(
                  child: Container(
                    height: 25,
                    // Stack to hold the fats and the fats variable
                    child: Stack(
                      children: [
                        //Protein row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Total Carbohydrate",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.w900),
                            ),
                            // Fats variable
                            Text('$carbsPserving',
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ],

                      )],
                    ),
                    
                  ),
                ),
                //end Protein
                Divider(thickness: 1,color: Color.fromARGB(255, 118, 117, 117)),
                Align(
                  
                  child: Container(
                    height: 25,
                    // Stack to hold the fats and the fats variable
                    child: Stack(
                      children: [
                        //Protein row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Protein....",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.w900),
                            ),
                            // Fats variable
                            Text('$proteinPserving',
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ],

                      )],
                    ),
                    
                  ),
                ),
                Divider(thickness: 1,color: Color.fromARGB(255, 118, 117, 117)),
                Align(
                  child: Container(
                    height: 25,
                    // Stack to hold the Carbs and the Carbs variable
                    child: Stack(
                      children: [
                        //Carbs row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Cholesterol....",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                            // Fats variable
                            Text('$cholesterolPerServing',
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ],

                      )],
                    ),
                    
                  ),
                ),
                //end Protein
                Divider(thickness: 1,color: Color.fromARGB(255, 118, 117, 117)),
                Align(
                  child: Container(
                    height: 25,
                    // Stack to hold the fats and the fats variable
                    child: Stack(
                      children: [
                        //Protein row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Protein....",
                            textAlign: TextAlign.start,
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                            // Fats variable
                            Text('$proteinPserving',
                            style: TextStyle(fontFamily: 'Helvetica Black',fontSize: 20,fontWeight: FontWeight.bold),
                            ),
                          ],

                      )],
                    ),
                    
                  ),
                ),
              ]),
            ),
          );
        });
  }
}

class NutriGridView extends StatelessWidget {
  final ScrollController secondController;
  const NutriGridView({
    super.key,
    required this.selectedFilters,
    required this.result,
    required this.productName,
    required this.productCalories,
    required this.carbsPserving,
    required this.proteinPserving,
    required this.fatsPserving,
    required this.secondController
  });

  final List<String> selectedFilters;
  final String result;
  final String productName;
  final double productCalories;
  final double carbsPserving;
  final double proteinPserving;
  final double fatsPserving;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: GridView.count(
        controller: secondController,
        crossAxisCount: 2,
        shrinkWrap: true,
        children: [
          if (selectedFilters.isNotEmpty)
            ...selectedFilters.map(
              (filter) {
                return GenerateTileCard(
                  result: result,
                  productName: productName,
                  productCalories: productCalories,
                  carbsPserving: carbsPserving,
                  proteinPserving: proteinPserving,
                  fatsPserving: fatsPserving,
                  filter: filter,
                );
              },
            )
        ],
      ),
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
            color: Color.fromARGB(255, 209, 209, 209),
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

class ProductCard extends StatelessWidget {
  final String title;
  final String data;
  final bool isVisible; // New property to control visibility

  ProductCard({
    required this.title,
    required this.data,
    this.isVisible = true, // Default is visible
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      // Return an empty container if it shouldn't be displayed
      return Container();
    }

    return Card(
      margin: const EdgeInsets.all(8.0),
      elevation: 4.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: AutoSizeText(
                title,
                style: TextStyle(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                maxLines: 1,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: AutoSizeText(
                data,
                style: TextStyle(
                  fontSize: 16.0,
                  color: Colors.black,
                ),
                maxLines:
                    10, // Specify the maximum number of lines before text ellipsis
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
