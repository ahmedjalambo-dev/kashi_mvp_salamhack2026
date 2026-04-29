import '../../../../core/crypto/ecdsa_signer.dart';
import '../../../../core/crypto/payload_codec.dart';
import '../models/payment_payload.dart';

class PaymentSigner {
  PaymentSigner({required EcdsaSigner signer, required PayloadCodec codec})
      : _signer = signer,
        _codec = codec;

  final EcdsaSigner _signer;
  final PayloadCodec _codec;

  String sign(PaymentPayload payload, String privateKeyBase64) {
    final bytes = _codec.canonicalBytes(payload.toJson());
    return _signer.sign(bytes, privateKeyBase64);
  }

  bool verify(PaymentPayload payload, String signature) {
    final bytes = _codec.canonicalBytes(payload.toJson());
    return _signer.verify(bytes, signature, payload.senderPublicKey);
  }
}
