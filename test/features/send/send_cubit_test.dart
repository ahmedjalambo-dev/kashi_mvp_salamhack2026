import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/error_model.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/data/repositories/send_repository.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/state/send_cubit.dart';
import 'package:kashi_mvp_salamhack2026/src/features/send/state/send_state.dart';
import 'package:mocktail/mocktail.dart';

class _MockSendRepository extends Mock implements SendRepository {}

const _readyState = SendReady(
  qrData: 'qr',
  transactionId: 'tx-uuid-1',
  amount: 42.0,
  receiverPublicKey: 'recv-pub',
);

void main() {
  late _MockSendRepository repository;

  setUp(() {
    repository = _MockSendRepository();
  });

  SendCubit buildCubit({SendState seed = const SendInitial()}) {
    final c = SendCubit(
      repository: repository,
      senderPublicKey: 'sender-pub',
    );
    // Force the cubit into the desired starting state via reset or by
    // seeding — we use emit via a subclass-friendly approach: just call
    // cancelTransfer/createPayment stubs; for the ready state we rely on
    // repository stubs.
    return c;
  }

  group('cancelTransfer', () {
    blocTest<SendCubit, SendState>(
      'emits [SendLoading, SendInitial] and clears controllers on success',
      build: () {
        when(() => repository.cancelPendingTransaction(any(), any()))
            .thenAnswer((_) async => const Success(1));
        // Seed the cubit into SendReady by stubbing buildSignedQr.
        when(
          () => repository.buildSignedQr(
            senderPublicKey: any(named: 'senderPublicKey'),
            receiverPublicKey: any(named: 'receiverPublicKey'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer(
          (_) async => const Success(
            (qrData: 'qr-data', transactionId: 'tx-uuid-1'),
          ),
        );
        return buildCubit();
      },
      seed: () => _readyState,
      act: (c) => c.cancelTransfer(),
      expect: () => [const SendLoading(), const SendInitial()],
      verify: (c) {
        verify(
          () => repository.cancelPendingTransaction('tx-uuid-1', 42.0),
        ).called(1);
        expect(c.amountController.text, isEmpty);
        expect(c.recipientController.text, isEmpty);
      },
    );

    blocTest<SendCubit, SendState>(
      'emits [SendLoading, SendFailure] when repository returns Failure',
      build: () {
        when(() => repository.cancelPendingTransaction(any(), any()))
            .thenAnswer(
              (_) async => const Failure(
                ErrorModel(
                  message: 'This transfer was already synced — too late to cancel.',
                  code: 'ALREADY_SYNCED',
                ),
              ),
            );
        return buildCubit();
      },
      seed: () => _readyState,
      act: (c) => c.cancelTransfer(),
      expect: () => [
        const SendLoading(),
        const SendFailure(
          'This transfer was already synced — too late to cancel.',
        ),
      ],
    );

    blocTest<SendCubit, SendState>(
      'is a no-op when state is not SendReady',
      build: buildCubit,
      seed: () => const SendInitial(),
      act: (c) => c.cancelTransfer(),
      expect: () => [],
      verify: (_) => verifyNever(
        () => repository.cancelPendingTransaction(any(), any()),
      ),
    );
  });
}
