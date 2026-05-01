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
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF2D5F3F), Color(0xFF234B32)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: const [
          BoxShadow(
            color: Color(0x2E2D5F3F), // rgba(45,95,63,0.18)
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Available balance',
              style: theme.textTheme.labelLarge?.copyWith(
                color: Colors.white.withAlpha(204), // ~0.8 opacity
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '₪ ${available.toStringAsFixed(2)}',
              style: theme.textTheme.displaySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (pendingOut > 0) ...[
              const SizedBox(height: 4),
              Text(
                'Confirmed: ₪ ${balance.toStringAsFixed(2)} · Pending out: ₪ ${pendingOut.toStringAsFixed(2)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.white.withAlpha(179), // ~0.7 opacity
                ),
              ),
            ],
            const SizedBox(height: 24),
            Text(
              'Public key',
              style: theme.textTheme.labelSmall?.copyWith(
                color: Colors.white.withAlpha(153), // ~0.6 opacity
              ),
            ),
            const SizedBox(height: 4),
            SelectableText(
              publicKey,
              style: theme.textTheme.bodySmall?.copyWith(
                fontFamily: 'monospace',
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
