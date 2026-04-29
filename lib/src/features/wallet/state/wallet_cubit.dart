import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/network/result.dart';
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
        final adj = await _repository.pendingBalanceAdjustment(data.publicKey);
        emit(WalletReady(data, pendingAdjustment: adj));
      case Failure(:final error):
        emit(WalletFailure(error.message));
    }
  }

  Future<void> refresh() async {
    final current = state;
    if (current is! WalletReady) return;

    final result = await _repository.refresh(current.wallet.publicKey);
    final adj = await _repository.pendingBalanceAdjustment(
      current.wallet.publicKey,
    );

    switch (result) {
      case Success(:final data):
        emit(WalletReady(data, pendingAdjustment: adj));
      case Failure():
        // Keep the current wallet data instead of destroying the UI with
        // WalletFailure. Mark it as stale so the UI can show an indicator.
        emit(WalletReady(
          current.wallet,
          stale: true,
          pendingAdjustment: adj,
        ));
    }
  }
}
