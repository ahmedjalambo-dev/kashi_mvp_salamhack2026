import 'package:equatable/equatable.dart';

import '../data/models/wallet_model.dart';

sealed class WalletState extends Equatable {
  const WalletState();
  @override
  List<Object?> get props => [];
}

class WalletInitial extends WalletState {
  const WalletInitial();
}

class WalletLoading extends WalletState {
  const WalletLoading();
}

class WalletReady extends WalletState {
  final WalletModel wallet;

  /// Whether the balance may be stale (e.g. last refresh failed due to
  /// no connectivity). The UI can show a subtle indicator.
  final bool stale;

  /// Local adjustment based on pending (not-yet-synced) transactions.
  /// Positive means net incoming pending, negative means net outgoing.
  /// Display balance as `wallet.balance + pendingAdjustment`.
  final double pendingAdjustment;

  const WalletReady(
    this.wallet, {
    this.stale = false,
    this.pendingAdjustment = 0,
  });

  @override
  List<Object?> get props => [wallet, stale, pendingAdjustment];
}

class WalletFailure extends WalletState {
  final String message;
  const WalletFailure(this.message);
  @override
  List<Object?> get props => [message];
}
