import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Define a provider for the ScrollController
final scrollControllerProvider = Provider.autoDispose<ScrollController>((ref) {
  return ScrollController();
});

class HomePage extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Retrieve the ScrollController from the provider
    final scrollController = ref.read(scrollControllerProvider);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.purple[900],
        title: Text('Draggable Scrollable Sheet'),
        centerTitle: true,
      ),
      body: Center(
        child: DraggableScrollableSheet(
          builder: (BuildContext context, ScrollController _controller) {
            return productHouserSheet(_controller);
          },
        ),
      ),
    );
  }

  Widget productHouserSheet(ScrollController _controller) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.purple[900],
      ),
      child: GridView.builder(
        // Set the ScrollController for the GridView
        controller: _controller,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2, // Number of columns in the grid
        ),
        itemCount: 50, // Adjust the number of items as needed
        itemBuilder: (BuildContext context, int index) {
          return Card(
            color: Colors.amber,
            child: Center(
              child: Text(
                'Item $index',
                style: TextStyle(color: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}
