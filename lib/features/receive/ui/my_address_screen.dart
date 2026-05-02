import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/crypto/address_codec.dart';

class MyAddressScreen extends StatelessWidget {
  const MyAddressScreen({super.key, required this.publicKey});

  final String publicKey;

  @override
  Widget build(BuildContext context) {
    final qrData = encodeAddress(publicKey);
    final truncated = publicKey.length > 20
        ? '${publicKey.substring(0, 12)}…${publicKey.substring(publicKey.length - 8)}'
        : publicKey;

    return Scaffold(
      appBar: AppBar(title: const Text('My Address')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.black12),
                ),
                child: QrImageView(
                  data: qrData,
                  version: QrVersions.auto,
                  size: 260,
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Center(
              child: Text(
                'Ask the sender to scan this code',
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: SelectableText(
                truncated,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: publicKey));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Address copied')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy address'),
            ),
          ],
        ),
      ),
    );
  }
}
