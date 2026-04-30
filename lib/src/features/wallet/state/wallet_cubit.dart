import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
import '../data/models/wallet_model.dart';
import '../data/repositories/wallet_repository.dart';
import 'wallet_state.dart';

class WalletCubit extends Cubit<WalletState> {
  WalletCubit(this._repository) : super(const WalletInitial());

  final WalletRepository _repository;

  Future<void> initialize() async {
    emit(const WalletLoading());
    final result = await _repository.initializeWallet();
    switch (result) {
      case Success(:final data):
        final pendingOut = await _repository.pendingOutgoing(data.publicKey);
        emit(WalletReady(data, pendingOut: pendingOut));
      case Failure(:final error):
        // Offline-tolerant bootstrap: if a key pair already exists on this
        // device the user has used the app before, so we can still render
        // the wallet shell (with a 0 balance until the next online refresh)
        // and let Send/Receive/History work offline. Only fall through to
        // WalletFailure when there's no cached identity to fall back on.
        try {
          final publicKey = await _repository.ensureKeyPair();
          final pendingOut = await _repository.pendingOutgoing(publicKey);
          emit(
            WalletReady(
              WalletModel(id: 'offline', publicKey: publicKey, balance: 0),
              pendingOut: pendingOut,
            ),
          );
        } catch (_) {
          emit(WalletFailure(error.message));
        }
    }
  }

  Future<void> refresh() async {
    final current = state;
    if (current is! WalletReady) return;
    final result = await _repository.refresh(current.wallet.publicKey);
    switch (result) {
      case Success(:final data):
        final pendingOut = await _repository.pendingOutgoing(data.publicKey);
        emit(WalletReady(data, pendingOut: pendingOut));
      case Failure():
        // Refresh failed (likely offline). Keep the existing WalletReady so
        // the user can keep interacting with cached balance + pending list;
        // the OfflineBanner already communicates the connectivity state.
        // Recompute pendingOut from local storage so the offline-created
        // outgoing transactions still show up immediately.
        final pendingOut = await _repository.pendingOutgoing(
          current.wallet.publicKey,
        );
        emit(WalletReady(current.wallet, pendingOut: pendingOut));
    }
  }
}
