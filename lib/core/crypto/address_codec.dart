import 'dart:convert';

const _addressType = 'kashi_address';
const _addressVersion = 1;

String encodeAddress(String publicKey) {
  return jsonEncode({
    'type': _addressType,
    'v': _addressVersion,
    'public_key': publicKey,
  });
}

/// Decodes a Kashi address QR string and returns the public key.
/// Throws [FormatException] on invalid JSON, wrong type, or unsupported version.
String decodeAddress(String raw) {
  final Map<String, dynamic> map;
  try {
    map = jsonDecode(raw) as Map<String, dynamic>;
  } catch (_) {
    throw const FormatException('Not a valid Kashi address QR');
  }
  if (map['type'] != _addressType) {
    throw const FormatException('QR code is not a Kashi address');
  }
  if (map['v'] != _addressVersion) {
    throw FormatException('Unsupported address version: ${map['v']}');
  }
  final pubKey = map['public_key'];
  if (pubKey is! String || pubKey.isEmpty) {
    throw const FormatException('Missing public_key in address QR');
  }
  return pubKey;
}
