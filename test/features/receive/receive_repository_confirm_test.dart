import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/core/services/qr_codec.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/data/repositories/receive_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/data/services/incoming_pending_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/data/services/pending_request_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/models/payment_payload.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/services/payment_signer.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_handler.dart';
import 'package:mocktail/mocktail.dart';
import 'package:uuid/uuid.dart';

class _MockPendingRequests extends Mock implements PendingRequestLocalService {}

class _MockIncomingPending extends Mock implements IncomingPendingLocalService {}

class _MockPaymentSigner extends Mock implements PaymentSigner {}

class _FakeSignedEnvelope extends Fake implements SignedEnvelope {}

class _FakePaymentPayload extends Fake implements PaymentPayload {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeSignedEnvelope());
    registerFallbackValue(_FakePaymentPayload());
  });
  late _MockPendingRequests pendingRequests;
  late _MockIncomingPending incomingPending;
  late _MockPaymentSigner signer;
  late QrCodec codec;
  late ReceiveRepository repo;

  final testNow = DateTime.now().toUtc();
  final testRequest = PaymentRequest(
    id: 'tx-uuid-confirm',
    receiverPublicKey: 'receiver-key',
    amount: 25.0,
    nonce: 'nonce-abc',
    clientCreatedAt: testNow,
    expiresAt: testNow.add(const Duration(hours: 1)),
  );
  final testPayload = PaymentPayload(
    id: 'tx-uuid-confirm',
    senderPublicKey: 'sender-key',
    receiverPublicKey: 'receiver-key',
    amount: 25.0,
    nonce: 'nonce-abc',
    clientCreatedAt: testNow,
    expiresAt: testNow.add(const Duration(hours: 1)),
  );
  final testEnvelope = SignedEnvelope(payload: testPayload, signature: 'valid-sig');

  setUp(() {
    pendingRequests = _MockPendingRequests();
    incomingPending = _MockIncomingPending();
    signer = _MockPaymentSigner();
    codec = const QrCodec();

    repo = ReceiveRepository(
      qrCodec: codec,
      uuid: const Uuid(),
      errors: const ErrorHandler(),
      pendingRequests: pendingRequests,
      incomingPending: incomingPending,
      paymentSigner: signer,
    );

    when(() => incomingPending.insert(any())).thenAnswer((_) async {});
    when(() => pendingRequests.delete(any())).thenAnswer((_) async {});
    when(() => signer.verify(any(), any())).thenReturn(true);
  });

  String encodeEnvelope(SignedEnvelope e) => codec.encodeEnvelope(e);

  test('happy path: decodes, verifies, and persists envelope', () async {
    final qr = encodeEnvelope(testEnvelope);
    final result = await repo.confirmEnvelope(qr, testRequest);

    expect(result, isA<Success<SignedEnvelope>>());
    verify(() => incomingPending.insert(any())).called(1);
    verify(() => pendingRequests.delete('tx-uuid-confirm')).called(1);
  });

  test('malformed QR returns Failure with MALFORMED_QR code', () async {
    final result = await repo.confirmEnvelope('not-valid-base64!!!', testRequest);
    expect(result, isA<Failure<SignedEnvelope>>());
    final err = (result as Failure<SignedEnvelope>).error;
    expect(err.code, 'MALFORMED_QR');
    verifyNever(() => incomingPending.insert(any()));
  });

  test('wrong-type QR (request QR) returns Failure', () async {
    // encodeRequest produces type='request', not 'envelope'
    final qr = codec.encodeRequest(testRequest);
    final result = await repo.confirmEnvelope(qr, testRequest);
    expect(result, isA<Failure<SignedEnvelope>>());
    verifyNever(() => incomingPending.insert(any()));
  });

  test('id mismatch returns ID_MISMATCH Failure', () async {
    final wrongRequest = PaymentRequest(
      id: 'different-id',
      receiverPublicKey: 'receiver-key',
      amount: 25.0,
      nonce: 'nonce-abc',
      clientCreatedAt: testNow,
      expiresAt: testNow.add(const Duration(hours: 1)),
    );
    final qr = encodeEnvelope(testEnvelope);
    final result = await repo.confirmEnvelope(qr, wrongRequest);
    expect(result, isA<Failure<SignedEnvelope>>());
    final err = (result as Failure<SignedEnvelope>).error;
    expect(err.code, 'ID_MISMATCH');
    verifyNever(() => incomingPending.insert(any()));
  });

  test('amount mismatch returns AMOUNT_MISMATCH Failure', () async {
    final wrongRequest = PaymentRequest(
      id: 'tx-uuid-confirm',
      receiverPublicKey: 'receiver-key',
      amount: 99.0, // wrong
      nonce: 'nonce-abc',
      clientCreatedAt: testNow,
      expiresAt: testNow.add(const Duration(hours: 1)),
    );
    final qr = encodeEnvelope(testEnvelope);
    final result = await repo.confirmEnvelope(qr, wrongRequest);
    expect(result, isA<Failure<SignedEnvelope>>());
    expect((result as Failure<SignedEnvelope>).error.code, 'AMOUNT_MISMATCH');
    verifyNever(() => incomingPending.insert(any()));
  });

  test('invalid signature returns SIGNATURE_INVALID Failure', () async {
    when(() => signer.verify(any(), any())).thenReturn(false);
    final qr = encodeEnvelope(testEnvelope);
    final result = await repo.confirmEnvelope(qr, testRequest);
    expect(result, isA<Failure<SignedEnvelope>>());
    expect(
      (result as Failure<SignedEnvelope>).error.code,
      'SIGNATURE_INVALID',
    );
    verifyNever(() => incomingPending.insert(any()));
  });
}
