import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:pointycastle/export.dart';

class EcdsaKeyPair {
  final String privateKeyBase64;
  final String publicKeyBase64;
  const EcdsaKeyPair(this.privateKeyBase64, this.publicKeyBase64);
}

/// secp256r1 (P-256) ECDSA with SHA-256.
/// Keys serialized as base64 of raw d (private) or uncompressed point (public).
class EcdsaSigner {
  EcdsaSigner({SecureRandom? random}) : _random = random ?? _seededRandom();

  final SecureRandom _random;
  final ECDomainParameters _params = ECDomainParameters('secp256r1');

  static SecureRandom _seededRandom() {
    final r = FortunaRandom();
    final seed = Random.secure();
    final seedBytes = Uint8List.fromList(
      List<int>.generate(32, (_) => seed.nextInt(256)),
    );
    r.seed(KeyParameter(seedBytes));
    return r;
  }

  EcdsaKeyPair generateKeyPair() {
    final generator = ECKeyGenerator()
      ..init(ParametersWithRandom(ECKeyGeneratorParameters(_params), _random));
    final pair = generator.generateKeyPair();
    final priv = pair.privateKey as ECPrivateKey;
    final pub = pair.publicKey as ECPublicKey;
    return EcdsaKeyPair(
      base64Encode(_unsignedBytes(priv.d!, 32)),
      base64Encode(_encodePublic(pub)),
    );
  }

  String sign(Uint8List message, String privateKeyBase64) {
    final dBytes = base64Decode(privateKeyBase64);
    final d = _readBigInt(dBytes);
    final priv = ECPrivateKey(d, _params);

    final signer = Signer('SHA-256/ECDSA')
      ..init(true, ParametersWithRandom(PrivateKeyParameter<ECPrivateKey>(priv), _random));
    final sig = signer.generateSignature(message) as ECSignature;
    final r = _unsignedBytes(sig.r, 32);
    final s = _unsignedBytes(sig.s, 32);
    final out = Uint8List(64)..setRange(0, 32, r)..setRange(32, 64, s);
    return base64Encode(out);
  }

  bool verify(Uint8List message, String signatureBase64, String publicKeyBase64) {
    try {
      final sigBytes = base64Decode(signatureBase64);
      if (sigBytes.length != 64) return false;
      final r = _readBigInt(sigBytes.sublist(0, 32));
      final s = _readBigInt(sigBytes.sublist(32, 64));
      final pub = _decodePublic(base64Decode(publicKeyBase64));
      final verifier = Signer('SHA-256/ECDSA')
        ..init(false, PublicKeyParameter<ECPublicKey>(pub));
      return verifier.verifySignature(message, ECSignature(r, s));
    } catch (_) {
      return false;
    }
  }

  Uint8List _encodePublic(ECPublicKey pub) {
    return pub.Q!.getEncoded(false);
  }

  ECPublicKey _decodePublic(Uint8List bytes) {
    final point = _params.curve.decodePoint(bytes);
    if (point == null) {
      throw const FormatException('Invalid EC public key encoding');
    }
    return ECPublicKey(point, _params);
  }

  Uint8List _unsignedBytes(BigInt value, int length) {
    final hex = value.toRadixString(16).padLeft(length * 2, '0');
    final out = Uint8List(length);
    for (var i = 0; i < length; i++) {
      out[i] = int.parse(hex.substring(i * 2, i * 2 + 2), radix: 16);
    }
    return out;
  }

  BigInt _readBigInt(Uint8List bytes) {
    var result = BigInt.zero;
    for (final b in bytes) {
      result = (result << 8) | BigInt.from(b & 0xff);
    }
    return result;
  }
}
