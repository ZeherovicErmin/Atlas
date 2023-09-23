import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../util/test.dart' as testAPI;
import '../../components/product_card.dart';
import 'barcode_log_page.dart';

final barcodeProvider = StateProvider<String?>((ref) => null);
final productNameProvider = StateProvider<String>((ref) => '');
final resultProvider = StateProvider<String>((ref) => '');
final productCaloriesProvider = StateProvider<double>((ref) => 0.0);
final fatsPservingProvider = StateProvider<double>((ref) => 0.0);
final carbsPservingProvider = StateProvider<double>((ref) => 0.0);
final proteinPservingProvider = StateProvider<double>((ref) => 0.0);
final selectedFiltersProvider = StateProvider<List<String>>((ref) => []);
final selectedDataProvider = StateProvider<Map<String, dynamic>>((ref) => {});

class BarcodeLookupPage extends ConsumerWidget {
  final List<String> filterOptions = [
    'Barcode Result',
    'Product Name',
    'Calories',
    'testMacros'
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
        ref.read(resultProvider.notifier).state = scannedBarcode;
        if (productData != null) {
          ref.read(productNameProvider.notifier).state =
              productData.productName!;
          ref.read(productCaloriesProvider.notifier).state = productData
                  .nutriments
                  ?.getValue(Nutrient.energyKCal, PerSize.oneHundredGrams) ??
              0.0;
          ref.read(carbsPservingProvider.notifier).state = productData
                  .nutriments
                  ?.getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams) ??
              0.0;
          ref.read(proteinPservingProvider.notifier).state = productData
                  .nutriments
                  ?.getValue(Nutrient.proteins, PerSize.oneHundredGrams) ??
              0.0;
          ref.read(fatsPservingProvider.notifier).state = productData.nutriments
                  ?.getValue(Nutrient.fat, PerSize.oneHundredGrams) ??
              0.0;
        } else {
          ref.read(productNameProvider.notifier).state = 'Please try again';
        }
        ref.read(selectedDataProvider.notifier).state = {
          'Barcode': scannedBarcode,
          'productName': ref.read(productNameProvider.notifier).state,
          'productCalories': ref.read(productCaloriesProvider.notifier).state,
          'carbsPerServing': ref.read(carbsPservingProvider.notifier).state,
          'proteinPerServing': ref.read(proteinPservingProvider.notifier).state,
          'fatsPerServing': ref.read(fatsPservingProvider.notifier).state,
        };
        sendDataToFirestore(context, ref, {});
      } else {
        ref.read(resultProvider.notifier).state = 'Invalid Barcode/UPC Code';
        ref.read(productNameProvider.notifier).state = 'Please try again';
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
    final selectedFilters = ref.watch(selectedFiltersProvider.notifier).state;

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
          ),
        ),
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Wrap(
                  spacing: .8,
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
                          child: generateTileCard(
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

  Future<void> sendDataToFirestore(
      BuildContext context, WidgetRef ref, Map<String, dynamic> data) async {
    try {
      if (ref.read(selectedDataProvider.notifier).state.isNotEmpty) {
        await FirebaseFirestore.instance
            .collection('Barcode_Lookup')
            .add(ref.read(selectedDataProvider.notifier).state);
        print("Data to Firestore sent!!!");
      } else {
        print("No data selected");
      }
    } catch (e) {
      print('Error sending data: Error: $e');
    }
  }

  void _onFilterChanged(String newFilter, BuildContext context, WidgetRef ref) {
    if (ref.read(selectedFiltersProvider.notifier).state.contains(newFilter)) {
      ref.read(selectedFiltersProvider.notifier).state.remove(newFilter);
    } else {
      ref.read(selectedFiltersProvider.notifier).state.add(newFilter);
    }
  }
}

class generateTileCard extends StatelessWidget {
  const generateTileCard({
    Key? key,
    required this.result,
    required this.productName,
    required this.productCalories,
    required this.carbsPserving,
    required this.proteinPserving,
    required this.fatsPserving,
    required this.filter,
  }) : super(key: key);

  final String result;
  final String productName;
  final double productCalories;
  final double carbsPserving;
  final double proteinPserving;
  final double fatsPserving;
  final String filter;

  @override
  Widget build(BuildContext context) {
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
              'Carbs: $carbsPserving\nProtein: $proteinPserving\nFats: $fatsPserving',
        );
      default:
        return const SizedBox.shrink();
    }
  }
}
