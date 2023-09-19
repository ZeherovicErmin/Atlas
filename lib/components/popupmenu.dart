import 'package:flutter/material.dart';

class PopUpMenu extends StatefulWidget {
  final List<String> filterOptions;
  final List<bool> selectedFilter;
  final void Function(List<bool>)? onChanged;

  PopUpMenu({
    required this.filterOptions,
    required this.selectedFilter,
    required this.onChanged,
  });

  @override
  _PopUpMenuState createState() => _PopUpMenuState();
}

class _PopUpMenuState extends State<PopUpMenu> {
  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<int>(
      initialValue: -1, // Nothing selected at first
      itemBuilder: (BuildContext context) {
        return widget.filterOptions.asMap().entries.map((entry) {
          final index = entry.key;
          final option = entry.value;

          return PopupMenuItem<int>(
            value: index,
            child: Row(
              children: [
                Icon(
                  Icons.check,
                  color: widget.selectedFilter[index]
                      ? Colors.blue
                      : Colors.transparent,
                ),
                SizedBox(width: 8),
                Text(option),
              ],
            ),
          );
        }).toList();
      },
      onSelected: (int index) {
        // Toggle the selection status of the item
        widget.selectedFilter[index] = !widget.selectedFilter[index];
        widget.onChanged?.call(widget.selectedFilter);
      },
    );
  }
}
