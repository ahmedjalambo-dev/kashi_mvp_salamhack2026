class AppConstants {
  AppConstants._();

  static const sqliteDbName = 'kashi.db';
  static const pendingTxTable = 'pending_transactions';
  static const transactionsCacheTable = 'transactions_cache';

  static const secureStoragePrivateKey = 'kashi.privateKey';
  static const sharedPublicKeyPref = 'kashi.publicKey';

  static const envSupabaseUrl = 'SUPABASE_URL';
  static const envSupabaseAnonKey = 'SUPABASE_ANON_KEY';

  static const walletsTable = 'wallets';
  static const transactionsTable = 'transactions';
  static const syncRpc = 'sync_transaction';
}
