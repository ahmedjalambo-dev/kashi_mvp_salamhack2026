import 'dart:async';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../../../send/data/models/payment_payload.dart';

class PendingRequestLocalService {
  PendingRequestLocalService([LocalDb? db]) : _db = db ?? LocalDb.instance;
  final LocalDb _db;

  final StreamController<void> _changes = StreamController<void>.broadcast();
  Stream<void> get onChange => _changes.stream;
  void _notify() {
    if (!_changes.isClosed) _changes.add(null);
  }

  Future<void> insert(PaymentRequest request) async {
    final db = await _db.database;
    await db.insert(AppConstants.pendingRequestsTable, {
      'id': request.id,
      'receiver_public_key': request.receiverPublicKey,
      'amount': request.amount,
      'nonce': request.nonce,
      'client_created_at': request.clientCreatedAt.toUtc().toIso8601String(),
      'expires_at': request.expiresAt.toUtc().toIso8601String(),
      'status': 'awaiting',
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
    _notify();
  }

  Future<void> markFulfilledLocally(String id) async {
    final db = await _db.database;
    await db.update(
      AppConstants.pendingRequestsTable,
      {'status': 'fulfilled_locally'},
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
  }

  Future<void> delete(String id) async {
    final db = await _db.database;
    await db.delete(
      AppConstants.pendingRequestsTable,
      where: 'id = ?',
      whereArgs: [id],
    );
    _notify();
  }

  Future<void> deleteByIds(Iterable<String> ids) async {
    if (ids.isEmpty) return;
    final db = await _db.database;
    final placeholders = ids.map((_) => '?').join(', ');
    await db.rawDelete(
      'DELETE FROM ${AppConstants.pendingRequestsTable} WHERE id IN ($placeholders)',
      ids.toList(),
    );
    _notify();
  }

  Future<List<Map<String, Object?>>> queryAwaitingFor(String publicKey) async {
    final db = await _db.database;
    return db.query(
      AppConstants.pendingRequestsTable,
      where: 'receiver_public_key = ? AND status = ?',
      whereArgs: [publicKey, 'awaiting'],
      orderBy: 'created_at desc',
    );
  }
}
