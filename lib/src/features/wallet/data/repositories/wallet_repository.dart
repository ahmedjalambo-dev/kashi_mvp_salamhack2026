import '../../../../core/constants/app_constants.dart';
import '../../../../core/crypto/ecdsa_signer.dart';
import '../../../../core/network/error_handler.dart';
import '../../../../core/network/error_model.dart';
import '../../../../core/network/result.dart';
import '../../../../core/services/secure_storage.dart';
import '../../../receive/data/services/pending_tx_local_service.dart';
import '../models/wallet_model.dart';
import '../services/wallet_remote_service.dart';

class WalletRepository {
  WalletRepository({
    required WalletRemoteService remote,
    required SecureStorage secureStorage,
    required EcdsaSigner signer,
    required ErrorHandler errors,
    required PendingTxLocalService pendingTx,
  })  : _remote = remote,
        _storage = secureStorage,
        _signer = signer,
        _errors = errors,
        _pendingTx = pendingTx;

  final WalletRemoteService _remote;
  final SecureStorage _storage;
  final EcdsaSigner _signer;
  final ErrorHandler _errors;
  final PendingTxLocalService _pendingTx;

  static const _pubKeyStorageKey =
      '${AppConstants.secureStoragePrivateKey}.pub';

  /// Returns the public key, generating + persisting a new key pair if needed.
  Future<String> ensureKeyPair() async {
    final priv = await _storage.read(AppConstants.secureStoragePrivateKey);
    final pub = await _storage.read(_pubKeyStorageKey);
    if (priv != null && pub != null) return pub;

    final pair = _signer.generateKeyPair();
    await _storage.write(
      AppConstants.secureStoragePrivateKey,
      pair.privateKeyBase64,
    );
    await _storage.write(_pubKeyStorageKey, pair.publicKeyBase64);
    return pair.publicKeyBase64;
  }

  Future<Result<WalletModel>> initializeWallet({String? deviceId}) async {
    try {
      await _remote.ensureSignedIn();
      final publicKey = await ensureKeyPair();
      final wallet = await _remote.upsertWallet(
        publicKey: publicKey,
        deviceId: deviceId,
      );
      return Success(wallet);
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
      return Success(wallet);
    } catch (e) {
      return Failure(_errors.map(e));
    }
  }
}
