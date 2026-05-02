import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/crypto/address_codec.dart';
import '../../wallet/data/models/wallet_profile.dart';

class MyAddressScreen extends StatelessWidget {
  const MyAddressScreen({
    super.key,
    required this.publicKey,
    required this.profile,
  });

  final String publicKey;
  final WalletProfile profile;

  @override
  Widget build(BuildContext context) {
    final qrData = encodeAddress(publicKey, profile);
    final theme = Theme.of(context);

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
            const SizedBox(height: 20),
            _ProfileRow(label: 'Name', value: profile.displayName, theme: theme),
            const SizedBox(height: 8),
            _ProfileRow(label: 'Phone', value: profile.phone, theme: theme, mono: true),
            const SizedBox(height: 8),
            _ProfileRow(label: 'IBAN', value: profile.iban, theme: theme, mono: true),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: profile.iban));
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('IBAN copied')),
                );
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy IBAN'),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileRow extends StatelessWidget {
  const _ProfileRow({
    required this.label,
    required this.value,
    required this.theme,
    this.mono = false,
  });

  final String label;
  final String value;
  final ThemeData theme;
  final bool mono;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 52,
          child: Text(label, style: theme.textTheme.labelSmall),
        ),
        Expanded(
          child: SelectableText(
            value,
            style: mono
                ? theme.textTheme.bodySmall?.copyWith(fontFamily: 'monospace')
                : theme.textTheme.bodySmall,
          ),
        ),
      ],
    );
  }
}
