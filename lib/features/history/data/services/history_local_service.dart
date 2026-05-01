import 'dart:async';

import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../../../receive/data/services/incoming_pending_local_service.dart';
import '../../../receive/data/services/pending_request_local_service.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';
import '../models/transaction_model.dart';

class HistoryLocalService {
  HistoryLocalService({
    LocalDb? db,
    PendingTxLocalService? pending,
    PendingRequestLocalService? requests,
    IncomingPendingLocalService? incomingPending,
  }) : _db = db ?? LocalDb.instance,
       _pending = pending ?? PendingTxLocalService(),
       _requests = requests ?? PendingRequestLocalService(),
       _incomingPending = incomingPending ?? IncomingPendingLocalService();

  final LocalDb _db;
  final PendingTxLocalService _pending;
  final PendingRequestLocalService _requests;
  final IncomingPendingLocalService _incomingPending;

  /// Fires whenever any of the three pending tables change so cubits keep the
  /// UI reactive without polling.
  Stream<void> get onPendingChange => StreamGroup.merge([
    _pending.onChange,
    _requests.onChange,
    _incomingPending.onChange,
  ]);

  Future<List<TransactionModel>> pendingFor(String publicKey) async {
    final txRows = await _pending.queryAllForKey(publicKey);
    final reqRows = await _requests.queryAwaitingFor(publicKey);
    final incomingRows = await _incomingPending.queryAllForKey(publicKey);

    final txModels =
        txRows.map(TransactionModel.fromPendingRow).toList(growable: true);
    final reqModels =
        reqRows
            .map(TransactionModel.fromPendingRequestRow)
            .toList(growable: true);
    final incomingModels =
        incomingRows
            .map(TransactionModel.fromIncomingPendingRow)
            .toList(growable: true);

    final merged = [...txModels, ...reqModels, ...incomingModels];
    merged.sort((a, b) => b.clientCreatedAt.compareTo(a.clientCreatedAt));
    return merged;
  }

  Future<void> deleteRequestsForIds(Iterable<String> ids) async {
    await _requests.deleteByIds(ids);
  }

  Future<void> deleteIncomingForIds(Iterable<String> ids) async {
    await _incomingPending.deleteByIds(ids);
  }

  Future<void> deleteRequest(String id) async {
    await _requests.delete(id);
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

/// Minimal stream merge helper — avoids pulling in the `async` package.
class StreamGroup {
  static Stream<void> merge(List<Stream<void>> streams) {
    late StreamController<void> controller;
    final subs = <StreamSubscription<void>>[];
    var active = streams.length;

    controller = StreamController<void>.broadcast(
      onListen: () {
        for (final s in streams) {
          subs.add(
            s.listen(
              (_) => controller.add(null),
              onError: controller.addError,
              onDone: () {
                active--;
                if (active == 0) controller.close();
              },
            ),
          );
        }
      },
      onCancel: () {
        for (final sub in subs) {
          sub.cancel();
        }
        subs.clear();
      },
    );
    return controller.stream;
  }
}
