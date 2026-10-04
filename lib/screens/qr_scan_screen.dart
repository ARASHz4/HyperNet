import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:hyper_net/l10n/app_localizations.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  bool _done = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.scanQrCode),
      ),
      body: MobileScanner(
        onDetect: (capture) {
          if (_done) return;

          final code = capture.barcodes.isNotEmpty
              ? capture.barcodes.first.rawValue
              : null;

          if (code != null) {
            _done = true;
            Navigator.pop(context, code);
          }
        },
      ),
    );
  }
}

class QrScanInput {
  static Future<String?> scan(BuildContext context) {
    return Navigator.push<String?>(
      context,
      MaterialPageRoute(builder: (_) => const QrScanScreen()),
    );
  }
}
