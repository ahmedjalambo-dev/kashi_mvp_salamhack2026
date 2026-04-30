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
}
