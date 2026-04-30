import 'package:flutter/material.dart';

import '../../../../core/components/transaction_tile.dart';
import '../../data/models/transaction_model.dart';

/// Feature-specific wrapper that maps a [TransactionModel] to the
/// generic [KashiTransactionTile] core component.
class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.tx,
    required this.myPublicKey,
    this.showBottomBorder = true,
  });

  final TransactionModel tx;
  final String myPublicKey;
  final bool showBottomBorder;

  @override
  Widget build(BuildContext context) {
    final direction = tx.directionFor(myPublicKey);
    final isSent = direction == TxDirection.sent;
    final isIncoming = !isSent;

    final icon = switch (tx.status) {
      TxStatus.rejected => Icons.error_outline,
      TxStatus.pending => Icons.schedule,
      TxStatus.confirmed => isSent ? Icons.arrow_upward : Icons.arrow_downward,
    };

    return KashiTransactionTile(
      title: _title(isSent),
      subtitle: _subtitle(),
      amount: tx.amount,
      isIncoming: isIncoming,
      icon: icon,
      showBottomBorder: showBottomBorder,
    );
  }

  String _title(bool isSent) {
    final counterparty = tx.counterpartyFor(myPublicKey);
    final shortKey = counterparty.length > 12
        ? '${counterparty.substring(0, 8)}…${counterparty.substring(counterparty.length - 4)}'
        : counterparty;
    return '${isSent ? 'To' : 'From'} $shortKey';
  }

  String _subtitle() {
    final when = tx.syncedAt ?? tx.clientCreatedAt;
    final stamp = '${when.toLocal()}'.split('.').first;
    return switch (tx.status) {
      TxStatus.pending => 'Pending sync · $stamp',
      TxStatus.rejected => 'Rejected · $stamp',
      TxStatus.confirmed => stamp,
    };
  }
}
