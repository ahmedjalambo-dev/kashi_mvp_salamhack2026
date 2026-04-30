import 'package:sqflite/sqflite.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/services/local_db.dart';
import '../models/wallet_model.dart';

class WalletLocalService {
  WalletLocalService([LocalDb? db]) : _db = db ?? LocalDb.instance;
  final LocalDb _db;

  Future<WalletModel?> loadCached(String publicKey) async {
    final db = await _db.database;
    final rows = await db.query(
      AppConstants.walletCacheTable,
      where: 'public_key = ?',
      whereArgs: [publicKey],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return WalletModel(
      id: 'cache',
      publicKey: publicKey,
      balance: (rows.first['balance'] as num).toDouble(),
    );
  }

  Future<void> cacheBalance(String publicKey, double balance) async {
    final db = await _db.database;
    await db.insert(AppConstants.walletCacheTable, {
      'public_key': publicKey,
      'balance': balance,
      'updated_at': DateTime.now().toUtc().toIso8601String(),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
  }
}
