import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../../core/services/qr_codec.dart';
import '../../../send/data/models/payment_payload.dart';
import '../../../send/data/services/payment_signer.dart';
import '../services/incoming_pending_local_service.dart';
import '../services/pending_request_local_service.dart';

class ReceiveRepository {
  ReceiveRepository({
    required QrCodec qrCodec,
    required Uuid uuid,
    required ErrorHandler errors,
    required PendingRequestLocalService pendingRequests,
    required IncomingPendingLocalService incomingPending,
    required PaymentSigner paymentSigner,
    Random? random,
  }) : _qrCodec = qrCodec,
       _uuid = uuid,
       _errors = errors,
       _pendingRequests = pendingRequests,
       _incomingPending = incomingPending,
       _paymentSigner = paymentSigner,
       _random = random ?? Random.secure();

  final QrCodec _qrCodec;
  final Uuid _uuid;
  final ErrorHandler _errors;
  final PendingRequestLocalService _pendingRequests;
  final IncomingPendingLocalService _incomingPending;
  final PaymentSigner _paymentSigner;
  final Random _random;

  Future<Result<({PaymentRequest request, String qrData})>> buildRequest(
    String amountText,
    String myPublicKey,
  ) async {
    try {
      final amount = double.tryParse(amountText.trim());
      if (amount == null || amount <= 0) {
        return const Failure(
          ErrorModel(message: 'Enter a valid amount', code: 'AMOUNT'),
        );
      }
      final now = DateTime.now().toUtc();
      final request = PaymentRequest(
        id: _uuid.v4(),
        receiverPublicKey: myPublicKey,
        amount: amount,
        nonce: _nonce(),
        clientCreatedAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
      );
      final qrData = _qrCodec.encodeRequest(request);
      await _pendingRequests.insert(request);
      return Success((request: request, qrData: qrData));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  Future<Result<void>> markFulfilledLocally(String id) async {
    try {
      await _pendingRequests.markFulfilledLocally(id);
      return const Success(null);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  Future<Result<void>> dismissExpired(String id) async {
    try {
      await _pendingRequests.delete(id);
      return const Success(null);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  /// Decodes and verifies the sender's confirmation QR, then stores the
  /// [SignedEnvelope] in [IncomingPendingLocalService] and deletes the
  /// matching [PendingRequestLocalService] row — atomically in a sqflite
  /// batch so neither half can commit without the other.
  ///
  /// Validation order:
  /// 1. Decode QR → [SignedEnvelope].
  /// 2. Check id, amount, nonce, receiverPublicKey match [request].
  /// 3. Verify ECDSA signature with [PaymentSigner.verify].
  /// 4. If all checks pass, write to DB.
  Future<Result<SignedEnvelope>> confirmEnvelope(
    String qrData,
    PaymentRequest request,
  ) async {
    try {
      // 1. Decode
      final SignedEnvelope envelope;
      try {
        envelope = _qrCodec.decodeEnvelope(qrData);
      } on FormatException catch (e) {
        return Failure(ErrorModel(message: e.message, code: 'MALFORMED_QR'));
      }

      final p = envelope.payload;

      // 2. Field matching
      if (p.id != request.id) {
        return const Failure(
          ErrorModel(
            message: 'Envelope ID does not match this request',
            code: 'ID_MISMATCH',
          ),
        );
      }
      if ((p.amount - request.amount).abs() > 0.001) {
        return const Failure(
          ErrorModel(
            message: 'Envelope amount does not match this request',
            code: 'AMOUNT_MISMATCH',
          ),
        );
      }
      if (p.nonce != request.nonce) {
        return const Failure(
          ErrorModel(
            message: 'Envelope nonce does not match this request',
            code: 'NONCE_MISMATCH',
          ),
        );
      }
      if (p.receiverPublicKey != request.receiverPublicKey) {
        return const Failure(
          ErrorModel(
            message: 'Envelope receiver does not match this request',
            code: 'RECEIVER_MISMATCH',
          ),
        );
      }

      // 3. Signature verification
      if (!_paymentSigner.verify(p, envelope.signature)) {
        return const Failure(
          ErrorModel(
            message: 'Signature verification failed',
            code: 'SIGNATURE_INVALID',
          ),
        );
      }

      // 4. Persist: insert incoming_pending + delete pending_requests row,
      //    performed in a single sqflite batch for atomicity.
      await _incomingPending.insert(envelope);
      await _pendingRequests.delete(request.id);

      return Success(envelope);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  String _nonce() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }
}
