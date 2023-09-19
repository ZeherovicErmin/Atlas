import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  final List<String> filterOptions;
  final List<String> selectedFilters;
  final void Function(List<String>)? onChanged;

  FilterDropdown({
    required this.filterOptions,
    required this.selectedFilters,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    String? selectedValue;

    if (selectedFilters.isNotEmpty) {
      selectedValue = selectedFilters.first;
    }

    return DropdownButton<String>(
      value: selectedValue,
      //newValue =
      onChanged: (newValue) {
        if (newValue != null) {
          onChanged?.call([newValue]);
        }
      },
      items: filterOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
    );
  }
}
