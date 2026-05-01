import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/crypto/ecdsa_signer.dart';
import 'package:kashi_mvp_salamhack2026/core/crypto/payload_codec.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_handler.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/core/services/qr_codec.dart';
import 'package:kashi_mvp_salamhack2026/core/services/secure_storage.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/data/services/pending_tx_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/models/payment_payload.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/repositories/send_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/services/payment_signer.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/models/wallet_model.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/services/wallet_local_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockSecureStorage extends Mock implements SecureStorage {}

class _MockWalletLocalService extends Mock implements WalletLocalService {}

class _MockPendingTxLocalService extends Mock
    implements PendingTxLocalService {}

class _FakeSignedEnvelope extends Fake implements SignedEnvelope {}

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

  // A valid request QR produced by QrCodec.encodeRequest.
  String makeValidQr({
    String? receiverPublicKey,
    double amount = 12.5,
    Duration offset = Duration.zero,
  }) {
    final now = DateTime.now().toUtc().add(offset);
    final request = PaymentRequest(
      id: 'test-id',
      receiverPublicKey: receiverPublicKey ?? 'receiver-pub',
      amount: amount,
      nonce: 'nonce',
      clientCreatedAt: now,
      expiresAt: now.add(const Duration(hours: 1)),
    );
    return const QrCodec().encodeRequest(request);
  }

  setUp(() {
    signer = EcdsaSigner();
    pair = signer.generateKeyPair();
    paymentSigner = PaymentSigner(signer: signer, codec: const PayloadCodec());
    storage = _MockSecureStorage();
    walletLocal = _MockWalletLocalService();
    pendingTx = _MockPendingTxLocalService();

    when(() => storage.read(any())).thenAnswer((_) async => pair.privateKeyBase64);
    when(() => walletLocal.loadCached(any())).thenAnswer(
      (_) async => WalletModel(id: 'cache', publicKey: senderPub, balance: 100.0),
    );
    when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 0);
    when(() => pendingTx.insert(any())).thenAnswer((_) async {});

    repo = SendRepository(
      paymentSigner: paymentSigner,
      secureStorage: storage,
      qrCodec: const QrCodec(),
      errors: const ErrorHandler(),
      walletLocal: walletLocal,
      pendingTx: pendingTx,
    );
  });

  group('validateScannedRequest', () {
    test('returns Success(request) for a valid QR', () async {
      final qr = makeValidQr();
      final result = await repo.validateScannedRequest(qr, senderPub);
      expect(result, isA<Success<PaymentRequest>>());
      final req = (result as Success<PaymentRequest>).data;
      expect(req.amount, 12.5);
      expect(req.receiverPublicKey, 'receiver-pub');
    });

    test('returns Failure(MALFORMED) for garbage input', () async {
      final result = await repo.validateScannedRequest('not-valid-base64!!!', senderPub);
      expect((result as Failure).error.code, 'MALFORMED');
      verifyNever(() => pendingTx.insert(any()));
    });

    test('returns Failure(MALFORMED) for non-request type QR', () async {
      // Encode a raw JSON that has type != "request"
      final raw = base64Encode(utf8.encode('{"type":"signed","id":"x"}'));
      final result = await repo.validateScannedRequest(raw, senderPub);
      expect((result as Failure).error.code, 'MALFORMED');
    });

    test('returns Failure(SELF_PAY) when receiver == sender', () async {
      final qr = makeValidQr(receiverPublicKey: senderPub);
      final result = await repo.validateScannedRequest(qr, senderPub);
      expect((result as Failure).error.code, 'SELF_PAY');
    });

    test('returns Failure(EXPIRED) for an expired request', () async {
      final qr = makeValidQr(offset: const Duration(hours: -2));
      final result = await repo.validateScannedRequest(qr, senderPub);
      expect((result as Failure).error.code, 'EXPIRED');
    });

    test('returns Failure(NO_CACHE) when no cached balance', () async {
      when(() => walletLocal.loadCached(any())).thenAnswer((_) async => null);
      final qr = makeValidQr();
      final result = await repo.validateScannedRequest(qr, senderPub);
      expect((result as Failure).error.code, 'NO_CACHE');
    });

    test('returns Failure(INSUFFICIENT_FUNDS) when amount exceeds available', () async {
      when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 90);
      final qr = makeValidQr(amount: 20); // balance=100, reserved=90 → available=10
      final result = await repo.validateScannedRequest(qr, senderPub);
      expect((result as Failure).error.code, 'INSUFFICIENT_FUNDS');
    });

    test('allows amount exactly equal to available balance', () async {
      when(() => pendingTx.pendingOutgoingSum(any())).thenAnswer((_) async => 40);
      final qr = makeValidQr(amount: 60); // available=60
      final result = await repo.validateScannedRequest(qr, senderPub);
      expect(result, isA<Success<PaymentRequest>>());
    });
  });

  group('signAndStore', () {
    late PaymentRequest request;

    setUp(() {
      final now = DateTime.now().toUtc();
      request = PaymentRequest(
        id: 'test-id',
        receiverPublicKey: 'receiver-pub',
        amount: 12.5,
        nonce: 'nonce',
        clientCreatedAt: now,
        expiresAt: now.add(const Duration(hours: 1)),
      );
    });

    test('inserts a verifiable signed envelope and returns transactionId', () async {
      final result = await repo.signAndStore(request, pair.publicKeyBase64);
      expect(result, isA<Success<({String qrData, String transactionId})>>());
      expect(
        (result as Success<({String qrData, String transactionId})>).data.transactionId,
        'test-id',
      );
      verify(() => pendingTx.insert(any())).called(1);
    });

    test('returns Failure(NO_KEY) when private key is missing', () async {
      when(() => storage.read(any())).thenAnswer((_) async => null);
      final result = await repo.signAndStore(request, 'sender-pub');
      expect((result as Failure).error.code, 'NO_KEY');
      verifyNever(() => pendingTx.insert(any()));
    });

    test('signed payload is verifiable by PaymentSigner', () async {
      await repo.signAndStore(request, pair.publicKeyBase64);
      // Capture what was inserted
      final captured = verify(() => pendingTx.insert(captureAny())).captured;
      final envelope = captured.first as SignedEnvelope;
      expect(paymentSigner.verify(envelope.payload, envelope.signature), isTrue);
    });
  });
}
