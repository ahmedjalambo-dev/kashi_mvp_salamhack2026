import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_model.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/data/repositories/receive_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/state/receive_cubit.dart';
import 'package:kashi_mvp_salamhack2026/features/receive/state/receive_state.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/models/payment_payload.dart';
import 'package:mocktail/mocktail.dart';

class _MockReceiveRepository extends Mock implements ReceiveRepository {}

class _FakeSignedEnvelope extends Fake implements SignedEnvelope {}

void main() {
  setUpAll(() {
    registerFallbackValue(_FakeSignedEnvelope());
  });
  const myPublicKey = 'my-pub-key';
  const raw = 'some-raw-qr';

  final now = DateTime.now().toUtc();
  final payload = PaymentPayload(
    id: 'test-id',
    senderPublicKey: 'sender-pub',
    receiverPublicKey: myPublicKey,
    amount: 25.0,
    nonce: 'nonce',
    clientCreatedAt: now,
    expiresAt: now.add(const Duration(hours: 1)),
  );
  final envelope = SignedEnvelope(payload: payload, signature: 'sig');

  late _MockReceiveRepository repository;

  setUp(() {
    repository = _MockReceiveRepository();
  });

  ReceiveCubit buildCubit() => ReceiveCubit(
        repository: repository,
        myPublicKey: myPublicKey,
      );

  group('onScan', () {
    blocTest<ReceiveCubit, ReceiveState>(
      'valid QR emits [ReceiveVerifying, ReceiveConfirming] and does not call acceptValidated',
      build: buildCubit,
      setUp: () {
        when(() => repository.validateScan(raw, myPublicKey))
            .thenAnswer((_) async => Success(envelope));
      },
      act: (c) => c.onScan(raw),
      expect: () => [
        const ReceiveVerifying(),
        ReceiveConfirming(envelope),
      ],
      verify: (_) => verifyNever(() => repository.acceptValidated(any())),
    );

    blocTest<ReceiveCubit, ReceiveState>(
      'invalid QR emits [ReceiveVerifying, ReceiveFailure]',
      build: buildCubit,
      setUp: () {
        when(() => repository.validateScan(raw, myPublicKey)).thenAnswer(
          (_) async =>
              const Failure(ErrorModel(message: 'Bad sig', code: 'BAD_SIG')),
        );
      },
      act: (c) => c.onScan(raw),
      expect: () => [
        const ReceiveVerifying(),
        const ReceiveFailure('Bad sig'),
      ],
    );

    blocTest<ReceiveCubit, ReceiveState>(
      'late detections are dropped when state is ReceiveConfirming',
      build: buildCubit,
      seed: () => ReceiveConfirming(envelope),
      act: (c) => c.onScan(raw),
      expect: () => [],
      verify: (_) => verifyNever(() => repository.validateScan(any(), any())),
    );
  });

  group('confirmTransaction', () {
    blocTest<ReceiveCubit, ReceiveState>(
      'success emits [ReceiveVerifying, ReceiveSuccess]',
      build: buildCubit,
      seed: () => ReceiveConfirming(envelope),
      setUp: () {
        when(() => repository.acceptValidated(envelope))
            .thenAnswer((_) async => Success(envelope));
      },
      act: (c) => c.confirmTransaction(payload),
      expect: () => [
        const ReceiveVerifying(),
        ReceiveSuccess(payload),
      ],
      verify: (_) => verify(() => repository.acceptValidated(envelope)).called(1),
    );

    blocTest<ReceiveCubit, ReceiveState>(
      'acceptValidated failure emits [ReceiveVerifying, ReceiveFailure]',
      build: buildCubit,
      seed: () => ReceiveConfirming(envelope),
      setUp: () {
        when(() => repository.acceptValidated(envelope)).thenAnswer(
          (_) async => const Failure(
            ErrorModel(message: 'Already received', code: 'ALREADY_RECEIVED'),
          ),
        );
      },
      act: (c) => c.confirmTransaction(payload),
      expect: () => [
        const ReceiveVerifying(),
        const ReceiveFailure('Already received'),
      ],
    );

    blocTest<ReceiveCubit, ReceiveState>(
      'is a no-op when state is not ReceiveConfirming',
      build: buildCubit,
      act: (c) => c.confirmTransaction(payload),
      expect: () => [],
      verify: (_) => verifyNever(() => repository.acceptValidated(any())),
    );
  });

  group('cancelTransaction', () {
    blocTest<ReceiveCubit, ReceiveState>(
      'from ReceiveConfirming emits [ReceiveScanning] and does not call acceptValidated',
      build: buildCubit,
      seed: () => ReceiveConfirming(envelope),
      act: (c) => c.cancelTransaction(),
      expect: () => [const ReceiveScanning()],
      verify: (_) => verifyNever(() => repository.acceptValidated(any())),
    );
  });
}
