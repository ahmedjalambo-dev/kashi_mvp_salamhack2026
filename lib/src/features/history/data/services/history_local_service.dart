import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';
import '../models/transaction_model.dart';

class HistoryLocalService {
  HistoryLocalService({LocalDb? db, PendingTxLocalService? pending})
    : _db = db ?? LocalDb.instance,
      _pending = pending ?? PendingTxLocalService();

  final LocalDb _db;
  final PendingTxLocalService _pending;

  /// Reactive stream that fires whenever pending rows change. Cubits use
  /// this to re-query so newly-received offline transactions surface
  /// immediately and so synced rows disappear from the pending list.
  Stream<void> get onPendingChange => _pending.onChange;

  Future<List<TransactionModel>> pendingFor(String publicKey) async {
    final rows = await _pending.queryAllForKey(publicKey);
    return rows.map(TransactionModel.fromPendingRow).toList(growable: false);
  }

  Future<List<TransactionModel>> cachedFor(String publicKey) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.transactionsCacheTable,
      where: 'sender_public_key = ? or receiver_public_key = ?',
      whereArgs: [publicKey, publicKey],
      orderBy: 'synced_at desc, client_created_at desc',
    );
    return rows.map(TransactionModel.fromCacheRow).toList(growable: false);
  }

  Future<void> upsertAll(List<TransactionModel> transactions) async {
    if (transactions.isEmpty) return;
    final db = await _db.database;
    final batch = db.batch();
    for (final tx in transactions) {
      batch.insert(
        AppConstants.transactionsCacheTable,
        Map<String, Object?>.from(tx.toCacheRow()),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
