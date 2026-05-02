import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/constants/app_constants.dart';
import '../models/wallet_model.dart';
import '../models/wallet_profile.dart';

class WalletRemoteService {
  WalletRemoteService(this._client);
  final SupabaseClient _client;

  Future<void> ensureSignedIn() async {
    if (_client.auth.currentSession == null) {
      await _client.auth.signInAnonymously();
    }
  }

  Future<WalletModel> upsertWallet({
    required String publicKey,
    required WalletProfile profile,
    String? deviceId,
  }) async {
    final user = _client.auth.currentUser;
    if (user == null) {
      throw const AuthException('Not authenticated');
    }

    final row = await _client
        .from(AppConstants.walletsTable)
        .upsert({
          'user_id': user.id,
          'public_key': publicKey,
          'device_id': deviceId,
          'display_name': profile.displayName,
          'phone': profile.phone,
          'iban': profile.iban,
        }, onConflict: 'public_key')
        .select()
        .single();
    return WalletModel.fromJson(row);
  }

  Future<WalletModel?> fetchByPublicKey(String publicKey) async {
    final row = await _client
        .from(AppConstants.walletsTable)
        .select()
        .eq('public_key', publicKey)
        .maybeSingle();
    if (row == null) return null;
    return WalletModel.fromJson(row);
  }
}
