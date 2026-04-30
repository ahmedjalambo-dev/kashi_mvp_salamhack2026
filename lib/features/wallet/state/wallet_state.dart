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
  final double pendingOut;
  const WalletReady(this.wallet, {this.pendingOut = 0.0});

  double get availableBalance => wallet.balance - pendingOut;

  @override
  List<Object?> get props => [wallet, pendingOut];
}

class WalletFailure extends WalletState {
  final String message;
  const WalletFailure(this.message);
  @override
  List<Object?> get props => [message];
}
