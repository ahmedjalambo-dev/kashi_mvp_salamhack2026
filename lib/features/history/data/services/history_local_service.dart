import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';
import '../models/transaction_model.dart';

class HistoryLocalService {
  HistoryLocalService({
    LocalDb? db,
    PendingTxLocalService? pending,
  }) : _db = db ?? LocalDb.instance,
       _pending = pending ?? PendingTxLocalService();

  final LocalDb _db;
  final PendingTxLocalService _pending;

  /// Fires whenever the pending table changes so cubits keep the UI reactive
  /// without polling.
  Stream<void> get onPendingChange => _pending.onChange;

  Future<List<TransactionModel>> pendingFor(String publicKey) async {
    final txRows = await _pending.queryAllForKey(publicKey);
    return txRows.map(TransactionModel.fromPendingRow).toList(growable: false);
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

    // Load all pending rows indexed by id so we can copy counterparty
    // profile fields that were captured at insert time.
    final pendingRows = await _pending.queryPending();
    final profileByTxId = {
      for (final r in pendingRows)
        r['id'] as String: (
          name: r['counterparty_name'] as String?,
          phone: r['counterparty_phone'] as String?,
          iban: r['counterparty_iban'] as String?,
        ),
    };

    final batch = db.batch();
    for (final tx in transactions) {
      final row = Map<String, Object?>.from(tx.toCacheRow());
      final profile = profileByTxId[tx.id];
      if (profile != null) {
        row['counterparty_name'] ??= profile.name;
        row['counterparty_phone'] ??= profile.phone;
        row['counterparty_iban'] ??= profile.iban;
      }
      batch.insert(
        AppConstants.transactionsCacheTable,
        row,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }
    await batch.commit(noResult: true);
  }
}
