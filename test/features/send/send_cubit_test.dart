import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_model.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/models/payment_payload.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/repositories/send_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/send/state/send_cubit.dart';
import 'package:kashi_mvp_salamhack2026/features/send/state/send_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSendRepository extends Mock implements SendRepository {}

class _FakePaymentRequest extends Fake implements PaymentRequest {}

final _now = DateTime.now().toUtc();
final _request = PaymentRequest(
  id: 'tx-uuid-1',
  receiverPublicKey: 'recv-pub',
  amount: 25.0,
  nonce: 'nonce',
  clientCreatedAt: _now,
  expiresAt: _now.add(const Duration(hours: 1)),
);

final _confirmingState = SendConfirming(
  amount: 25.0,
  receiverPublicKey: 'recv-pub',
  request: _request,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _MockSendRepository repository;

  setUpAll(() => registerFallbackValue(_FakePaymentRequest()));

  setUp(() {
    repository = _MockSendRepository();
  });

  SendCubit buildCubit() => SendCubit(
    repository: repository,
    senderPublicKey: 'sender-pub',
  );

  group('onScan', () {
    blocTest<SendCubit, SendState>(
      'valid request emits [SendVerifying, SendConfirming]',
      build: () {
        when(
          () => repository.validateScannedRequest(any(), any()),
        ).thenAnswer((_) async => Success(_request));
        return buildCubit();
      },
      act: (c) => c.onScan('raw-qr'),
      expect: () => [
        const SendVerifying(),
        SendConfirming(
          amount: 25.0,
          receiverPublicKey: 'recv-pub',
          request: _request,
        ),
      ],
      verify: (_) => verify(
        () => repository.validateScannedRequest('raw-qr', 'sender-pub'),
      ).called(1),
    );

    blocTest<SendCubit, SendState>(
      'invalid request emits [SendVerifying, SendFailure]',
      build: () {
        when(
          () => repository.validateScannedRequest(any(), any()),
        ).thenAnswer(
          (_) async => const Failure(
            ErrorModel(message: 'Not a Kashi payment request', code: 'MALFORMED'),
          ),
        );
        return buildCubit();
      },
      act: (c) => c.onScan('bad-qr'),
      expect: () => [
        const SendVerifying(),
        const SendFailure('Not a Kashi payment request'),
      ],
    );

    blocTest<SendCubit, SendState>(
      'is a no-op when not in SendScanning',
      build: buildCubit,
      seed: () => _confirmingState,
      act: (c) => c.onScan('raw-qr'),
      expect: () => [],
      verify: (_) =>
          verifyNever(() => repository.validateScannedRequest(any(), any())),
    );
  });

  group('confirmAndSign', () {
    blocTest<SendCubit, SendState>(
      'emits [SendVerifying, SendSuccess] from SendConfirming on success',
      build: () {
        when(
          () => repository.signAndStore(any(), any()),
        ).thenAnswer(
          (_) async => const Success((transactionId: 'tx-uuid-1')),
        );
        return buildCubit();
      },
      seed: () => _confirmingState,
      act: (c) => c.confirmAndSign(),
      expect: () => [
        const SendVerifying(),
        const SendSuccess(
          amount: 25.0,
          receiverPublicKey: 'recv-pub',
          transactionId: 'tx-uuid-1',
        ),
      ],
      verify: (_) => verify(
        () => repository.signAndStore(_request, 'sender-pub'),
      ).called(1),
    );

    blocTest<SendCubit, SendState>(
      'emits [SendVerifying, SendFailure] when signAndStore returns Failure',
      build: () {
        when(
          () => repository.signAndStore(any(), any()),
        ).thenAnswer(
          (_) async => const Failure(
            ErrorModel(message: 'Private key missing', code: 'NO_KEY'),
          ),
        );
        return buildCubit();
      },
      seed: () => _confirmingState,
      act: (c) => c.confirmAndSign(),
      expect: () => [
        const SendVerifying(),
        const SendFailure('Private key missing'),
      ],
    );

    blocTest<SendCubit, SendState>(
      'is a no-op when state is not SendConfirming',
      build: buildCubit,
      seed: () => const SendScanning(),
      act: (c) => c.confirmAndSign(),
      expect: () => [],
      verify: (_) =>
          verifyNever(() => repository.signAndStore(any(), any())),
    );
  });

  group('cancelReview', () {
    blocTest<SendCubit, SendState>(
      'emits [SendScanning] from SendConfirming',
      build: buildCubit,
      seed: () => _confirmingState,
      act: (c) => c.cancelReview(),
      expect: () => [const SendScanning()],
    );

    blocTest<SendCubit, SendState>(
      'is a no-op outside SendConfirming',
      build: buildCubit,
      seed: () => const SendScanning(),
      act: (c) => c.cancelReview(),
      expect: () => [],
    );
  });

  group('rescan', () {
    blocTest<SendCubit, SendState>(
      'emits [SendScanning] from any state',
      build: buildCubit,
      seed: () => const SendFailure('some error'),
      act: (c) => c.rescan(),
      expect: () => [const SendScanning()],
    );
  });
}
