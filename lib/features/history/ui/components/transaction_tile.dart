
import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';

import '../../data/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  const TransactionTile({
    super.key,
    required this.tx,
    required this.myPublicKey,
    this.onDismiss,
  });

  final TransactionModel tx;
  final String myPublicKey;
  final VoidCallback? onDismiss;

  @override
  Widget build(BuildContext context) {
    if (tx.kind == TxKind.request) return _buildRequestTile(context);
    return _buildPaymentTile(context);
  }

  Widget _buildPaymentTile(BuildContext context) {
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
      TxStatus.rejected => LucideIcons.circleAlert,
      TxStatus.pending => LucideIcons.clock,
      TxStatus.confirmed =>
        isSent ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
    };
    final subtitle = _paymentSubtitle(tx, myPublicKey);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        '${isSent ? 'Sent' : 'Received'} '
        '₪ ${tx.amount.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      subtitle: Text(subtitle, maxLines: 2, overflow: TextOverflow.ellipsis),
      trailing: Text(
        '$sign ₪ ${tx.amount.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.bold,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    );
  }

  Widget _buildRequestTile(BuildContext context) {
    final theme = Theme.of(context);
    final now = DateTime.now();
    final expired = tx.isExpired(now);
    final color = expired
        ? theme.colorScheme.error
        : theme.colorScheme.tertiary;
    final stamp = '${tx.clientCreatedAt.toLocal()}'.split('.').first;

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: color.withValues(alpha: 0.12),
        child: Icon(LucideIcons.hourglass, color: color, size: 20),
      ),
      title: Text(
        'Awaiting payment of ₪ ${tx.amount.toStringAsFixed(2)}',
        style: theme.textTheme.titleSmall?.copyWith(
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(stamp),
          if (expired)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Chip(
                label: const Text('Expired'),
                labelStyle: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onError,
                ),
                backgroundColor: theme.colorScheme.error,
                padding: EdgeInsets.zero,
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      trailing: expired && onDismiss != null
          ? IconButton(
              icon: const Icon(LucideIcons.x),
              tooltip: 'Dismiss',
              onPressed: onDismiss,
            )
          : null,
    );
  }

  String _paymentSubtitle(TransactionModel tx, String myPublicKey) {
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
