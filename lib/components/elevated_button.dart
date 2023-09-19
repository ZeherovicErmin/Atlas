import 'package:flutter/material.dart';

class ElevatedBarcodeButton extends StatelessWidget {
  final Function() onPressed;

  ElevatedBarcodeButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      child: Text('Scan Barcode'),
    );
  }
}
