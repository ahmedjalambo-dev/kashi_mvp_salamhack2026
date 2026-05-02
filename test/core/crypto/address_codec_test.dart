import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/crypto/address_codec.dart';

void main() {
  const pubKey = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=';

  group('encodeAddress / decodeAddress', () {
    test('roundtrip returns original public key', () {
      final encoded = encodeAddress(pubKey);
      expect(decodeAddress(encoded), pubKey);
    });

    test('throws when type is wrong', () {
      final bad = '{"type":"other","v":1,"public_key":"$pubKey"}';
      expect(() => decodeAddress(bad), throwsFormatException);
    });

    test('throws on unsupported version', () {
      final bad = '{"type":"kashi_address","v":99,"public_key":"$pubKey"}';
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
      final encoded = encodeAddress(pubKey);
      expect(encoded, contains('"type":"kashi_address"'));
      expect(encoded, contains('"v":1'));
      expect(encoded, contains(pubKey));
    });
  });
}
