import 'dart:convert';

import '../../features/wallet/data/models/wallet_profile.dart';

const _addressType = 'kashi_address';
const _addressVersion = 1;

String encodeAddress(String publicKey, WalletProfile profile) {
  return jsonEncode({
    'type': _addressType,
    'v': _addressVersion,
    'public_key': publicKey,
    'display_name': profile.displayName,
    'phone': profile.phone,
    'iban': profile.iban,
  });
}

typedef AddressResult = ({String publicKey, WalletProfile? profile});

/// Decodes a Kashi address QR string. Returns [publicKey] and an optional
/// [profile] (null only when all three profile fields are absent — legacy fallback).
/// Throws [FormatException] on invalid JSON, wrong type, unsupported version,
/// or missing [publicKey].
AddressResult decodeAddress(String raw) {
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

  final dn = map['display_name'] as String?;
  final ph = map['phone'] as String?;
  final ib = map['iban'] as String?;

  WalletProfile? profile;
  if (dn != null && ph != null && ib != null) {
    profile = WalletProfile(displayName: dn, phone: ph, iban: ib);
  }

  return (publicKey: pubKey, profile: profile);
}
