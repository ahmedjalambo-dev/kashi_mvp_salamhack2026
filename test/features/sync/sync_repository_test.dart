import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/core/network/error_handler.dart';
import 'package:kashi_mvp_salamhack2026/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/features/history/data/services/history_remote_service.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/data/repositories/sync_repository.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/data/services/sync_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/sync/data/services/sync_remote_service.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/services/wallet_local_service.dart';
import 'package:kashi_mvp_salamhack2026/features/wallet/data/services/wallet_remote_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSyncRemoteService extends Mock implements SyncRemoteService {}

class _MockSyncLocalService extends Mock implements SyncLocalService {}

class _MockHistoryRemoteService extends Mock implements HistoryRemoteService {}

class _MockWalletRemoteService extends Mock implements WalletRemoteService {}

class _MockWalletLocalService extends Mock implements WalletLocalService {}

// A minimal pending-row fixture used by all tests.
const _row = {
  'id': 'tx-uuid-1',
  'sender_public_key': 'sender',
  'receiver_public_key': 'receiver',
  'amount': 10.0,
  'nonce': 'nonce',
  'signature': 'sig',
  'signed_payload': '{"id":"tx-uuid-1"}',
  'client_created_at': '2026-01-01T00:00:00.000Z',
  'expires_at': '2026-01-01T01:00:00.000Z',
};

void main() {
  late _MockSyncRemoteService remote;
  late _MockSyncLocalService local;
  late _MockHistoryRemoteService historyRemote;
  late _MockWalletRemoteService walletRemote;
  late _MockWalletLocalService walletLocal;
  late SyncRepository repo;

  setUp(() {
    remote = _MockSyncRemoteService();
    local = _MockSyncLocalService();
    historyRemote = _MockHistoryRemoteService();
    walletRemote = _MockWalletRemoteService();
    walletLocal = _MockWalletLocalService();
    repo = SyncRepository(
      remote: remote,
      local: local,
      errors: const ErrorHandler(),
      remoteHistory: historyRemote,
      walletRemote: walletRemote,
      walletLocal: walletLocal,
    );

    // Default stubs — override per test.
    when(() => local.pending()).thenAnswer((_) async => [_row]);
    when(() => local.markSynced(any())).thenAnswer((_) async {});
    when(() => local.markRejected(any(), any())).thenAnswer((_) async {});
    when(() => local.pendingCount()).thenAnswer((_) async => 0);
    when(() => remote.transactionExists(any())).thenAnswer((_) async => false);
    // Default stubs for the incoming_pending drain loop.
    when(() => local.pendingIncoming()).thenAnswer((_) async => []);
    when(() => local.markIncomingSynced(any())).thenAnswer((_) async {});
    when(() => local.markIncomingRejected(any(), any())).thenAnswer((_) async {});
  });

  test('23505 unique-violation is treated as successful sync', () async {
    when(
      () => remote.push(
        id: any(named: 'id'),
        senderPublicKey: any(named: 'senderPublicKey'),
        receiverPublicKey: any(named: 'receiverPublicKey'),
        amount: any(named: 'amount'),
        nonce: any(named: 'nonce'),
        signature: any(named: 'signature'),
        signedPayload: any(named: 'signedPayload'),
        clientCreatedAt: any(named: 'clientCreatedAt'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenThrow(
      PostgrestException(code: '23505', message: 'duplicate key value'),
    );

    final result = await repo.drainPending();

    expect(result, isA<Success<SyncOutcome>>());
    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 1);
    expect(outcome.failed, 0);
    verify(() => local.markSynced('tx-uuid-1')).called(1);
    verifyNever(() => local.markRejected(any(), any()));
  });

  test(
    'INSUFFICIENT_FUNDS (P0001) leaves row pending and does not fail',
    () async {
      when(
        () => remote.push(
          id: any(named: 'id'),
          senderPublicKey: any(named: 'senderPublicKey'),
          receiverPublicKey: any(named: 'receiverPublicKey'),
          amount: any(named: 'amount'),
          nonce: any(named: 'nonce'),
          signature: any(named: 'signature'),
          signedPayload: any(named: 'signedPayload'),
          clientCreatedAt: any(named: 'clientCreatedAt'),
          expiresAt: any(named: 'expiresAt'),
        ),
      ).thenThrow(
        PostgrestException(code: 'P0001', message: 'INSUFFICIENT_FUNDS'),
      );

      final result = await repo.drainPending();

      expect(result, isA<Success<SyncOutcome>>());
      final outcome = (result as Success<SyncOutcome>).data;
      expect(outcome.synced, 0);
      expect(outcome.failed, 0);
      verifyNever(() => local.markSynced(any()));
      verifyNever(() => local.markRejected(any(), any()));
    },
  );

  test('other PostgrestException is a permanent failure', () async {
    when(
      () => remote.push(
        id: any(named: 'id'),
        senderPublicKey: any(named: 'senderPublicKey'),
        receiverPublicKey: any(named: 'receiverPublicKey'),
        amount: any(named: 'amount'),
        nonce: any(named: 'nonce'),
        signature: any(named: 'signature'),
        signedPayload: any(named: 'signedPayload'),
        clientCreatedAt: any(named: 'clientCreatedAt'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenThrow(
      PostgrestException(code: '23502', message: 'not-null violation'),
    );

    final result = await repo.drainPending();

    expect(result, isA<Success<SyncOutcome>>());
    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 0);
    expect(outcome.failed, 1);
    verify(() => local.markRejected('tx-uuid-1', any())).called(1);
    verifyNever(() => local.markSynced(any()));
  });

  test('successful RPC response increments synced counter', () async {
    when(
      () => remote.push(
        id: any(named: 'id'),
        senderPublicKey: any(named: 'senderPublicKey'),
        receiverPublicKey: any(named: 'receiverPublicKey'),
        amount: any(named: 'amount'),
        nonce: any(named: 'nonce'),
        signature: any(named: 'signature'),
        signedPayload: any(named: 'signedPayload'),
        clientCreatedAt: any(named: 'clientCreatedAt'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer((_) async => {'status': 'ok'});

    final result = await repo.drainPending();

    expect(result, isA<Success<SyncOutcome>>());
    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 1);
    expect(outcome.failed, 0);
    verify(() => local.markSynced('tx-uuid-1')).called(1);
  });

  // _isDuplicate broadened matcher tests

  test('P0001 with "duplicate key" message is treated as synced', () async {
    when(
      () => remote.push(
        id: any(named: 'id'),
        senderPublicKey: any(named: 'senderPublicKey'),
        receiverPublicKey: any(named: 'receiverPublicKey'),
        amount: any(named: 'amount'),
        nonce: any(named: 'nonce'),
        signature: any(named: 'signature'),
        signedPayload: any(named: 'signedPayload'),
        clientCreatedAt: any(named: 'clientCreatedAt'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenThrow(
      PostgrestException(
        code: 'P0001',
        message: 'duplicate key value violates unique constraint',
      ),
    );

    final result = await repo.drainPending();

    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 1);
    expect(outcome.failed, 0);
    verify(() => local.markSynced('tx-uuid-1')).called(1);
    verifyNever(() => local.markRejected(any(), any()));
  });

  test('HTTP 409 PostgrestException is treated as synced', () async {
    when(
      () => remote.push(
        id: any(named: 'id'),
        senderPublicKey: any(named: 'senderPublicKey'),
        receiverPublicKey: any(named: 'receiverPublicKey'),
        amount: any(named: 'amount'),
        nonce: any(named: 'nonce'),
        signature: any(named: 'signature'),
        signedPayload: any(named: 'signedPayload'),
        clientCreatedAt: any(named: 'clientCreatedAt'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenThrow(
      PostgrestException(code: '409', message: 'conflict'),
    );

    final result = await repo.drainPending();

    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 1);
    expect(outcome.failed, 0);
    verify(() => local.markSynced('tx-uuid-1')).called(1);
    verifyNever(() => local.markRejected(any(), any()));
  });

  test('RPC status "exists" is treated as synced', () async {
    when(
      () => remote.push(
        id: any(named: 'id'),
        senderPublicKey: any(named: 'senderPublicKey'),
        receiverPublicKey: any(named: 'receiverPublicKey'),
        amount: any(named: 'amount'),
        nonce: any(named: 'nonce'),
        signature: any(named: 'signature'),
        signedPayload: any(named: 'signedPayload'),
        clientCreatedAt: any(named: 'clientCreatedAt'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer((_) async => {'status': 'exists'});

    final result = await repo.drainPending();

    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 1);
    expect(outcome.failed, 0);
    verify(() => local.markSynced('tx-uuid-1')).called(1);
    verifyNever(() => local.markRejected(any(), any()));
  });

  test('RPC status "already_synced" is treated as synced', () async {
    when(
      () => remote.push(
        id: any(named: 'id'),
        senderPublicKey: any(named: 'senderPublicKey'),
        receiverPublicKey: any(named: 'receiverPublicKey'),
        amount: any(named: 'amount'),
        nonce: any(named: 'nonce'),
        signature: any(named: 'signature'),
        signedPayload: any(named: 'signedPayload'),
        clientCreatedAt: any(named: 'clientCreatedAt'),
        expiresAt: any(named: 'expiresAt'),
      ),
    ).thenAnswer((_) async => {'status': 'already_synced'});

    final result = await repo.drainPending();

    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 1);
    expect(outcome.failed, 0);
    verify(() => local.markSynced('tx-uuid-1')).called(1);
    verifyNever(() => local.markRejected(any(), any()));
  });

  // _isCallerNotReceiver (42501) tests — sender's outgoing row

  test(
    '42501 + tx exists server-side → treated as synced (receiver already settled)',
    () async {
      when(
        () => remote.push(
          id: any(named: 'id'),
          senderPublicKey: any(named: 'senderPublicKey'),
          receiverPublicKey: any(named: 'receiverPublicKey'),
          amount: any(named: 'amount'),
          nonce: any(named: 'nonce'),
          signature: any(named: 'signature'),
          signedPayload: any(named: 'signedPayload'),
          clientCreatedAt: any(named: 'clientCreatedAt'),
          expiresAt: any(named: 'expiresAt'),
        ),
      ).thenThrow(
        PostgrestException(
          code: '42501',
          message: 'caller is not receiver wallet owner',
        ),
      );
      when(() => remote.transactionExists(any())).thenAnswer((_) async => true);

      final result = await repo.drainPending();

      expect(result, isA<Success<SyncOutcome>>());
      final outcome = (result as Success<SyncOutcome>).data;
      expect(outcome.synced, 1);
      expect(outcome.failed, 0);
      verify(() => local.markSynced('tx-uuid-1')).called(1);
      verifyNever(() => local.markRejected(any(), any()));
    },
  );

  test(
    '42501 + tx does NOT exist server-side → row stays pending (receiver not yet synced)',
    () async {
      when(
        () => remote.push(
          id: any(named: 'id'),
          senderPublicKey: any(named: 'senderPublicKey'),
          receiverPublicKey: any(named: 'receiverPublicKey'),
          amount: any(named: 'amount'),
          nonce: any(named: 'nonce'),
          signature: any(named: 'signature'),
          signedPayload: any(named: 'signedPayload'),
          clientCreatedAt: any(named: 'clientCreatedAt'),
          expiresAt: any(named: 'expiresAt'),
        ),
      ).thenThrow(
        PostgrestException(
          code: '42501',
          message: 'caller is not receiver wallet owner',
        ),
      );
      when(
        () => remote.transactionExists(any()),
      ).thenAnswer((_) async => false);

      final result = await repo.drainPending();

      expect(result, isA<Success<SyncOutcome>>());
      final outcome = (result as Success<SyncOutcome>).data;
      expect(outcome.synced, 0);
      expect(outcome.failed, 0);
      verifyNever(() => local.markSynced(any()));
      verifyNever(() => local.markRejected(any(), any()));
    },
  );

  test(
    '42501 + transactionExists throws SocketException → drain stops, returns current counts',
    () async {
      when(
        () => remote.push(
          id: any(named: 'id'),
          senderPublicKey: any(named: 'senderPublicKey'),
          receiverPublicKey: any(named: 'receiverPublicKey'),
          amount: any(named: 'amount'),
          nonce: any(named: 'nonce'),
          signature: any(named: 'signature'),
          signedPayload: any(named: 'signedPayload'),
          clientCreatedAt: any(named: 'clientCreatedAt'),
          expiresAt: any(named: 'expiresAt'),
        ),
      ).thenThrow(
        PostgrestException(
          code: '42501',
          message: 'caller is not receiver wallet owner',
        ),
      );
      when(
        () => remote.transactionExists(any()),
      ).thenThrow(const SocketException('connection reset'));

      final result = await repo.drainPending();

      expect(result, isA<Success<SyncOutcome>>());
      final outcome = (result as Success<SyncOutcome>).data;
      expect(outcome.synced, 0);
      expect(outcome.failed, 0);
      verifyNever(() => local.markSynced(any()));
      verifyNever(() => local.markRejected(any(), any()));
    },
  );

  test('requeueDuplicateRejections delegates to local service', () async {
    when(() => local.requeueDuplicateRejections()).thenAnswer((_) async {});

    await repo.requeueDuplicateRejections();

    verify(() => local.requeueDuplicateRejections()).called(1);
  });
}
