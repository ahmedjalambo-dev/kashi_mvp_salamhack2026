import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../history/data/services/history_remote_service.dart';
import '../../../wallet/data/services/wallet_local_service.dart';
import '../../../wallet/data/services/wallet_remote_service.dart';
import '../services/sync_local_service.dart';
import '../services/sync_remote_service.dart';

class SyncOutcome {
  final int synced;
  final int failed;
  const SyncOutcome(this.synced, this.failed);
}

class ReconcileOutcome {
  final int reconciled;
  final double? serverBalance;
  const ReconcileOutcome(this.reconciled, this.serverBalance);
}

class SyncRepository {
  SyncRepository({
    required SyncRemoteService remote,
    required SyncLocalService local,
    required ErrorHandler errors,
    required HistoryRemoteService remoteHistory,
    required WalletRemoteService walletRemote,
    required WalletLocalService walletLocal,
  }) : _remote = remote,
       _local = local,
       _errors = errors,
       _remoteHistory = remoteHistory,
       _walletRemote = walletRemote,
       _walletLocal = walletLocal;

  final SyncRemoteService _remote;
  final SyncLocalService _local;
  final ErrorHandler _errors;
  final HistoryRemoteService _remoteHistory;
  final WalletRemoteService _walletRemote;
  final WalletLocalService _walletLocal;

  Future<Result<SyncOutcome>> drainPending() async {
    try {
      final rows = await _local.pending();
      var synced = 0;
      var failed = 0;
      for (final row in rows) {
        final id = row['id'] as String;
        try {
          final response = await _remote.push(
            id: id,
            senderPublicKey: row['sender_public_key'] as String,
            receiverPublicKey: row['receiver_public_key'] as String,
            amount: (row['amount'] as num).toDouble(),
            nonce: row['nonce'] as String,
            signature: row['signature'] as String,
            signedPayload: (jsonDecode(row['signed_payload'] as String) as Map)
                .cast<String, dynamic>(),
            clientCreatedAt: DateTime.parse(row['client_created_at'] as String),
            expiresAt: DateTime.parse(row['expires_at'] as String),
          );
          // A 'duplicate'/'exists'/'already_synced' status means the server
          // already processed this TX (idempotent re-delivery). Count as synced.
          final status = response['status'] as String? ?? 'ok';
          const okStatuses = {'ok', 'duplicate', 'exists', 'already_synced'};
          if (okStatuses.contains(status)) {
            await _local.markSynced(id);
            synced++;
          } else {
            await _local.markRejected(id, 'server status: $status');
            failed++;
          }
        } on PostgrestException catch (e) {
          // The receiver already pushed this UUID — server settled it. Mark
          // synced locally so the row leaves the pending queue and the synced
          // counter increments (not failed).
          if (_isDuplicate(e)) {
            await _local.markSynced(id);
            synced++;
            continue;
          }
          // Transient: sender chain hasn't synced yet — leave pending to retry.
          if (_isInsufficientFunds(e)) continue;
          // The RPC requires the caller to own the receiver wallet, so the
          // sender's outgoing row always hits 42501. Check if the receiver has
          // already settled this tx server-side; if yes, mark synced so the
          // row leaves the pending queue without incrementing failed.
          if (_isCallerNotReceiver(e)) {
            try {
              if (await _remote.transactionExists(id)) {
                await _local.markSynced(id);
                synced++;
              }
              // else: receiver hasn't synced yet — leave row pending_sync for
              // the next connectivity edge or retry timer.
            } on SocketException {
              return Success(SyncOutcome(synced, failed));
            }
            continue;
          }
          // Permanent rejection (bad signature, other constraint, etc.)
          await _local.markRejected(id, e.message);
          failed++;
        } on SocketException {
          // Connectivity dropped — stop the loop, leave row pending.
          return Success(SyncOutcome(synced, failed));
        }
      }

      return Success(SyncOutcome(synced, failed));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  Future<int> pendingCount() => _local.pendingCount();

  Future<void> requeueDuplicateRejections() =>
      _local.requeueDuplicateRejections();

  /// Pull server transactions and reconcile any `voided_locally` rows that the
  /// server has already settled. Also hard-overrides the local wallet cache with
  /// the authoritative server balance so the sender can't spend against a stale
  /// refund.
  Future<Result<ReconcileOutcome>> pullAndReconcile(String publicKey) async {
    try {
      final serverTxs = await _remoteHistory.fetchFor(publicKey);
      final serverIds = {for (final t in serverTxs) t.id};

      final voided = await _local.queryByStatus('voided_locally');
      var reconciled = 0;
      for (final row in voided) {
        final id = row['id'] as String;
        if (serverIds.contains(id)) {
          await _local.markSyncedFromVoided(id);
          reconciled++;
        }
      }

      final wallet = await _walletRemote.fetchByPublicKey(publicKey);
      if (wallet != null) {
        await _walletLocal.cacheBalance(publicKey, wallet.balance);
        return Success(ReconcileOutcome(reconciled, wallet.balance));
      }
      return Success(ReconcileOutcome(reconciled, null));
    } on SocketException {
      return const Failure(ErrorModel(message: 'Offline', code: 'OFFLINE'));
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  // Recognises every plausible duplicate signal a Supabase RPC can produce:
  // SQLSTATE 23505, PostgREST HTTP 409, or a P0001 RAISE EXCEPTION whose
  // message contains the duplicate text.
  bool _isDuplicate(PostgrestException e) {
    if (e.code == '23505') return true;
    if (e.code == '409') return true;
    final msg = e.message.toLowerCase();
    return msg.contains('duplicate key') ||
        msg.contains('unique constraint') ||
        msg.contains('already exists');
  }

  // P0001 is a Postgres RAISE EXCEPTION; the message is set by the RPC.
  bool _isInsufficientFunds(PostgrestException e) =>
      e.code == 'P0001' && e.message.contains('INSUFFICIENT_FUNDS');

  // The RPC rejects when the caller doesn't own the receiver wallet (42501).
  // This is the expected path for sender-originated rows — the RPC is designed
  // for receivers only.
  bool _isCallerNotReceiver(PostgrestException e) =>
      e.code == '42501' ||
      e.message.toLowerCase().contains('caller is not receiver');
}
