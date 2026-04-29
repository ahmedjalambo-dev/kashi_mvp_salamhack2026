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
      version: 2,
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
            status text not null default 'pending_sync',
            last_error text,
            retry_count integer not null default 0,
            created_at text not null
          );
        ''');
        await db.execute(
          'create index pending_status_idx on ${AppConstants.pendingTxTable}(status);',
        );
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'alter table ${AppConstants.pendingTxTable} add column retry_count integer not null default 0;',
          );
        }
      },
    );
  }

  Future<void> close() async {
    await _db?.close();
    _db = null;
  }
}

