import 'package:equatable/equatable.dart';

import '../data/models/pending_tx_display.dart';

sealed class PendingTxState extends Equatable {
  const PendingTxState();
  @override
  List<Object?> get props => [];
}

class PendingTxLoading extends PendingTxState {
  const PendingTxLoading();
}

class PendingTxLoaded extends PendingTxState {
  final List<PendingTxDisplay> transactions;
  const PendingTxLoaded(this.transactions);
  @override
  List<Object?> get props => [transactions];
}

class PendingTxFailure extends PendingTxState {
  final String message;
  const PendingTxFailure(this.message);
  @override
  List<Object?> get props => [message];
}
