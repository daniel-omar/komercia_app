import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController cameraController = MobileScannerController();
  bool isDetected = false;
  late AnimationController _animationController;
  Barcode? _barcode;
  String? _code;

  @override
  void initState() {
    super.initState();
    _animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2))
          ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    cameraController.dispose();
    super.dispose();
  }

  Widget _buildBarcode(String? value) {
    if (value == null) {
      return const Text(
        "No hay valor",
        overflow: TextOverflow.fade,
        style: TextStyle(color: Colors.white),
      );
    }

    return Text(
      value,
      overflow: TextOverflow.fade,
      style: const TextStyle(color: Colors.white),
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (mounted && !isDetected) {
      _barcode = barcodes.barcodes.firstOrNull;

      setState(() {
        if (_barcode == null) return;
        _code = _barcode!.rawValue;
        if (_code == null) return;
        isDetected = true;
        Navigator.of(context, rootNavigator: true).pop(_code);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Centrado
    const scanBoxSize = 250.0;
    final left = (screenWidth - scanBoxSize) / 2;
    final topStart = (screenHeight - scanBoxSize) / 3;

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear código')),
      body: Stack(
        children: [
          MobileScanner(
            controller: cameraController,
            onDetect: _handleBarcode,
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              final animatedTop =
                  topStart + (_animationController.value * scanBoxSize);

              return Positioned(
                top: animatedTop,
                left: left,
                child: Container(
                  width: 250,
                  height: 2,
                  color: Colors.redAccent,
                ),
              );
            },
          ),
          // Botón de linterna
          Positioned(
            bottom: 40,
            left: MediaQuery.of(context).size.width / 2 - 25,
            child: IconButton(
              icon: const Icon(Icons.flash_on, size: 40, color: Colors.white),
              onPressed: () => cameraController.toggleTorch(),
            ),
          ),
          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: Container(
          //     alignment: Alignment.bottomCenter,
          //     height: 100,
          //     child: Row(
          //       mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //       children: [
          //         Expanded(
          //             child: Center(
          //           child: _buildBarcode(_code),
          //         ))
          //       ],
          //     ),
          //   ),
          // )
        ],
      ),
    );
  }
}
