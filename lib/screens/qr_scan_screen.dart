import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hyper_net/l10n/app_localizations.dart';

class QrScanScreen extends StatefulWidget {
  const QrScanScreen({super.key});

  @override
  State<QrScanScreen> createState() => _QrScanScreenState();
}

class _QrScanScreenState extends State<QrScanScreen> {
  final _controller = MobileScannerController();
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.scanQrCode),
        actions: [
          IconButton(
            icon: const Icon(Icons.cameraswitch),
            onPressed: () => _controller.switchCamera(),
          ),
          ValueListenableBuilder<MobileScannerState>(
            valueListenable: _controller,
            builder: (_, state, __) {
              return IconButton(
                icon: Icon(
                  state.torchState == TorchState.on ? Icons.flash_on : Icons.flash_off,
                ),
                onPressed: () => _controller.toggleTorch(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.photo_library_outlined),
            onPressed: _pickAndScanImage,
          ),
        ],
      ),
      body: MobileScanner(
        controller: _controller,
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

  Future<void> _pickAndScanImage() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image == null || !mounted) return;

    try {
      final capture = await _controller.analyzeImage(image.path);
      final code = capture != null && capture.barcodes.isNotEmpty
          ? capture.barcodes.first.rawValue
          : null;

      if (code != null) {
        Navigator.pop(context, code);
        return;
      }
    } catch (_) {}

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No QR code found in that photo.')),
      );
    }
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
