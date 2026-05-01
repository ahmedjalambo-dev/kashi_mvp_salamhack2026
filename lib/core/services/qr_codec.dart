import 'dart:convert';

import '../../features/send/data/models/payment_payload.dart';

class QrCodec {
  const QrCodec();

  String encodeRequest(PaymentRequest r) =>
      base64Encode(utf8.encode(jsonEncode(r.toJson())));

  /// Throws [FormatException] if [raw] is malformed or not a Kashi request.
  PaymentRequest decodeRequest(String raw) {
    final Map<String, dynamic> map;
    try {
      final decoded = utf8.decode(base64Decode(raw));
      final json = jsonDecode(decoded);
      if (json is! Map) throw const FormatException('QR payload is not an object');
      map = json.cast<String, dynamic>();
    } catch (e) {
      if (e is FormatException) rethrow;
      throw const FormatException('Cannot decode QR data');
    }
    if (map['type'] != 'request') {
      throw const FormatException('Not a Kashi payment request');
    }
    return PaymentRequest.fromJson(map);
  }
}
