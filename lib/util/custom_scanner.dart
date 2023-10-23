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
  
  Color _borderColor = Colors.white;  // Initial border color
  
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

  Future<void> _handleScan(BarcodeCapture capture) async {
  final context = this.context;  // Store the BuildContext in a local variable
  
  final List<Barcode> barcodes = capture.barcodes;
  if (barcodes.isNotEmpty) {
    final bool isValid = await validateBarcode(barcodes.first.rawValue!);
    if (mounted) {
      if (isValid) {
        setState(() {
          _borderColor = Colors.green;
        });
        await Future.delayed(Duration(milliseconds: 500));
        if (Navigator.canPop(context)) {
          Navigator.pop(context, barcodes.first.rawValue);
        }
      } else {
        setState(() {
          _borderColor = Colors.red;
        });
        await Future.delayed(Duration(milliseconds: 500));
        if (mounted) {
          setState(() {
            _borderColor = Colors.white;
          });
        }
      }
    }
    
    // Show the barcode numbers using a SnackBar
    final snackBar = SnackBar(content: Text('Barcode: ${barcodes.first.rawValue}'));
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}



  Future<bool> validateBarcode(String barcode) async {
    // Placeholder for validate Barcode logic
    return true;
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
            onDetect: _handleScan,
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
        final double overlaySize = width * 0.65;  // Size of viewfinder overlay

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
                    color: _borderColor,  // Updated border color
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
