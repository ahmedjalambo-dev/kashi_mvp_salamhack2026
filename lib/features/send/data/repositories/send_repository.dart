import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';
import '../../../wallet/data/models/wallet_profile.dart';
import '../../../wallet/data/services/wallet_local_service.dart';
import '../models/payment_payload.dart';
import '../services/payment_signer.dart';

class SendRepository {
  SendRepository({
    required PaymentSigner paymentSigner,
    required SecureStorage secureStorage,
    required Uuid uuid,
    required ErrorHandler errors,
    required WalletLocalService walletLocal,
    required PendingTxLocalService pendingTx,
    Random? random,
  }) : _paymentSigner = paymentSigner,
       _storage = secureStorage,
       _uuid = uuid,
       _errors = errors,
       _walletLocal = walletLocal,
       _pendingTx = pendingTx,
       _random = random ?? Random.secure();

  final PaymentSigner _paymentSigner;
  final SecureStorage _storage;
  final Uuid _uuid;
  final ErrorHandler _errors;
  final WalletLocalService _walletLocal;
  final PendingTxLocalService _pendingTx;
  final Random _random;

  Future<Result<void>> validateAmount({
    required String senderPublicKey,
    required double amount,
  }) async {
    try {
      if (amount <= 0) {
        return const Failure(
          ErrorModel(message: 'Amount must be greater than 0', code: 'AMOUNT'),
        );
      }
      final cached = await _walletLocal.loadCached(senderPublicKey);
      if (cached == null) {
        return const Failure(
          ErrorModel(
            message:
                'Balance not yet synced. Connect to the internet once before sending.',
            code: 'NO_CACHE',
          ),
        );
      }
      final reserved = await _pendingTx.pendingOutgoingSum(senderPublicKey);
      final available = cached.balance - reserved;
      if (amount > available) {
        return Failure(
          ErrorModel(
            message:
                'Insufficient funds. Available: ${available.toStringAsFixed(2)}',
            code: 'INSUFFICIENT_FUNDS',
          ),
        );
      }
      return const Success(null);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  Future<Result<({String qrData, String transactionId})>> buildSignedQr({
    required String senderPublicKey,
    required String receiverPublicKey,
    required double amount,
    required WalletProfile senderProfile,
    required WalletProfile receiverProfile,
  }) async {
    try {
      if (amount <= 0) {
        return const Failure(
          ErrorModel(message: 'Amount must be greater than 0', code: 'AMOUNT'),
        );
      }

      // Offline balance validation: require a cached balance so we can
      // enforce the available-funds check before generating the QR.
      final cached = await _walletLocal.loadCached(senderPublicKey);
      if (cached == null) {
        return const Failure(
          ErrorModel(
            message:
                'Balance not yet synced. Connect to the internet once before sending.',
            code: 'NO_CACHE',
          ),
        );
      }

      // Deduct already-pending outgoing transactions to prevent overdraft.
      final reserved = await _pendingTx.pendingOutgoingSum(senderPublicKey);
      final available = cached.balance - reserved;
      if (amount > available) {
        return Failure(
          ErrorModel(
            message:
                'Insufficient funds. Available: ${available.toStringAsFixed(2)}',
            code: 'INSUFFICIENT_FUNDS',
          ),
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
        senderDisplayName: senderProfile.displayName,
        senderPhone: senderProfile.phone,
        senderIban: senderProfile.iban,
      );
      final signature = _paymentSigner.sign(payload, priv);
      final envelope = SignedEnvelope(payload: payload, signature: signature);

      // Optimistic deduction: insert the outgoing tx into pending_transactions
      // on the sender's device. This immediately reduces pendingOutgoingSum so
      // the sender cannot double-spend remaining offline balance. SyncCubit
      // will push this row; the RPC is idempotent so whichever side (sender or
      // receiver) reaches Supabase first wins and the other becomes a no-op.
      await _pendingTx.insert(
        envelope,
        counterpartyName: receiverProfile.displayName,
        counterpartyPhone: receiverProfile.phone,
        counterpartyIban: receiverProfile.iban,
      );

      return Success((
        qrData: base64Encode(utf8.encode(jsonEncode(envelope.toJson()))),
        transactionId: payload.id,
      ));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  Future<Result<int>> cancelPendingTransaction(
    String transactionId,
    double amount, // amount kept for API symmetry; the math is done via pendingOutgoingSum
  ) async {
    try {
      final affected = await _pendingTx.markVoidedLocally(transactionId);
      if (affected == 0) {
        return const Failure(
          ErrorModel(
            message: 'This transfer was already synced — too late to cancel.',
            code: 'ALREADY_SYNCED',
          ),
        );
      }
      return Success(affected);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  String _nonce() {
    final bytes = List<int>.generate(16, (_) => _random.nextInt(256));
    return base64Encode(bytes);
  }
}
