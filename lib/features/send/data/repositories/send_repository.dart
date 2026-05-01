import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../../core/services/qr_codec.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';
import '../../../wallet/data/services/wallet_local_service.dart';
import '../models/payment_payload.dart';
import '../services/payment_signer.dart';

class SendRepository {
  SendRepository({
    required PaymentSigner paymentSigner,
    required SecureStorage secureStorage,
    required QrCodec qrCodec,
    required ErrorHandler errors,
    required WalletLocalService walletLocal,
    required PendingTxLocalService pendingTx,
  }) : _paymentSigner = paymentSigner,
       _storage = secureStorage,
       _qrCodec = qrCodec,
       _errors = errors,
       _walletLocal = walletLocal,
       _pendingTx = pendingTx;

  final PaymentSigner _paymentSigner;
  final SecureStorage _storage;
  final QrCodec _qrCodec;
  final ErrorHandler _errors;
  final WalletLocalService _walletLocal;
  final PendingTxLocalService _pendingTx;

  static const _maxAgeMinutes = 60;
  static const _maxFutureMinutes = 5;

  Future<Result<PaymentRequest>> validateScannedRequest(
    String raw,
    String myPublicKey,
  ) async {
    try {
      final PaymentRequest request;
      try {
        request = _qrCodec.decodeRequest(raw);
      } on FormatException catch (e) {
        return Failure(ErrorModel(message: e.message, code: 'MALFORMED'));
      }

      if (request.receiverPublicKey == myPublicKey) {
        return const Failure(
          ErrorModel(message: 'You cannot pay yourself', code: 'SELF_PAY'),
        );
      }
      if (request.amount <= 0) {
        return const Failure(
          ErrorModel(message: 'Invalid amount', code: 'AMOUNT'),
        );
      }

      final now = DateTime.now().toUtc();
      if (request.clientCreatedAt.isAfter(
        now.add(const Duration(minutes: _maxFutureMinutes)),
      )) {
        return const Failure(
          ErrorModel(
            message: 'QR timestamp is too far in the future',
            code: 'CLOCK_SKEW',
          ),
        );
      }
      final age = now.difference(request.clientCreatedAt);
      if (age.inMinutes > _maxAgeMinutes || now.isAfter(request.expiresAt)) {
        return const Failure(
          ErrorModel(
            message: 'Payment request has expired',
            code: 'EXPIRED',
          ),
        );
      }

      final cached = await _walletLocal.loadCached(myPublicKey);
      if (cached == null) {
        return const Failure(
          ErrorModel(
            message:
                'Balance not yet synced. Connect to the internet once before sending.',
            code: 'NO_CACHE',
          ),
        );
      }
      final reserved = await _pendingTx.pendingOutgoingSum(myPublicKey);
      final available = cached.balance - reserved;
      if (request.amount > available) {
        return Failure(
          ErrorModel(
            message:
                'Insufficient funds. Available: ${available.toStringAsFixed(2)}',
            code: 'INSUFFICIENT_FUNDS',
          ),
        );
      }

      return Success(request);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  Future<Result<({String transactionId, String qrData})>> signAndStore(
    PaymentRequest request,
    String senderPublicKey,
  ) async {
    try {
      final priv = await _storage.read(AppConstants.secureStoragePrivateKey);
      if (priv == null) {
        return const Failure(
          ErrorModel(message: 'Private key missing', code: 'NO_KEY'),
        );
      }
      final payload = PaymentPayload.fromRequest(request, senderPublicKey);
      final signature = _paymentSigner.sign(payload, priv);
      final envelope = SignedEnvelope(payload: payload, signature: signature);
      await _pendingTx.insert(envelope);
      final qrData = _qrCodec.encodeEnvelope(envelope);
      return Success((transactionId: payload.id, qrData: qrData));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }
}
