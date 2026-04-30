import 'package:flutter_test/flutter_test.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/error_handler.dart';
import 'package:kashi_mvp_salamhack2026/src/core/network/result.dart';
import 'package:kashi_mvp_salamhack2026/src/features/sync/data/repositories/sync_repository.dart';
import 'package:kashi_mvp_salamhack2026/src/features/sync/data/services/sync_local_service.dart';
import 'package:kashi_mvp_salamhack2026/src/features/sync/data/services/sync_remote_service.dart';
import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class _MockSyncRemoteService extends Mock implements SyncRemoteService {}

class _MockSyncLocalService extends Mock implements SyncLocalService {}

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
  late SyncRepository repo;

  setUp(() {
    remote = _MockSyncRemoteService();
    local = _MockSyncLocalService();
    repo = SyncRepository(
      remote: remote,
      local: local,
      errors: const ErrorHandler(),
    );

    // Default stubs — override per test.
    when(() => local.pending()).thenAnswer((_) async => [_row]);
    when(() => local.markSynced(any())).thenAnswer((_) async {});
    when(() => local.markRejected(any(), any())).thenAnswer((_) async {});
    when(() => local.pendingCount()).thenAnswer((_) async => 0);
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
}
