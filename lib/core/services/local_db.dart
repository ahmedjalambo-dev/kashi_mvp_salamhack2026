import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../constants/app_constants.dart';

class LocalDb {
  LocalDb._();
  static final LocalDb instance = LocalDb._();

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getApplicationDocumentsDirectory();
    final path = p.join(dir.path, AppConstants.sqliteDbName);
    return openDatabase(
      path,
      version: 7,
      onCreate: (db, _) async {
        await db.execute('''
          create table ${AppConstants.pendingTxTable} (
            id text primary key,
            sender_public_key text not null,
            receiver_public_key text not null,
            amount real not null,
            nonce text not null,
            signature text not null,
            signed_payload text not null,
            client_created_at text not null,
            expires_at text not null,
            status text not null default 'pending_sync',
            last_error text,
            created_at text not null
          );
        ''');
        await db.execute(
          'create index pending_status_idx on ${AppConstants.pendingTxTable}(status, created_at);',
        );
        await _createTransactionsCache(db);
        await _createWalletCache(db);
        await _createPendingRequests(db);
        await _createIncomingPending(db);
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            "alter table ${AppConstants.pendingTxTable} add column expires_at text not null default '1970-01-01T00:00:00.000Z';",
          );
          await db.execute(
            "update ${AppConstants.pendingTxTable} set expires_at = datetime(client_created_at, '+1 hour');",
          );
        }
        if (oldVersion < 3) {
          await _createTransactionsCache(db);
        }
        if (oldVersion < 4) {
          await _createWalletCache(db);
        }
        if (oldVersion < 5) {
          await db.execute(
            "UPDATE ${AppConstants.pendingTxTable} SET status = 'voided_locally' WHERE status = 'cancelled';",
          );
        }
        if (oldVersion < 6) {
          await _createPendingRequests(db);
        }
        if (oldVersion < 7) {
          await _createIncomingPending(db);
        }
      },
    );
  }

  Future<void> _createWalletCache(Database db) async {
    await db.execute('''
      create table ${AppConstants.walletCacheTable} (
        public_key text primary key,
        balance real not null,
        updated_at text not null
      );
    ''');
  }

  Future<void> _createIncomingPending(Database db) async {
    await db.execute('''
      create table ${AppConstants.incomingPendingTable} (
        id text primary key,
        sender_public_key text not null,
        receiver_public_key text not null,
        amount real not null,
        nonce text not null,
        signature text not null,
        signed_payload text not null,
        client_created_at text not null,
        expires_at text not null,
        status text not null default 'pending_sync',
        last_error text,
        created_at text not null
      );
    ''');
    await db.execute(
      'create index incoming_pending_status_idx on ${AppConstants.incomingPendingTable}(status, created_at);',
    );
  }

  Future<void> _createPendingRequests(Database db) async {
    await db.execute('''
      create table ${AppConstants.pendingRequestsTable} (
        id text primary key,
        receiver_public_key text not null,
        amount real not null,
        nonce text not null,
        client_created_at text not null,
        expires_at text not null,
        status text not null default 'awaiting',
        created_at text not null
      );
    ''');
    await db.execute(
      'create index pending_requests_status_idx on ${AppConstants.pendingRequestsTable}(status, created_at);',
    );
  }

  Future<void> _createTransactionsCache(Database db) async {
    await db.execute('''
      create table ${AppConstants.transactionsCacheTable} (
        id text primary key,
        sender_public_key text not null,
        receiver_public_key text not null,
        amount real not null,
        status text not null,
        client_created_at text not null,
        synced_at text
      );
    ''');
    await db.execute(
      'create index tx_cache_synced_idx on ${AppConstants.transactionsCacheTable}(synced_at desc);',
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}
