import 'package:atlas/pages/constants.dart';
import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/test.dart' as testAPI;
import '../../components/product_card.dart';
import 'barcode_log_page.dart';
import 'package:firebase_auth/firebase_auth.dart';

final barcodeProvider = StateProvider<String?>((ref) => null);
final productNameProvider = StateProvider<String>((ref) => '');
final resultProvider = StateProvider<String>((ref) => '');
final productCaloriesProvider = StateProvider<double>((ref) => 0.0);
final fatsPservingProvider = StateProvider<double>((ref) => 0.0);
final carbsPservingProvider = StateProvider<double>((ref) => 0.0);
final proteinPservingProvider = StateProvider<double>((ref) => 0.0);
final selectedFiltersProvider = StateProvider<List<String>>((ref) => []);
final selectedDataProvider = StateProvider<List<DataItem>>((ref) => []);
final uidProvider = StateProvider<String>((ref) => '');

final FirebaseAuth auth = FirebaseAuth.instance;
final user = auth.currentUser;
final uid = user?.uid;

class DataItem {
  final String category;
  final dynamic value;

  DataItem(this.category, this.value);
}

// Creating the barcode class
class BarcodeLookupPage extends ConsumerWidget {
  final List<String> filterOptions = [
    'Barcode Result',
    'Product Name',
    'Calories',
    'Macros',
  ];
  BarcodeLookupPage({Key? key}) : super(key: key);

  Future<void> _scanBarcode(BuildContext context, WidgetRef ref) async {
    var scannedBarcode = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SimpleBarcodeScannerPage(),
      ),
    );

    if (scannedBarcode is String) {
      scannedBarcode = isValidUPC(scannedBarcode);
      if (isValidBarcode(scannedBarcode)) {
        final productData = await testAPI.getProduct(scannedBarcode);
        ref.watch(resultProvider.notifier).state =
            scannedBarcode; // Corrected line
        if (productData != null) {
          if (productData.productName != null) {
            ref.watch(productNameProvider.notifier).state =
                productData.productName!;
          } else {
            // Handle the case where productData.productName is null.
            // For example, you might set a default value or log an error.
            ref.watch(productNameProvider.notifier).state =
                'Unknown product name';
          }
          // Corrected line
          ref.watch(productCaloriesProvider.notifier).state = productData
                  .nutriments
                  ?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ??
              0.0; // Corrected line
          ref.watch(carbsPservingProvider.notifier).state = productData
                  .nutriments
                  ?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
              0.0; // Corrected line
          ref.watch(proteinPservingProvider.notifier).state = productData
                  .nutriments
                  ?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ??
              0.0; // Corrected line
          ref.watch(fatsPservingProvider.notifier).state = productData
                  .nutriments
                  ?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ??
              0.0; // Corrected line

          ref.watch(uidProvider.notifier).state = uid.toString();
        } else {
          ref.watch(productNameProvider.notifier).state =
              'Please try again'; // Corrected line
        }
        ref.read(selectedDataProvider.notifier).state = [
          DataItem('uid', ref.read(uidProvider.notifier).state),
          DataItem('Barcode', scannedBarcode),
          DataItem('productName', ref.read(productNameProvider.notifier).state),
          DataItem('productCalories',
              ref.read(productCaloriesProvider.notifier).state),
          DataItem('carbsPerServing',
              ref.read(carbsPservingProvider.notifier).state),
          DataItem('proteinPerServing',
              ref.read(proteinPservingProvider.notifier).state),
          DataItem(
              'fatsPerServing', ref.read(fatsPservingProvider.notifier).state),
        ];

        sendDataToFirestore(
            context, ref, {}, ref.read(productNameProvider.notifier).state);
      } else {
        ref.watch(resultProvider.notifier).state =
            'Invalid Barcode/UPC Code'; // Corrected line
        ref.watch(productNameProvider.notifier).state =
            'Please try again'; // Corrected line
      }
    }
  }

  bool isValidBarcode(String barcode) {
    final RegExp barcodePattern = RegExp(r'^\d{13}$');
    return barcodePattern.hasMatch(barcode);
  }

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
    final barcode = ref.watch(barcodeProvider.notifier).state;
    final result = ref.watch(resultProvider.notifier).state;
    final productName = ref.watch(productNameProvider.notifier).state;
    final productCalories = ref.watch(productCaloriesProvider.notifier).state;
    final fatsPserving = ref.watch(fatsPservingProvider.notifier).state;
    final carbsPserving = ref.watch(carbsPservingProvider.notifier).state;
    final proteinPserving = ref.watch(proteinPservingProvider.notifier).state;
    final selectedFilters = ref.watch(selectedFiltersProvider);
    final selectedData = ref.watch(selectedDataProvider);
    final uid = ref.watch(uidProvider.notifier).state;

    final filteredItems = selectedData
        .where((dataItem) => selectedFilters.contains(dataItem.category))
        .toList();
    return Scaffold(
      appBar: myAppBar2(context, ref, 'Barcode Lookup'),
      backgroundColor: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFA9B7FF), Color(0xFF83B0FA)],
      ).colors[0],
      body: Container(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
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
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    await _scanBarcode(context, ref);
                  },
                  child: const Text('Open Scanner'),
                ),
                const SizedBox(height: 20),
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
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  children: [
                    if (selectedFilters.isNotEmpty)
                      ...selectedFilters.map((filter) {
                        return Container(
                          child: GenerateTileCard(
                            result: result,
                            productName: productName,
                            productCalories: productCalories,
                            carbsPserving: carbsPserving,
                            proteinPserving: proteinPserving,
                            fatsPserving: fatsPserving,
                            filter: filter,
                          ),
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
        await FirebaseFirestore.instance
            .collection('Barcode_Lookup')
            .add(dataMap);
        print("Data to Firestore sent!!!");

        // Send a Snackbar when data is sent to database
        // ScaffoldMessenger
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

  void _addFilter(StateController<List<String>> notifier,
      List<String> currentFilters, String newFilter) {
    notifier.state = [...currentFilters, newFilter];
    print("Filters after adding: ${notifier.state}");
    notifier.state = notifier.state;
  }

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

class GenerateTileCard extends ConsumerStatefulWidget {
  GenerateTileCard({
    Key? key,
    required this.result,
    required this.productName,
    required this.productCalories,
    required this.carbsPserving,
    required this.proteinPserving,
    required this.fatsPserving,
    required this.filter,
  }) : super(key: key) {
    print("GenerateTileCard constructed with filter: $filter");
  }

  final String result;
  final String productName;
  final double productCalories;
  final double carbsPserving;
  final double proteinPserving;
  final double fatsPserving;
  final String filter;

  @override
  _GenerateTileCardState createState() => _GenerateTileCardState();
}

class _GenerateTileCardState extends ConsumerState<GenerateTileCard> {
  @override
  Widget build(BuildContext context) {
    print("Filter: ${widget.result}");
    switch (widget.filter) {
      case 'Barcode Result':
        return ProductCard(title: 'Barcode Result:', data: widget.result);
      case 'Product Name':
        return ProductCard(
          title: 'Product Name:',
          data: widget.productName,
        );
      case 'Calories':
        return ProductCard(
            title: 'Calories:', data: '${widget.productCalories}');
      case 'Macros':
        return ProductCard(
          title: "Macros",
          data:
              'Carbs: ${widget.carbsPserving}\nProtein: ${widget.proteinPserving}\nFats: ${widget.fatsPserving}',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
