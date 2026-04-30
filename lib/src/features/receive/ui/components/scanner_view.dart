import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key, required this.onDetect});
  final void Function(String raw) onDetect;

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  late final MobileScannerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        MobileScanner(
          controller: _controller,
          onDetect: (capture) {
            for (final barcode in capture.barcodes) {
              final raw = barcode.rawValue;
              if (raw != null && raw.isNotEmpty) {
                widget.onDetect(raw);
                return;
              }
            }
          },
        ),
        // Dark overlay with cutout and corners
        Positioned.fill(
          child: CustomPaint(
            painter: _ScannerOverlayPainter(
              overlayColor: const Color(0xDA0A0A0A),
              cornerColor: Theme.of(context).colorScheme.tertiary, // Gold
            ),
          ),
        ),
        // Instruction text
        Positioned(
          top: MediaQuery.of(context).padding.top + 64,
          left: 24,
          right: 24,
          child: Text(
            'Point your camera at a Kashi QR code',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  final Color overlayColor;
  final Color cornerColor;

  _ScannerOverlayPainter({
    required this.overlayColor,
    required this.cornerColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw dark overlay with transparent center
    final backgroundPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height));

    const cutoutSize = 260.0;
    final cutoutRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: cutoutSize,
      height: cutoutSize,
    );
    final cutoutPath = Path()
      ..addRRect(
        RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)),
      );

    final path = Path.combine(
      PathOperation.difference,
      backgroundPath,
      cutoutPath,
    );

    final paint = Paint()..color = overlayColor;
    canvas.drawPath(path, paint);

    // 2. Draw gold corners
    final cornerPaint = Paint()
      ..color = cornerColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0;

    const len = 36.0;

    // Top Left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.top + len)
        ..lineTo(cutoutRect.left, cutoutRect.top + 16)
        ..arcToPoint(
          Offset(cutoutRect.left + 16, cutoutRect.top),
          radius: const Radius.circular(16),
        )
        ..lineTo(cutoutRect.left + len, cutoutRect.top),
      cornerPaint,
    );

    // Top Right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right, cutoutRect.top + len)
        ..lineTo(cutoutRect.right, cutoutRect.top + 16)
        ..arcToPoint(
          Offset(cutoutRect.right - 16, cutoutRect.top),
          radius: const Radius.circular(16),
          clockwise: false,
        )
        ..lineTo(cutoutRect.right - len, cutoutRect.top),
      cornerPaint,
    );

    // Bottom Left
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.left, cutoutRect.bottom - len)
        ..lineTo(cutoutRect.left, cutoutRect.bottom - 16)
        ..arcToPoint(
          Offset(cutoutRect.left + 16, cutoutRect.bottom),
          radius: const Radius.circular(16),
          clockwise: false,
        )
        ..lineTo(cutoutRect.left + len, cutoutRect.bottom),
      cornerPaint,
    );

    // Bottom Right
    canvas.drawPath(
      Path()
        ..moveTo(cutoutRect.right, cutoutRect.bottom - len)
        ..lineTo(cutoutRect.right, cutoutRect.bottom - 16)
        ..arcToPoint(
          Offset(cutoutRect.right - 16, cutoutRect.bottom),
          radius: const Radius.circular(16),
        )
        ..lineTo(cutoutRect.right - len, cutoutRect.bottom),
      cornerPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _ScannerOverlayPainter oldDelegate) {
    return oldDelegate.overlayColor != overlayColor ||
        oldDelegate.cornerColor != cornerColor;
  }
}
