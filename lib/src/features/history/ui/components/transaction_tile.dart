import 'package:flutter/material.dart';

import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.tx,
    required this.myPublicKey,
  });

  final TransactionModel tx;
  final String myPublicKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final direction = tx.directionFor(myPublicKey);
    final isSent = direction == TxDirection.sent;
    final sign = isSent ? '-' : '+';
    final color = switch (tx.status) {
      TxStatus.rejected => theme.colorScheme.error,
      TxStatus.pending => theme.colorScheme.tertiary,
      TxStatus.confirmed =>
        isSent ? theme.colorScheme.error : Colors.green.shade700,
    };
    final icon = switch (tx.status) {
      TxStatus.rejected => Icons.error_outline,
      TxStatus.pending => Icons.schedule,
      TxStatus.confirmed => isSent ? Icons.arrow_upward : Icons.arrow_downward,
    };
    final subtitle = _subtitle(tx, myPublicKey);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        '${isSent ? 'Sent' : 'Received'} '
        '${tx.amount.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall,
      ),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(
        '$sign${tx.amount.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  String _subtitle(TransactionModel tx, String myPublicKey) {
    final counterparty = tx.counterpartyFor(myPublicKey);
    final shortKey = counterparty.length > 12
        ? '${counterparty.substring(0, 8)}…${counterparty.substring(counterparty.length - 4)}'
        : counterparty;
    final when = tx.syncedAt ?? tx.clientCreatedAt;
    final stamp = '${when.toLocal()}'.split('.').first;
    final tag = switch (tx.status) {
      TxStatus.pending => 'Pending sync · ',
      TxStatus.rejected => 'Rejected · ',
      TxStatus.confirmed => '',
    };
    return '$tag$shortKey\n$stamp';
  }
}
