import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/crypto/address_codec.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/models/wallet_profile.dart';

void main() {
  const pubKey = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';
  const profile = WalletProfile(
    displayName: 'Ahmad Khalil',
    phone: '+970 59 123 4567',
    iban: 'PS92APAB123456789012345678901',
  );

  group('encodeAddress / decodeAddress', () {
    test('roundtrip returns original publicKey and profile', () {
      final encoded = encodeAddress(pubKey, profile);
      final result = decodeAddress(encoded);
      expect(result.publicKey, pubKey);
      expect(result.profile, profile);
    });

    test('returns null profile when profile fields absent', () {
      final noProfile =
          '{"type":"kashi_address","v":1,"public_key":"$pubKey"}';
      final result = decodeAddress(noProfile);
      expect(result.publicKey, pubKey);
      expect(result.profile, isNull);
    });

    test('throws when type is wrong', () {
      final bad = '{"type":"other","v":1,"public_key":"$pubKey"}';
      expect(() => decodeAddress(bad), throwsFormatException);
    });

    test('throws on unsupported version', () {
      final bad =
          '{"type":"kashi_address","v":99,"public_key":"$pubKey"}';
      expect(() => decodeAddress(bad), throwsFormatException);
    });

    test('throws when public_key is missing', () {
      const bad = '{"type":"kashi_address","v":1}';
      expect(() => decodeAddress(bad), throwsFormatException);
    });

    test('throws when public_key is empty string', () {
      const bad = '{"type":"kashi_address","v":1,"public_key":""}';
      expect(() => decodeAddress(bad), throwsFormatException);
    });

    test('throws on non-JSON input', () {
      expect(() => decodeAddress('not json at all'), throwsFormatException);
    });

    test('encoded string contains expected fields', () {
      final encoded = encodeAddress(pubKey, profile);
      expect(encoded, contains('"type":"kashi_address"'));
      expect(encoded, contains('"v":1'));
      expect(encoded, contains(pubKey));
      expect(encoded, contains('Ahmad Khalil'));
    });
  });
}
