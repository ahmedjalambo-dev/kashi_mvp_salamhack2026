import 'package:flutter/material.dart';

import '../../data/models/wallet_profile.dart';

class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    required this.profile,
    this.pendingOut = 0.0,
    this.onShowAddress,
  });

  final double balance;
  final double pendingOut;
  final WalletProfile profile;
  final VoidCallback? onShowAddress;

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
            color: Color(0x2E2D5F3F),
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
                color: Colors.white.withAlpha(204),
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
                  color: Colors.white.withAlpha(179),
                ),
              ),
            ],
            const SizedBox(height: 24),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.displayName,
                        style: theme.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.phone,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.white.withAlpha(204),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        profile.iban,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          color: Colors.white.withAlpha(179),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onShowAddress != null)
                  GestureDetector(
                    onTap: onShowAddress,
                    child: Tooltip(
                      message: 'My Address',
                      child: Icon(
                        Icons.qr_code,
                        size: 20,
                        color: Colors.white.withAlpha(204),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
