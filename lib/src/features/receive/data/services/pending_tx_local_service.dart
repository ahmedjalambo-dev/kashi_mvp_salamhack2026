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
      'created_at': DateTime.now().toUtc().toIso8601String(),
    });
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
}
