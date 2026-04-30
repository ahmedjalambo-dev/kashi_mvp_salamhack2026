import 'package:flutter/material.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.publicKey,
    this.pendingOut = 0.0,
  });

  final double balance;
  final double pendingOut;
  final String publicKey;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final available = balance - pendingOut;
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Available balance', style: theme.textTheme.labelLarge),
            const SizedBox(height: 8),
            Text(
              available.toStringAsFixed(2),
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            if (pendingOut > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Confirmed: ${balance.toStringAsFixed(2)} · Pending out: ${pendingOut.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Text('Public key', style: theme.textTheme.labelSmall),
            const SizedBox(height: 4),
            SelectableText(
              publicKey,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
