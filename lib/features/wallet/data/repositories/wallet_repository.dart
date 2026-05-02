import 'dart:async';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/crypto/ecdsa_signer.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../../core/utils/profile_generator.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';
import '../models/wallet_model.dart';
import '../models/wallet_profile.dart';
import '../services/wallet_local_service.dart';
import '../services/wallet_remote_service.dart';

class WalletRepository {
  WalletRepository({
    required WalletRemoteService remote,
    required WalletLocalService local,
    required SecureStorage secureStorage,
    required EcdsaSigner signer,
    required ErrorHandler errors,
    required PendingTxLocalService pendingTx,
  }) : _remote = remote,
       _local = local,
       _storage = secureStorage,
       _signer = signer,
       _errors = errors,
       _pendingTx = pendingTx;

  final WalletRemoteService _remote;
  final WalletLocalService _local;
  final SecureStorage _storage;
  final EcdsaSigner _signer;
  final ErrorHandler _errors;
  final PendingTxLocalService _pendingTx;

  static const _pubKeyStorageKey =
      '${AppConstants.secureStoragePrivateKey}.pub';

  /// Fires whenever the local wallet cache is updated (e.g. after reconciliation).
  Stream<void> get onCacheChange => _local.onChange;

  /// Returns the public key and profile, generating + persisting them if needed.
  Future<({String publicKey, WalletProfile profile})> ensureKeyPair() async {
    final priv = await _storage.read(AppConstants.secureStoragePrivateKey);
    final pub = await _storage.read(_pubKeyStorageKey);

    final String publicKey;
    if (priv == null || pub == null) {
      final pair = _signer.generateKeyPair();
      await _storage.write(
        AppConstants.secureStoragePrivateKey,
        pair.privateKeyBase64,
      );
      await _storage.write(_pubKeyStorageKey, pair.publicKeyBase64);
      publicKey = pair.publicKeyBase64;
    } else {
      publicKey = pub;
    }

    // Load existing profile or generate one if missing (e.g. older install).
    final dn = await _storage.read(AppConstants.secureStorageDisplayName);
    final ph = await _storage.read(AppConstants.secureStoragePhone);
    final ib = await _storage.read(AppConstants.secureStorageIban);

    if (dn != null && ph != null && ib != null) {
      return (
        publicKey: publicKey,
        profile: WalletProfile(displayName: dn, phone: ph, iban: ib),
      );
    }

    final generated = ProfileGenerator().generate();
    await _storage.write(AppConstants.secureStorageDisplayName, generated.displayName);
    await _storage.write(AppConstants.secureStoragePhone, generated.phone);
    await _storage.write(AppConstants.secureStorageIban, generated.iban);
    return (publicKey: publicKey, profile: generated);
  }

  /// Last balance persisted from a successful remote fetch. Returns null if
  /// the app has never been online with this key.
  Future<WalletModel?> loadCached(String publicKey) async {
    final cached = await _local.loadCached(publicKey);
    if (cached == null) return null;
    final profile = await _readStoredProfile();
    if (profile == null) return cached;
    return WalletModel(
      id: cached.id,
      publicKey: cached.publicKey,
      balance: cached.balance,
      profile: profile,
    );
  }

  Future<Result<WalletModel>> initializeWallet({String? deviceId}) async {
    try {
      await _remote.ensureSignedIn();
      final (:publicKey, :profile) = await ensureKeyPair();
      final wallet = await _remote.upsertWallet(
        publicKey: publicKey,
        profile: profile,
        deviceId: deviceId,
      );
      await _local.cacheBalance(wallet.publicKey, wallet.balance);
      // Return a model with the locally-stored profile (remote row may lag).
      return Success(
        WalletModel(
          id: wallet.id,
          publicKey: wallet.publicKey,
          balance: wallet.balance,
          profile: wallet.profile ?? profile,
        ),
      );
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  /// Sum of outgoing pending-sync transactions for this wallet's public key.
  Future<double> pendingOutgoing(String publicKey) =>
      _pendingTx.pendingOutgoingSum(publicKey);

  Future<Result<WalletModel>> refresh(String publicKey) async {
    try {
      final wallet = await _remote.fetchByPublicKey(publicKey);
      if (wallet == null) {
        return const Failure(
          ErrorModel(message: 'Wallet not found', code: 'NOT_FOUND'),
        );
      }
      await _local.cacheBalance(wallet.publicKey, wallet.balance);
      if (wallet.profile != null) return Success(wallet);
      final profile = await _readStoredProfile();
      if (profile == null) return Success(wallet);
      return Success(
        WalletModel(
          id: wallet.id,
          publicKey: wallet.publicKey,
          balance: wallet.balance,
          profile: profile,
        ),
      );
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }

  Future<WalletProfile?> _readStoredProfile() async {
    final dn = await _storage.read(AppConstants.secureStorageDisplayName);
    final ph = await _storage.read(AppConstants.secureStoragePhone);
    final ib = await _storage.read(AppConstants.secureStorageIban);
    if (dn == null || ph == null || ib == null) return null;
    return WalletProfile(displayName: dn, phone: ph, iban: ib);
  }
}
