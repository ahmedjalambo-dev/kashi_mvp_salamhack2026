import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrDisplay extends StatelessWidget {
  const QrDisplay({super.key, required this.data, required this.amount});
  final String data;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Pay ${amount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black12),
          ),
          child: QrImageView(
            data: data,
            version: QrVersions.auto,
            size: 260,
            errorCorrectionLevel: QrErrorCorrectLevel.M,
          ),
        ),
        const SizedBox(height: 12),
        const Text('Show this code to the receiver'),
      ],
    );
  }
}
