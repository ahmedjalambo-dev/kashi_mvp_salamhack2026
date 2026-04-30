import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../../core/services/secure_storage.dart';
import '../models/payment_payload.dart';
import '../services/payment_signer.dart';

class SendRepository {
  SendRepository({
    required PaymentSigner paymentSigner,
    required SecureStorage secureStorage,
    required Uuid uuid,
    required ErrorHandler errors,
    Random? random,
  })  : _paymentSigner = paymentSigner,
        _storage = secureStorage,
        _uuid = uuid,
        _errors = errors,
        _random = random ?? Random.secure();

  final PaymentSigner _paymentSigner;
  final SecureStorage _storage;
  final Uuid _uuid;
  final ErrorHandler _errors;
  final Random _random;

  Future<Result<String>> buildSignedQr({
    required String senderPublicKey,
    required String receiverPublicKey,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        return const Failure(
          ErrorModel(message: 'Amount must be greater than 0', code: 'AMOUNT'),
        );
      }
      final priv = await _storage.read(AppConstants.secureStoragePrivateKey);
      if (priv == null) {
        return const Failure(
          ErrorModel(message: 'Private key missing', code: 'NO_KEY'),
        );
      }
      final now = DateTime.now().toUtc();
      final payload = PaymentPayload(
        id: _uuid.v4(),
        senderPublicKey: senderPublicKey,
        receiverPublicKey: receiverPublicKey,
        amount: amount,
        nonce: _nonce(),
        clientCreatedAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
      );
      final signature = _paymentSigner.sign(payload, priv);
      final envelope = SignedEnvelope(payload: payload, signature: signature);
      return Success(base64Encode(utf8.encode(jsonEncode(envelope.toJson()))));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  String _nonce() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }
}
