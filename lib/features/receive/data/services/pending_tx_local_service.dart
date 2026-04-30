import 'dart:async';
import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../../../send/data/models/payment_payload.dart';

class PendingTxLocalService {
  PendingTxLocalService([LocalDb? db]) : _db = db ?? LocalDb.instance;
  final LocalDb _db;

  // Broadcast notifier so cubits can re-query whenever the pending table
  // changes (insert from receive, status flip from sync). Enables reactive
  // UI without polling.
  final StreamController<void> _changes = StreamController<void>.broadcast();
  Stream<void> get onChange => _changes.stream;
  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

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
      'client_created_at': envelope.payload.clientCreatedAt
          .toUtc()
          .toIso8601String(),
      'expires_at': envelope.payload.expiresAt.toUtc().toIso8601String(),
      'status': 'pending_sync',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    _notify();
  }

  /// Insert a row representing an outgoing transaction the user just signed
  /// while offline. Mirrors [insert] but the caller already has the raw
  /// fields (the sender doesn't go through the scanner).
  Future<void> insertOutgoing({required SignedEnvelope envelope}) async {
    await insert(envelope);
  }

  Future<List<Map<String, Object?>>> queryAllForKey(String publicKey) async {
    final db = await _db.database;
    return db.query(
      AppConstants.pendingTxTable,
      where:
          '(sender_public_key = ? or receiver_public_key = ?) and status = ?',
      whereArgs: [publicKey, publicKey, 'pending_sync'],
      orderBy: 'created_at desc',
    );
  }

  Future<int> pendingCount() async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.pendingTxTable,
      columns: ['count(*) as n'],
      where: "status = 'pending_sync'",
    );
    return (rows.first['n'] as int? ?? 0);
  }

  Future<double> pendingOutgoingSum(String senderPublicKey) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.pendingTxTable,
      columns: ['amount'],
      where: "sender_public_key = ? and status = 'pending_sync'",
      whereArgs: [senderPublicKey],
    );
    return rows.fold<double>(
      0.0,
      (sum, r) => sum + (r['amount'] as num).toDouble(),
    );
  }

  Future<List<Map<String, Object?>>> queryPending() async {
    final db = await _db.database;
    return db.query(
      AppConstants.pendingTxTable,
      where: 'status = ?',
      whereArgs: ['pending_sync'],
      orderBy: 'created_at asc',
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
    _notify();
  }

  Future<void> markRejected(String id, String reason) async {
    final db = await _db.database;
    await db.update(
      AppConstants.pendingTxTable,
      {'status': 'rejected', 'last_error': reason},
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
  }

  /// Marks an outgoing row as voided locally (optimistic cancel).
  /// Only affects rows still in `pending_sync`; returns 0 if already settled.
  Future<int> markVoidedLocally(String id) async {
    final db = await _db.database;
    final affected = await db.update(
      AppConstants.pendingTxTable,
      {'status': 'voided_locally', 'last_error': null},
      where: 'id = ? AND status = ?',
      whereArgs: [id, 'pending_sync'],
    );
    if (affected > 0) _notify();
    return affected;
  }

  /// Reconciliation: flip a `voided_locally` row to `synced` when the server
  /// confirms the receiver already settled it. Gated on `voided_locally` so
  /// rows in other states are never accidentally overwritten.
  Future<void> markSyncedFromVoided(String id) async {
    final db = await _db.database;
    final affected = await db.update(
      AppConstants.pendingTxTable,
      {'status': 'synced', 'last_error': null},
      where: 'id = ? AND status = ?',
      whereArgs: [id, 'voided_locally'],
    );
    if (affected > 0) _notify();
  }

  /// Returns all rows with the given status, ordered by created_at asc.
  Future<List<Map<String, Object?>>> queryByStatus(String status) async {
    final db = await _db.database;
    return db.query(
      AppConstants.pendingTxTable,
      where: 'status = ?',
      whereArgs: [status],
      orderBy: 'created_at asc',
    );
  }

  /// Flip stale rejected rows that look like duplicate-key errors back to
  /// pending_sync so the next drain can re-classify them correctly. Runs once
  /// at app startup via SyncCubit to recover from the pre-fix bug.
  Future<void> requeueDuplicateRejections() async {
    final db = await _db.database;
    final count = await db.rawUpdate(
      "UPDATE ${AppConstants.pendingTxTable} "
      "SET status = 'pending_sync', last_error = NULL "
      "WHERE status = 'rejected' "
      "AND (last_error LIKE '%duplicate%' OR last_error LIKE '%unique%' OR last_error LIKE '%caller is not receiver%')",
    );
    if (count > 0) _notify();
  }
}
