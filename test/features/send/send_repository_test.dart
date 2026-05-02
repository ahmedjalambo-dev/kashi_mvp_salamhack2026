import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/crypto/ecdsa_signer.dart';
import 'package:kashi_mvp_salamhack2026/core/crypto/payload_codec.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_handler.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/core/services/secure_storage.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/data/services/pending_tx_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/models/payment_payload.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/repositories/send_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/services/payment_signer.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/models/wallet_model.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/models/wallet_profile.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/services/wallet_local_service.dart';
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
    registerFallbackValue(const WalletProfile(
      displayName: '',
      phone: '',
      iban: '',
    ));
  });
  late EcdsaSigner signer;
  late EcdsaKeyPair pair;
  late PaymentSigner paymentSigner;
  late _MockSecureStorage storage;
  late _MockWalletLocalService walletLocal;
  late _MockPendingTxLocalService pendingTx;
  late SendRepository repo;

  const senderPub = 'sender-pub';

  const senderProfile = WalletProfile(
    displayName: 'Ahmad Khalil',
    phone: '+970 59 000 0001',
    iban: 'PS92APAB000000000000000000001',
  );
  const receiverProfile = WalletProfile(
    displayName: 'Yousef Barakat',
    phone: '+970 59 000 0002',
    iban: 'PS92APAB000000000000000000002',
  );

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
    when(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    ).thenAnswer((_) async {});

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
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
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
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
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
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
    verify(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    ).called(1);
  });

  test('rejects non-positive amount', () async {
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 0,
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
    expect(result, isA<Failure<_QrResult>>());
    verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
  });

  test('rejects when no cached balance exists', () async {
    when(() => walletLocal.loadCached(any())).thenAnswer((_) async => null);
    final result = await repo.buildSignedQr(
      senderPublicKey: senderPub,
      receiverPublicKey: 'r',
      amount: 10,
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
    final failure = result as Failure<_QrResult>;
    expect(failure.error.code, 'NO_CACHE');
    verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
  });

  test('rejects overdraft — amount exceeds available balance', () async {
    // balance=100, reserved=60 → available=40; sending 50 is an overdraft.
    when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 60);
    final result = await repo.buildSignedQr(
      senderPublicKey: senderPub,
      receiverPublicKey: 'r',
      amount: 50,
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
    final failure = result as Failure<_QrResult>;
    expect(failure.error.code, 'INSUFFICIENT_FUNDS');
    verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
  });

  test('allows amount exactly equal to available balance', () async {
    // balance=100, reserved=40 → available=60; sending exactly 60 is ok.
    when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 40);
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 60,
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
    expect(result, isA<Success<_QrResult>>());
    verify(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    ).called(1);
  });

  test('fails when private key is missing', () async {
    when(() => storage.read(any())).thenAnswer((_) async => null);
    final result = await repo.buildSignedQr(
      senderPublicKey: pair.publicKeyBase64,
      receiverPublicKey: 'r',
      amount: 1,
      senderProfile: senderProfile,
      receiverProfile: receiverProfile,
    );
    expect(result, isA<Failure<_QrResult>>());
    verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
  });

  group('validateAmount', () {
    test('returns Success(null) for amount within available balance', () async {
      final result = await repo.validateAmount(
        senderPublicKey: senderPub,
        amount: 50,
      );
      expect(result, isA<Success<void>>());
      verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
    });

    test('returns Failure(AMOUNT) for amount <= 0', () async {
      final result = await repo.validateAmount(
        senderPublicKey: senderPub,
        amount: 0,
      );
      expect((result as Failure).error.code, 'AMOUNT');
      verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
    });

    test('returns Failure(NO_CACHE) when loadCached returns null', () async {
      when(() => walletLocal.loadCached(any())).thenAnswer((_) async => null);
      final result = await repo.validateAmount(
        senderPublicKey: senderPub,
        amount: 10,
      );
      expect((result as Failure).error.code, 'NO_CACHE');
      verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
    });

    test('returns Failure(INSUFFICIENT_FUNDS) when amount > balance − reserved',
        () async {
      when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 60);
      final result = await repo.validateAmount(
        senderPublicKey: senderPub,
        amount: 50, // balance=100, reserved=60 → available=40
      );
      expect((result as Failure).error.code, 'INSUFFICIENT_FUNDS');
      verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
    });

    test('does not call pendingTx.insert under any path', () async {
      await repo.validateAmount(senderPublicKey: senderPub, amount: 10);
      verifyNever(
      () => pendingTx.insert(
        any(),
        counterpartyName: any(named: 'counterpartyName'),
        counterpartyPhone: any(named: 'counterpartyPhone'),
        counterpartyIban: any(named: 'counterpartyIban'),
      ),
    );
    });
  });

  group('cancelPendingTransaction', () {
    test('returns Success when markVoidedLocally affects 1 row', () async {
      when(() => pendingTx.markVoidedLocally(any())).thenAnswer((_) async => 1);

      final result = await repo.cancelPendingTransaction('tx-id', 10.0);

      expect(result, isA<Success<int>>());
      expect((result as Success<int>).data, 1);
      verify(() => pendingTx.markVoidedLocally('tx-id')).called(1);
    });

    test(
      'returns Failure(ALREADY_SYNCED) when markVoidedLocally affects 0 rows',
      () async {
        when(() => pendingTx.markVoidedLocally(any())).thenAnswer((_) async => 0);

        final result = await repo.cancelPendingTransaction('tx-id', 10.0);

        expect(result, isA<Failure<int>>());
        expect((result as Failure<int>).error.code, 'ALREADY_SYNCED');
      },
    );

    test('returns Failure when service throws', () async {
      when(
        () => pendingTx.markVoidedLocally(any()),
      ).thenThrow(Exception('db error'));

      final result = await repo.cancelPendingTransaction('tx-id', 10.0);

      expect(result, isA<Failure<int>>());
    });
  });
}
