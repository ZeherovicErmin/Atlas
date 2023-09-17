import 'package:flutter/material.dart';

class FilterDropdown extends StatelessWidget {
  //const FilterDropdown({super.key});
  final List<String> filterOptions;
  final String selectedFilter;
  final void Function(String?)? onChanged;

  //Required parameters for FilterDropdown
  FilterDropdown({
    required this.filterOptions,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: selectedFilter,
      onChanged: onChanged,
      items: filterOptions.map<DropdownMenuItem<String>>((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
          //Boolean to make the toggleable portions visible
        );
      }).toList(),
    );
  }
}
