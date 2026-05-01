import 'dart:async';
import 'dart:convert';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../../../send/data/models/payment_payload.dart';

/// Local service for inbound (receiver-owned) pending signed envelopes.
///
/// Mirrors [PendingTxLocalService] in structure. After the receiver scans the
/// sender's confirmation QR, the [SignedEnvelope] is stored here so the
/// receiver's [SyncRepository] can push it to Supabase when online.
class IncomingPendingLocalService {
  IncomingPendingLocalService([LocalDb? db]) : _db = db ?? LocalDb.instance;
  final LocalDb _db;

  final StreamController<void> _changes = StreamController<void>.broadcast();
  Stream<void> get onChange => _changes.stream;
  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> insert(SignedEnvelope envelope) async {
    final db = await _db.database;
    await db.insert(AppConstants.incomingPendingTable, {
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

  Future<List<Map<String, Object?>>> queryPending() async {
    final db = await _db.database;
    return db.query(
      AppConstants.incomingPendingTable,
      where: 'status = ?',
      whereArgs: ['pending_sync'],
      orderBy: 'created_at asc',
    );
  }

  Future<List<Map<String, Object?>>> queryAllForKey(String publicKey) async {
    final db = await _db.database;
    return db.query(
      AppConstants.incomingPendingTable,
      where:
          '(sender_public_key = ? or receiver_public_key = ?) and status = ?',
      whereArgs: [publicKey, publicKey, 'pending_sync'],
      orderBy: 'created_at desc',
    );
  }

  Future<int> pendingCount() async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.incomingPendingTable,
      columns: ['count(*) as n'],
      where: "status = 'pending_sync'",
    );
    return (rows.first['n'] as int? ?? 0);
  }

  Future<void> markSynced(String id) async {
    final db = await _db.database;
    await db.update(
      AppConstants.incomingPendingTable,
      {'status': 'synced', 'last_error': null},
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
  }

  Future<void> markRejected(String id, String reason) async {
    final db = await _db.database;
    await db.update(
      AppConstants.incomingPendingTable,
      {'status': 'rejected', 'last_error': reason},
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
  }

  /// Delete rows whose ids appear in [ids] (used by [HistoryLocalService]
  /// during reconciliation when the server already has these transactions).
  Future<void> deleteByIds(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = ids.map((_) => '?').join(', ');
    await db.rawDelete(
      'DELETE FROM ${AppConstants.incomingPendingTable} WHERE id IN ($placeholders)',
      ids.toList(),
    );
    _notify();
  }
}
