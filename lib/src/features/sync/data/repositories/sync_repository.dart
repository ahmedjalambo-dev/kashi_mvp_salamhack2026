import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/network/error_handler.dart';
import '../../../../core/network/result.dart';
import '../services/sync_local_service.dart';
import '../services/sync_remote_service.dart';

class SyncOutcome {
  final int synced;
  final int failed;
  const SyncOutcome(this.synced, this.failed);
}

class SyncRepository {
  SyncRepository({
    required SyncRemoteService remote,
    required SyncLocalService local,
    required ErrorHandler errors,
  })  : _remote = remote,
        _local = local,
        _errors = errors;

  final SyncRemoteService _remote;
  final SyncLocalService _local;
  final ErrorHandler _errors;

  Future<Result<SyncOutcome>> drainPending() async {
    try {
      final rows = await _local.pending();
      var synced = 0;
      var failed = 0;
      for (final row in rows) {
        final id = row['id'] as String;
        try {
          await _remote.push(
            id: id,
            senderPublicKey: row['sender_public_key'] as String,
            receiverPublicKey: row['receiver_public_key'] as String,
            amount: (row['amount'] as num).toDouble(),
            nonce: row['nonce'] as String,
            signature: row['signature'] as String,
            signedPayload: (jsonDecode(row['signed_payload'] as String) as Map)
                .cast<String, dynamic>(),
            clientCreatedAt:
                DateTime.parse(row['client_created_at'] as String),
          );
          await _local.markSynced(id);
          synced++;
        } on PostgrestException catch (e) {
          // Permanent rejection (auth/permission/check failures)
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
}
