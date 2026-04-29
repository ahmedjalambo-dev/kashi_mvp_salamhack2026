import '../../../../core/crypto/ecdsa_signer.dart';
import '../../../../core/crypto/payload_codec.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../send/data/models/payment_payload.dart';
import '../services/pending_tx_local_service.dart';
import '../services/scanner_service.dart';

class ReceiveRepository {
  ReceiveRepository({
    required ScannerService scanner,
    required PendingTxLocalService pendingTx,
    required EcdsaSigner signer,
    required PayloadCodec codec,
    required ErrorHandler errors,
  })  : _scanner = scanner,
        _pending = pendingTx,
        _signer = signer,
        _codec = codec,
        _errors = errors;

  final ScannerService _scanner;
  final PendingTxLocalService _pending;
  final EcdsaSigner _signer;
  final PayloadCodec _codec;
  final ErrorHandler _errors;

  Future<Result<SignedEnvelope>> handleScan(
    String raw,
    String myPublicKey,
  ) async {
    try {
      final envelope = _scanner.parse(raw);
      final p = envelope.payload;

      if (p.senderPublicKey.isEmpty ||
          p.receiverPublicKey.isEmpty ||
          envelope.signature.isEmpty ||
          p.id.isEmpty ||
          p.nonce.isEmpty) {
        return const Failure(
          ErrorModel(message: 'Malformed payload', code: 'MALFORMED'),
        );
      }
      if (p.receiverPublicKey != myPublicKey) {
        return const Failure(
          ErrorModel(message: 'QR is for a different wallet', code: 'WRONG_RECEIVER'),
        );
      }
      if (p.amount <= 0) {
        return const Failure(
          ErrorModel(message: 'Invalid amount', code: 'AMOUNT'),
        );
      }

      final bytes = _codec.canonicalBytes(p.toJson());
      final ok = _signer.verify(bytes, envelope.signature, p.senderPublicKey);
      if (!ok) {
        return const Failure(
          ErrorModel(message: 'Invalid signature', code: 'BAD_SIG'),
        );
      }

      await _pending.insert(envelope);
      return Success(envelope);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }
}

