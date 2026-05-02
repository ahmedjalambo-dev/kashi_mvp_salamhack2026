import 'package:flutter/material.dart';

import '../../../core/components/scanner_view.dart';
import '../../../core/crypto/address_codec.dart';
import '../../../core/routes/routes.dart';
import '../../wallet/data/models/wallet_profile.dart';

class ScanRecipientScreen extends StatefulWidget {
  const ScanRecipientScreen({
    super.key,
    required this.senderPub,
    required this.senderProfile,
  });

  final String senderPub;
  final WalletProfile senderProfile;

  @override
  State<ScanRecipientScreen> createState() => _ScanRecipientScreenState();
}

class _ScanRecipientScreenState extends State<ScanRecipientScreen> {
  bool _handling = false;
  String? _error;

  void _onDetect(String raw) {
    if (_handling) return;
    _handling = true;

    final AddressResult result;
    try {
      result = decodeAddress(raw);
    } on FormatException catch (e) {
      setState(() => _error = e.message);
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _error = null;
            _handling = false;
          });
        }
      });
      return;
    }

    final receiverProfile = result.profile;
    if (receiverProfile == null) {
      setState(() => _error = 'Address QR is missing profile information');
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) {
          setState(() {
            _error = null;
            _handling = false;
          });
        }
      });
      return;
    }

    Navigator.pushReplacementNamed(
      context,
      Routes.send,
      arguments: (
        senderPub: widget.senderPub,
        receiverPub: result.publicKey,
        senderProfile: widget.senderProfile,
        receiverProfile: receiverProfile,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scan recipient address')),
      body: Stack(
        children: [
          ScannerView(onDetect: _onDetect),
          Positioned(
            bottom: 32,
            left: 24,
            right: 24,
            child: Column(
              children: [
                if (_error != null)
                  Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Ask the recipient to open My Address',
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
