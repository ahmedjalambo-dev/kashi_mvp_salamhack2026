import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../../../send/data/models/payment_payload.dart';

class PendingTxLocalService {
  PendingTxLocalService([LocalDb? db]) : _db = db ?? LocalDb.instance;
  final LocalDb _db;

  Future<void> insert(SignedEnvelope envelope) async {
    final db = await _db.database;
    await db.insert(AppConstants.pendingTxTable, {
      'id': envelope.payload.id,
      'sender_public_key': envelope.payload.senderPublicKey,
      'receiver_public_key': envelope.payload.receiverPublicKey,
      'amount': envelope.payload.amount,
      'nonce': envelope.payload.nonce,
      'signature': envelope.signature,
      'signed_payload': jsonEncode(envelope.payload.toJson()),
      'client_created_at':
          envelope.payload.clientCreatedAt.toUtc().toIso8601String(),
      'status': 'pending_sync',
      'retry_count': 0,
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
  }

  /// Returns rows that need syncing: both `pending_sync` and `syncing`
  /// (the latter may exist if the app crashed mid-push).
  /// Excludes rows that have exceeded the retry limit.
  Future<List<Map<String, Object?>>> queryPending() async {
    final db = await _db.database;
    return db.query(
      AppConstants.pendingTxTable,
      where: 'status in (?, ?) and retry_count < ?',
      whereArgs: [
        'pending_sync',
        'syncing',
        AppConstants.maxSyncRetries,
      ],
      orderBy: 'created_at asc',
    );
  }

  /// Marks a transaction as currently being pushed to the server.
  /// This intermediate status makes sync crash-safe: if the app crashes
  /// after push succeeds but before markSynced, the row will be re-attempted
  /// on restart (idempotent via the transaction id primary key).
  Future<void> markSyncing(String id) async {
    final db = await _db.database;
    await db.update(
      AppConstants.pendingTxTable,
      {'status': 'syncing'},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markSynced(String id) async {
    final db = await _db.database;
    await db.update(
      AppConstants.pendingTxTable,
      {'status': 'synced', 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> markRejected(String id, String reason) async {
    final db = await _db.database;
    await db.update(
      AppConstants.pendingTxTable,
      {'status': 'rejected', 'last_error': reason},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Increments the retry count for a row. If the count reaches
  /// [AppConstants.maxSyncRetries], the status is set to `failed_permanently`.
  Future<void> incrementRetry(String id) async {
    final db = await _db.database;
    await db.rawUpdate(
      '''
      update ${AppConstants.pendingTxTable}
      set retry_count = retry_count + 1,
          status = case
            when retry_count + 1 >= ${AppConstants.maxSyncRetries}
              then 'failed_permanently'
            else status
          end
      where id = ?
      ''',
      [id],
    );
  }

  /// Sum of pending incoming amounts for the given public key.
  Future<double> sumPendingReceived(String myPublicKey) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      '''
      select coalesce(sum(amount), 0) as total
      from ${AppConstants.pendingTxTable}
      where receiver_public_key = ?
        and status in ('pending_sync', 'syncing')
      ''',
      [myPublicKey],
    );
    return (result.first['total'] as num).toDouble();
  }

  /// Sum of pending outgoing amounts for the given public key.
  Future<double> sumPendingSent(String myPublicKey) async {
    final db = await _db.database;
    final result = await db.rawQuery(
      '''
      select coalesce(sum(amount), 0) as total
      from ${AppConstants.pendingTxTable}
      where sender_public_key = ?
        and status in ('pending_sync', 'syncing')
      ''',
      [myPublicKey],
    );
    return (result.first['total'] as num).toDouble();
  }
}
