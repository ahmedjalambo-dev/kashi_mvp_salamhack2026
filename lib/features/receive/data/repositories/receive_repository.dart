import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../../core/services/qr_codec.dart';
import '../../../send/data/models/payment_payload.dart';

class ReceiveRepository {
  ReceiveRepository({
    required QrCodec qrCodec,
    required Uuid uuid,
    required ErrorHandler errors,
    Random? random,
  }) : _qrCodec = qrCodec,
       _uuid = uuid,
       _errors = errors,
       _random = random ?? Random.secure();

  final QrCodec _qrCodec;
  final Uuid _uuid;
  final ErrorHandler _errors;
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
      return Success((request: request, qrData: qrData));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  String _nonce() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }
}
