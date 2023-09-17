import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '/../util/test.dart' as testAPI;
import '../../components/product_card.dart';
import '../../components/dropdown.dart';
import '../../components/popupmenu.dart';

class BarcodeLookupPage extends StatefulWidget {
  @override
  State<BarcodeLookupPage> createState() => _BarcodeLookupPageState();
}

class _BarcodeLookupPageState extends State<BarcodeLookupPage> {
  String? barcodeData;

  String productName = '';
  String result = '';
  double productCalories = 0.0;
  // List of selectedFilters the user wants to see
  List<String> selectedFilters = [];
  // List of filter options the user can select
  List<String> filterOptions = ['Barcode Result', 'Product Name', 'Calories'];

  //Code opens the barcode scanner portion
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

  //Function for changing the filters
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

// Function to generate a sample card based on the selected filter
  Widget generateTileCard(String filter) {
    // Switch case based on the filter you select. Will be researching
    // how to make this more formless
    switch (filter) {
      case 'Barcode Result':
        return ProductCard(title: 'Barcode Result:', data: '$result');
      case 'Product Name':
        return ProductCard(
          title: 'Product Name:',
          data: '$productName',
        );
      case 'Calories':
        return ProductCard(title: 'Calories:', data: '$productCalories');
      default:
        return SizedBox
            .shrink(); // Return an empty container if no filter matches
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
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFA9B7FF), Color(0xFF83B0FA)],
        )),
        child: Center(
          //will contain widgets
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //FilterDropdown widget here
              Wrap(
                children: filterOptions.map((filter) {
                  return FilterChip(
                    label: Text(filter),
                    selected: selectedFilters.contains(filter),
                    onSelected: (isSelected) {
                      _onFilterChanged(filter);
                    },
                  );
                }).toList(),
              ),

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

                //reads off the results of the callback
                //9/16/2023: Adding selected Filter into the mix
                children: [
                  if (selectedFilters.isNotEmpty)
                    ...selectedFilters.map((filter) {
                      return generateTileCard(filter);
                    }),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
//AliChowdhury: 9/16/2023: added barcode and filter dropdown
