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

const _incomingRow = {
  'id': 'rx-uuid-1',
  'sender_public_key': 'sender',
  'receiver_public_key': 'receiver',
  'amount': 25.0,
  'nonce': 'nonce',
  'signature': 'sig',
  'signed_payload': '{"id":"rx-uuid-1"}',
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

    // Outgoing table is empty — only receiver has the signed envelope.
    when(() => local.pending()).thenAnswer((_) async => []);
    when(() => local.pendingIncoming()).thenAnswer((_) async => [_incomingRow]);
    when(() => local.markIncomingSynced(any())).thenAnswer((_) async {});
    when(
      () => local.markIncomingRejected(any(), any()),
    ).thenAnswer((_) async {});
  });

  test(
    'receiver-online-first: incoming_pending row is pushed via RPC and marked synced',
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
      ).thenAnswer((_) async => {'status': 'ok'});

      final result = await repo.drainPending();

      expect(result, isA<Success<SyncOutcome>>());
      final outcome = (result as Success<SyncOutcome>).data;
      expect(outcome.synced, 1);
      expect(outcome.failed, 0);
      verify(() => local.markIncomingSynced('rx-uuid-1')).called(1);
      verifyNever(() => local.markSynced(any()));
      verifyNever(() => local.markIncomingRejected(any(), any()));
    },
  );

  test('incoming duplicate (23505) is treated as synced', () async {
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

    final outcome = (result as Success<SyncOutcome>).data;
    expect(outcome.synced, 1);
    expect(outcome.failed, 0);
    verify(() => local.markIncomingSynced('rx-uuid-1')).called(1);
  });

  test(
    'SocketException during incoming drain stops loop and returns current counts',
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
      ).thenThrow(const SocketException('connection reset'));

      final result = await repo.drainPending();

      final outcome = (result as Success<SyncOutcome>).data;
      expect(outcome.synced, 0);
      expect(outcome.failed, 0);
      verifyNever(() => local.markIncomingSynced(any()));
      verifyNever(() => local.markIncomingRejected(any(), any()));
    },
  );
}
