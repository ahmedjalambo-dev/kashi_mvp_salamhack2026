import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/src/core/crypto/ecdsa_signer.dart';
import 'package:kashi_mvp_salamhack2026/src/core/crypto/payload_codec.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/error_handler.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/src/core/services/secure_storage.dart';
import 'package:kashi_mvp_salamhack2026/src/features/receive/data/services/pending_tx_local_service.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/data/models/payment_payload.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/data/repositories/send_repository.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/data/services/payment_signer.dart';
import 'package:kashi_mvp_salamhack2026/src/features/wallet/data/models/wallet_model.dart';
import 'package:kashi_mvp_salamhack2026/src/features/wallet/data/services/wallet_local_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockSecureStorage extends Mock implements SecureStorage {}

class _MockWalletLocalService extends Mock implements WalletLocalService {}

class _MockPendingTxLocalService extends Mock
    implements PendingTxLocalService {}

class _FakeSignedEnvelope extends Fake implements SignedEnvelope {}

// Convenience alias for the record type returned by buildSignedQr.
typedef _QrResult = ({String qrData, String transactionId});

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSignedEnvelope());
  });
  late EcdsaSigner signer;
  late EcdsaKeyPair pair;
  late PaymentSigner paymentSigner;
  late _MockSecureStorage storage;
  late _MockWalletLocalService walletLocal;
  late _MockPendingTxLocalService pendingTx;
  late SendRepository repo;

  const senderPub = 'sender-pub';

  setUp(() {
    signer = EcdsaSigner();
    pair = signer.generateKeyPair();
    paymentSigner = PaymentSigner(signer: signer, codec: const PayloadCodec());
    storage = _MockSecureStorage();
    walletLocal = _MockWalletLocalService();
    pendingTx = _MockPendingTxLocalService();

    // Default stubs: private key present, balance cached at 100, no reservations.
    when(
      () => storage.read(any()),
    ).thenAnswer((_) async => pair.privateKeyBase64);
    when(() => walletLocal.loadCached(any())).thenAnswer(
      (_) async =>
          WalletModel(id: 'cache', publicKey: senderPub, balance: 100.0),
    );
    when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 0);
    when(() => pendingTx.insert(any())).thenAnswer((_) async {});

    repo = SendRepository(
      paymentSigner: paymentSigner,
      secureStorage: storage,
      uuid: const Uuid(),
      errors: const ErrorHandler(),
      walletLocal: walletLocal,
      pendingTx: pendingTx,
    );
  });

  test('produces a verifiable signed envelope', () async {
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'receiver-pub',
      amount: 12.5,
    );
    expect(result, isA<Success<_QrResult>>());
    final qr = (result as Success<_QrResult>).data.qrData;
    final envelope = SignedEnvelope.fromJson(
      (jsonDecode(utf8.decode(base64Decode(qr))) as Map)
          .cast<String, dynamic>(),
    );
    expect(envelope.payload.amount, 12.5);
    expect(paymentSigner.verify(envelope.payload, envelope.signature), isTrue);
  });

  test('returns the transaction id alongside the QR data', () async {
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'receiver-pub',
      amount: 5,
    );
    final data = (result as Success<_QrResult>).data;
    expect(data.transactionId, isNotEmpty);
    // The id should match what is embedded in the QR payload.
    final envelope = SignedEnvelope.fromJson(
      (jsonDecode(utf8.decode(base64Decode(data.qrData))) as Map)
          .cast<String, dynamic>(),
    );
    expect(data.transactionId, envelope.payload.id);
  });

  test('inserts an optimistic pending row on success', () async {
    await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'receiver-pub',
      amount: 10,
    );
    verify(() => pendingTx.insert(any())).called(1);
  });

  test('rejects non-positive amount', () async {
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 0,
    );
    expect(result, isA<Failure<_QrResult>>());
    verifyNever(() => pendingTx.insert(any()));
  });

  test('rejects when no cached balance exists', () async {
    when(() => walletLocal.loadCached(any())).thenAnswer((_) async => null);
    final result = await repo.buildSignedQr(
      senderPublicKey: senderPub,
      receiverPublicKey: 'r',
      amount: 10,
    );
    final failure = result as Failure<_QrResult>;
    expect(failure.error.code, 'NO_CACHE');
    verifyNever(() => pendingTx.insert(any()));
  });

  test('rejects overdraft — amount exceeds available balance', () async {
    // balance=100, reserved=60 → available=40; sending 50 is an overdraft.
    when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 60);
    final result = await repo.buildSignedQr(
      senderPublicKey: senderPub,
      receiverPublicKey: 'r',
      amount: 50,
    );
    final failure = result as Failure<_QrResult>;
    expect(failure.error.code, 'INSUFFICIENT_FUNDS');
    verifyNever(() => pendingTx.insert(any()));
  });

  test('allows amount exactly equal to available balance', () async {
    // balance=100, reserved=40 → available=60; sending exactly 60 is ok.
    when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 40);
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 60,
    );
    expect(result, isA<Success<_QrResult>>());
    verify(() => pendingTx.insert(any())).called(1);
  });

  test('fails when private key is missing', () async {
    when(() => storage.read(any())).thenAnswer((_) async => null);
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 1,
    );
    expect(result, isA<Failure<_QrResult>>());
    verifyNever(() => pendingTx.insert(any()));
  });

  group('cancelPendingTransaction', () {
    test('returns Success when markCancelled affects 1 row', () async {
      when(() => pendingTx.markCancelled(any())).thenAnswer((_) async => 1);

      final result = await repo.cancelPendingTransaction('tx-id', 10.0);

      expect(result, isA<Success<int>>());
      expect((result as Success<int>).data, 1);
      verify(() => pendingTx.markCancelled('tx-id')).called(1);
    });

    test(
      'returns Failure(ALREADY_SYNCED) when markCancelled affects 0 rows',
      () async {
        when(() => pendingTx.markCancelled(any())).thenAnswer((_) async => 0);

        final result = await repo.cancelPendingTransaction('tx-id', 10.0);

        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).error.code, 'ALREADY_SYNCED');
      },
    );

    test('returns Failure when service throws', () async {
      when(
        () => pendingTx.markCancelled(any()),
      ).thenThrow(Exception('db error'));

      final result = await repo.cancelPendingTransaction('tx-id', 10.0);

      expect(result, isA<Failure<int>>());
    });
  });
}
