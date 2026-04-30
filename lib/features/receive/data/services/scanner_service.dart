import 'dart:convert';

import '../../../send/data/models/payment_payload.dart';

class ScannerService {
  const ScannerService();

  SignedEnvelope parse(String raw) {
    final decoded = utf8.decode(base64Decode(raw));
    final json = jsonDecode(decoded);
    if (json is! Map) {
      throw const FormatException('QR payload is not an object');
    }
    return SignedEnvelope.fromJson(json.cast<String, dynamic>());
  }
}
