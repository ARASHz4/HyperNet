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
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: MobileScanner(
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
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 24,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _circleButton(
                      icon: Icons.cameraswitch_outlined,
                      label: l10n.switchCamera,
                      onPressed: () => _controller.switchCamera(),
                    ),
                    ValueListenableBuilder<MobileScannerState>(
                      valueListenable: _controller,
                      builder: (_, state, _) {
                        return _circleButton(
                          icon: state.torchState == TorchState.on
                              ? Icons.flash_on
                              : Icons.flash_off,
                          label: l10n.flash,
                          onPressed: () => _controller.toggleTorch(),
                        );
                      },
                    ),
                    _circleButton(
                      icon: Icons.photo_library_outlined,
                      label: l10n.gallery,
                      onPressed: _pickAndScanImage,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        InkWell(
          customBorder: const CircleBorder(),
          onTap: onPressed,
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      ],
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

      if (!mounted) return;

      if (code != null) {
        Navigator.pop(context, code);
        return;
      }
    } catch (_) {}

    if (mounted) {
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.noQrFoundInPhoto)),
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
