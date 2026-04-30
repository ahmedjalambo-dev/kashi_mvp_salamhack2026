import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/transaction_model.dart';

class HistoryRemoteService {
  HistoryRemoteService(this._client);
  final SupabaseClient _client;

  Future<List<TransactionModel>> fetchFor(String publicKey) async {
    final rows = await _client
        .from(AppConstants.transactionsTable)
        .select()
        .or('sender_public_key.eq.$publicKey,receiver_public_key.eq.$publicKey')
        .order('synced_at', ascending: false)
        .limit(200);
    return (rows as List)
        .cast<Map<String, dynamic>>()
        .map(TransactionModel.fromRemote)
        .toList(growable: false);
  }
}
