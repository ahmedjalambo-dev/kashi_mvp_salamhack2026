import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';

class SyncRemoteService {
  SyncRemoteService(this._client);
  final SupabaseClient _client;

  Future<Map<String, dynamic>> push({
    required String id,
    required String senderPublicKey,
    required String receiverPublicKey,
    required double amount,
    required String nonce,
    required String signature,
    required Map<String, dynamic> signedPayload,
    required DateTime clientCreatedAt,
    required DateTime expiresAt,
  }) async {
    final result = await _client.rpc(
      AppConstants.syncRpc,
      params: {
        'p_id': id,
        'p_sender_public_key': senderPublicKey,
        'p_receiver_public_key': receiverPublicKey,
        'p_amount': amount,
        'p_nonce': nonce,
        'p_signature': signature,
        'p_signed_payload': signedPayload,
        'p_client_created_at': clientCreatedAt.toUtc().toIso8601String(),
        'p_expires_at': expiresAt.toUtc().toIso8601String(),
      },
    );
    return (result as Map).cast<String, dynamic>();
  }
}
