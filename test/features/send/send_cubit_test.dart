import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_model.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/features/send/data/repositories/send_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/send/state/send_cubit.dart';
import 'package:kashi_mvp_salamhack2026/features/send/state/send_state.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/models/wallet_profile.dart';
import 'package:mocktail/mocktail.dart';

class _MockSendRepository extends Mock implements SendRepository {}

const _senderProfile = WalletProfile(
  displayName: 'Ahmad Khalil',
  phone: '+970 59 000 0001',
  iban: 'PS92APAB000000000000000000001',
);

const _receiverProfile = WalletProfile(
  displayName: 'Yousef Barakat',
  phone: '+970 59 000 0002',
  iban: 'PS92APAB000000000000000000002',
);

const _readyState = SendReady(
  qrData: 'qr',
  transactionId: 'tx-uuid-1',
  amount: 42.0,
  receiverPublicKey: 'recv-pub',
  receiverProfile: _receiverProfile,
);

const _confirmingState = SendConfirming(
  amount: 25.0,
  receiverPublicKey: 'recv-pub',
  receiverProfile: _receiverProfile,
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(const WalletProfile(
      displayName: '',
      phone: '',
      iban: '',
    ));
  });

  late _MockSendRepository repository;

  setUp(() {
    repository = _MockSendRepository();
  });

  SendCubit buildCubit() => SendCubit(
        repository: repository,
        senderPublicKey: 'sender-pub',
        receiverPublicKey: 'recv-pub',
        senderProfile: _senderProfile,
        receiverProfile: _receiverProfile,
      );

  group('cancelTransfer', () {
    blocTest<SendCubit, SendState>(
      'emits [SendLoading, SendInitial] and clears controllers on success',
      build: () {
        when(() => repository.cancelPendingTransaction(any(), any()))
            .thenAnswer((_) async => const Success(1));
        when(
          () => repository.buildSignedQr(
            senderPublicKey: any(named: 'senderPublicKey'),
            receiverPublicKey: any(named: 'receiverPublicKey'),
            amount: any(named: 'amount'),
            senderProfile: any(named: 'senderProfile'),
            receiverProfile: any(named: 'receiverProfile'),
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

  group('reviewTransfer', () {
    blocTest<SendCubit, SendState>(
      'emits [SendLoading, SendConfirming] on valid amount; buildSignedQr not called',
      build: () {
        when(
          () => repository.validateAmount(
            senderPublicKey: any(named: 'senderPublicKey'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer((_) async => const Success(null));
        return buildCubit();
      },
      act: (c) => c.reviewTransfer(25.0),
      expect: () => [],
      verify: (_) => verifyNever(
        () => repository.validateAmount(
          senderPublicKey: any(named: 'senderPublicKey'),
          amount: any(named: 'amount'),
        ),
      ),
    );

    blocTest<SendCubit, SendState>(
      'emits [SendLoading, SendFailure] when validateAmount returns INSUFFICIENT_FUNDS',
      build: () {
        when(
          () => repository.validateAmount(
            senderPublicKey: any(named: 'senderPublicKey'),
            amount: any(named: 'amount'),
          ),
        ).thenAnswer(
          (_) async => const Failure(
            ErrorModel(
              message: 'Insufficient funds. Available: 10.00',
              code: 'INSUFFICIENT_FUNDS',
            ),
          ),
        );
        return buildCubit();
      },
      seed: () => const SendInitial(),
      act: (c) => c.reviewTransfer(50.0),
      expect: () => [],
      verify: (_) => verifyNever(
        () => repository.buildSignedQr(
          senderPublicKey: any(named: 'senderPublicKey'),
          receiverPublicKey: any(named: 'receiverPublicKey'),
          amount: any(named: 'amount'),
          senderProfile: any(named: 'senderProfile'),
          receiverProfile: any(named: 'receiverProfile'),
        ),
      ),
    );
  });

  group('confirmAndGenerateQR', () {
    blocTest<SendCubit, SendState>(
      'emits [SendLoading, SendReady] from SendConfirming on success',
      build: () {
        when(
          () => repository.buildSignedQr(
            senderPublicKey: any(named: 'senderPublicKey'),
            receiverPublicKey: any(named: 'receiverPublicKey'),
            amount: any(named: 'amount'),
            senderProfile: any(named: 'senderProfile'),
            receiverProfile: any(named: 'receiverProfile'),
          ),
        ).thenAnswer(
          (_) async => const Success(
            (qrData: 'qr-data', transactionId: 'tx-uuid-1'),
          ),
        );
        return buildCubit();
      },
      seed: () => _confirmingState,
      act: (c) => c.confirmAndGenerateQR(),
      expect: () => [
        const SendLoading(),
        const SendReady(
          qrData: 'qr-data',
          transactionId: 'tx-uuid-1',
          amount: 25.0,
          receiverPublicKey: 'recv-pub',
          receiverProfile: _receiverProfile,
        ),
      ],
      verify: (_) => verify(
        () => repository.buildSignedQr(
          senderPublicKey: 'sender-pub',
          receiverPublicKey: 'recv-pub',
          amount: 25.0,
          senderProfile: _senderProfile,
          receiverProfile: _receiverProfile,
        ),
      ).called(1),
    );

    blocTest<SendCubit, SendState>(
      'emits [SendLoading, SendFailure] when buildSignedQr returns Failure',
      build: () {
        when(
          () => repository.buildSignedQr(
            senderPublicKey: any(named: 'senderPublicKey'),
            receiverPublicKey: any(named: 'receiverPublicKey'),
            amount: any(named: 'amount'),
            senderProfile: any(named: 'senderProfile'),
            receiverProfile: any(named: 'receiverProfile'),
          ),
        ).thenAnswer(
          (_) async => const Failure(
            ErrorModel(message: 'Private key missing', code: 'NO_KEY'),
          ),
        );
        return buildCubit();
      },
      seed: () => _confirmingState,
      act: (c) => c.confirmAndGenerateQR(),
      expect: () => [
        const SendLoading(),
        const SendFailure('Private key missing'),
      ],
    );

    blocTest<SendCubit, SendState>(
      'is a no-op when state is not SendConfirming',
      build: buildCubit,
      seed: () => const SendInitial(),
      act: (c) => c.confirmAndGenerateQR(),
      expect: () => [],
      verify: (_) => verifyNever(
        () => repository.buildSignedQr(
          senderPublicKey: any(named: 'senderPublicKey'),
          receiverPublicKey: any(named: 'receiverPublicKey'),
          amount: any(named: 'amount'),
          senderProfile: any(named: 'senderProfile'),
          receiverProfile: any(named: 'receiverProfile'),
        ),
      ),
    );
  });

  group('cancelReview', () {
    blocTest<SendCubit, SendState>(
      'emits [SendInitial] from SendConfirming; amount controller retains text',
      build: buildCubit,
      seed: () => _confirmingState,
      act: (c) {
        c.amountController.text = '25.00';
        c.cancelReview();
      },
      expect: () => [const SendInitial()],
      verify: (c) {
        expect(c.amountController.text, '25.00');
        verifyNever(
          () => repository.buildSignedQr(
            senderPublicKey: any(named: 'senderPublicKey'),
            receiverPublicKey: any(named: 'receiverPublicKey'),
            amount: any(named: 'amount'),
            senderProfile: any(named: 'senderProfile'),
            receiverProfile: any(named: 'receiverProfile'),
          ),
        );
      },
    );

    blocTest<SendCubit, SendState>(
      'is a no-op outside SendConfirming',
      build: buildCubit,
      seed: () => const SendInitial(),
      act: (c) => c.cancelReview(),
      expect: () => [],
    );
  });
}
