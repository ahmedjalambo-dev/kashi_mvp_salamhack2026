import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/src/core/crypto/ecdsa_signer.dart';
import 'package:kashi_mvp_salamhack2026/src/core/crypto/payload_codec.dart';

void main() {
  test('canonical encoding sorts keys deterministically', () {
    const codec = PayloadCodec();
    final a = codec.canonicalEncode({
      'b': 1,
      'a': 2,
      'c': {'y': 1, 'x': 2},
    });
    final b = codec.canonicalEncode({
      'c': {'x': 2, 'y': 1},
      'a': 2,
      'b': 1,
    });
    expect(a, equals(b));
  });

  test('ECDSA sign + verify round-trips', () {
    final signer = EcdsaSigner();
    final pair = signer.generateKeyPair();
    const codec = PayloadCodec();
    final bytes = codec.canonicalBytes({
      'id': 'abc',
      'amount': 10.5,
      'nonce': 'n1',
    });
    final sig = signer.sign(bytes, pair.privateKeyBase64);
    expect(signer.verify(bytes, sig, pair.publicKeyBase64), isTrue);
  });

  test('ECDSA rejects tampered payload', () {
    final signer = EcdsaSigner();
    final pair = signer.generateKeyPair();
    const codec = PayloadCodec();
    final original = codec.canonicalBytes({'id': 'x', 'amount': 5});
    final sig = signer.sign(original, pair.privateKeyBase64);
    final tampered = codec.canonicalBytes({'id': 'x', 'amount': 50});
    expect(signer.verify(tampered, sig, pair.publicKeyBase64), isFalse);
  });
}
