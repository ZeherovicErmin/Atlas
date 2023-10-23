import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class CustomScannerPage extends StatefulWidget {
  const CustomScannerPage({super.key});

  @override
  State<CustomScannerPage> createState() => _CustomScannerPageState();
}

class _CustomScannerPageState extends State<CustomScannerPage> with WidgetsBindingObserver {
  final MobileScannerController _controller = MobileScannerController(
    facing: CameraFacing.back,
    returnImage: true,
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _controller.start();
    } else if (state == AppLifecycleState.inactive ||
               state == AppLifecycleState.paused ||
               state == AppLifecycleState.detached) {
      _controller.stop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mobile Scanner'),
      ),
      body: Stack(
        children: <Widget>[
          MobileScanner(
            fit: BoxFit.contain,
            controller: _controller,
            onDetect: (capture) {
              final List<Barcode> barcodes = capture.barcodes;
              if (barcodes.isNotEmpty) {
                Navigator.pop(context, barcodes.first.rawValue);
              }
            },
          ),
          _buildViewfinderOverlay(),
        ],
      ),
    );
  }

  Widget _buildViewfinderOverlay() {
    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final double width = constraints.maxWidth;
        final double height = constraints.maxHeight;
        final double overlaySize = width * 0.65;  // Adjust size to your preference

        return Stack(
          children: <Widget>[
            Container(
              color: Colors.black.withOpacity(0.5),
            ),
            Center(
              child: Container(
                width: overlaySize,
                height: overlaySize,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Colors.white,
                    width: 2.0,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
