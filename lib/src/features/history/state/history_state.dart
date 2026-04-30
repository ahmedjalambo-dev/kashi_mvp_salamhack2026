import 'package:equatable/equatable.dart';

import '../data/models/transaction_model.dart';

sealed class HistoryState extends Equatable {
  const HistoryState();
  @override
  List<Object?> get props => [];
}

class HistoryInitial extends HistoryState {
  const HistoryInitial();
}

class HistoryLoading extends HistoryState {
  const HistoryLoading();
}

class HistoryReady extends HistoryState {
  final List<TransactionModel> pending;
  final List<TransactionModel> completed;
  final bool refreshing;
  final String? remoteError;

  const HistoryReady({
    required this.pending,
    required this.completed,
    this.refreshing = false,
    this.remoteError,
  });

  HistoryReady copyWith({
    List<TransactionModel>? pending,
    List<TransactionModel>? completed,
    bool? refreshing,
    String? remoteError,
    bool clearRemoteError = false,
  }) {
    return HistoryReady(
      pending: pending ?? this.pending,
      completed: completed ?? this.completed,
      refreshing: refreshing ?? this.refreshing,
      remoteError: clearRemoteError ? null : (remoteError ?? this.remoteError),
    );
  }

  @override
  List<Object?> get props => [pending, completed, refreshing, remoteError];
}
