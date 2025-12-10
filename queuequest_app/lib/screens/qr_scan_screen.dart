import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _handled = false;

  Future<void> _handleBarcode(String rawValue) async {
    if (_handled) return;
    _handled = true;

    try {
      final uri = Uri.parse(rawValue);
      final comercioId = uri.queryParameters['cola'];

      if (comercioId == null) {
        throw Exception('El QR no contiene el parámetro "cola".');
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/commerce',
        arguments: comercioId,
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('QR no válido: $e')),
      );
      _handled = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR')),
      body: MobileScanner(
        onDetect: (capture) {
          final barcode = capture.barcodes.first;
          final rawValue = barcode.rawValue;
          if (rawValue != null) {
            _handleBarcode(rawValue);
          }
        },
      ),
    );
  }
}
