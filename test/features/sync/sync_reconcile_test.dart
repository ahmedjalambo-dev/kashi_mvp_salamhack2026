import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_handler.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/features/history/data/models/transaction_model.dart';
import 'package:kashi_mvp_salamhack2026/features/history/data/services/history_remote_service.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/data/repositories/sync_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/data/services/sync_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/data/services/sync_remote_service.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/models/wallet_model.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/services/wallet_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/services/wallet_remote_service.dart';
import 'package:mocktail/mocktail.dart';

class _MockSyncRemoteService extends Mock implements SyncRemoteService {}

class _MockSyncLocalService extends Mock implements SyncLocalService {}

class _MockHistoryRemoteService extends Mock implements HistoryRemoteService {}

class _MockWalletRemoteService extends Mock implements WalletRemoteService {}

class _MockWalletLocalService extends Mock implements WalletLocalService {}

TransactionModel _tx(String id) => TransactionModel(
  id: id,
  senderPublicKey: 'sender',
  receiverPublicKey: 'receiver',
  amount: 25.0,
  status: TxStatus.confirmed,
  clientCreatedAt: DateTime.now(),
);

void main() {
  late _MockSyncRemoteService syncRemote;
  late _MockSyncLocalService syncLocal;
  late _MockHistoryRemoteService historyRemote;
  late _MockWalletRemoteService walletRemote;
  late _MockWalletLocalService walletLocal;
  late SyncRepository repo;

  const pubKey = 'my-pub-key';
  const serverBalance = 900.0;

  setUp(() {
    syncRemote = _MockSyncRemoteService();
    syncLocal = _MockSyncLocalService();
    historyRemote = _MockHistoryRemoteService();
    walletRemote = _MockWalletRemoteService();
    walletLocal = _MockWalletLocalService();

    when(() => walletRemote.fetchByPublicKey(pubKey)).thenAnswer(
      (_) async =>
          WalletModel(id: 'srv', publicKey: pubKey, balance: serverBalance),
    );
    when(() => walletLocal.cacheBalance(any(), any())).thenAnswer((_) async {});

    repo = SyncRepository(
      remote: syncRemote,
      local: syncLocal,
      errors: const ErrorHandler(),
      remoteHistory: historyRemote,
      walletRemote: walletRemote,
      walletLocal: walletLocal,
    );
  });

  group('pullAndReconcile', () {
    test(
      'flips voided_locally row to synced when server has the same id',
      () async {
        when(
          () => historyRemote.fetchFor(pubKey),
        ).thenAnswer((_) async => [_tx('tx-1'), _tx('tx-2')]);
        when(() => syncLocal.queryByStatus('voided_locally')).thenAnswer(
          (_) async => [
            {'id': 'tx-1', 'amount': 25.0},
          ],
        );
        when(
          () => syncLocal.markSyncedFromVoided('tx-1'),
        ).thenAnswer((_) async {});

        final result = await repo.pullAndReconcile(pubKey);

        expect(result, isA<Success<ReconcileOutcome>>());
        final outcome = (result as Success<ReconcileOutcome>).data;
        expect(outcome.reconciled, 1);
        expect(outcome.serverBalance, serverBalance);
        verify(() => syncLocal.markSyncedFromVoided('tx-1')).called(1);
      },
    );

    test(
      'leaves voided_locally row alone when server does NOT have the id',
      () async {
        when(
          () => historyRemote.fetchFor(pubKey),
        ).thenAnswer((_) async => [_tx('tx-other')]);
        when(() => syncLocal.queryByStatus('voided_locally')).thenAnswer(
          (_) async => [
            {'id': 'tx-cancelled', 'amount': 10.0},
          ],
        );

        final result = await repo.pullAndReconcile(pubKey);

        expect(result, isA<Success<ReconcileOutcome>>());
        final outcome = (result as Success<ReconcileOutcome>).data;
        expect(outcome.reconciled, 0);
        verifyNever(() => syncLocal.markSyncedFromVoided(any()));
      },
    );

    test('overrides wallet_cache balance even when reconciled == 0', () async {
      when(() => historyRemote.fetchFor(pubKey)).thenAnswer((_) async => []);
      when(
        () => syncLocal.queryByStatus('voided_locally'),
      ).thenAnswer((_) async => []);

      final result = await repo.pullAndReconcile(pubKey);

      expect(result, isA<Success<ReconcileOutcome>>());
      final outcome = (result as Success<ReconcileOutcome>).data;
      expect(outcome.serverBalance, serverBalance);
      verify(() => walletLocal.cacheBalance(pubKey, serverBalance)).called(1);
    });

    test('returns Failure(OFFLINE) on SocketException', () async {
      when(
        () => historyRemote.fetchFor(pubKey),
      ).thenThrow(const SocketException('no network'));

      final result = await repo.pullAndReconcile(pubKey);

      expect(result, isA<Failure<ReconcileOutcome>>());
      expect((result as Failure<ReconcileOutcome>).error.code, 'OFFLINE');
      verifyNever(() => walletLocal.cacheBalance(any(), any()));
    });
  });
}
