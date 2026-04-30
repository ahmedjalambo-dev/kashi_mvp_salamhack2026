import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// Premium wallet balance card matching the Kashi Design System.
///
/// Features an olive-to-dark-olive gradient, a subtle gold radial glow,
/// tabular-figure balance rendering, and an IBAN line in JetBrains Mono.
class BalanceCard extends StatelessWidget {
  const BalanceCard({
    super.key,
    required this.balance,
    this.pendingOut = 0.0,
    this.iban,
    this.publicKey,
    this.isOnline = true,
    this.onTap,
  });

  final double balance;
  final double pendingOut;
  final String? iban;
  final String? publicKey;
  final bool isOnline;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final available = balance - pendingOut;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: KashiRadii.balanceBorder,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [KashiColors.olive, KashiColors.olive700],
          ),
          boxShadow: KashiShadows.balance,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Gold radial glow — decorative
            Positioned(
              right: -40,
              top: -40,
              child: Container(
                width: 180,
                height: 180,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Color(0x2ED4A24C), // gold @ 18% opacity
                      Colors.transparent,
                    ],
                    stops: [0.0, 0.7],
                  ),
                ),
              ),
            ),

            // Content
            Padding(
              padding: const EdgeInsets.all(KashiSpacing.s6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top row — label + status chip
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'WALLET BALANCE',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xBFFAF8F5), // 75% opacity
                          letterSpacing: 0.04 * 13,
                        ),
                      ),
                      _StatusChip(isOnline: isOnline),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Balance amount
                  Text(
                    '₪ ${_formatAmount(available)}',
                    style: GoogleFonts.inter(
                      fontSize: 44,
                      fontWeight: FontWeight.w700,
                      color: KashiColors.bgLight,
                      letterSpacing: -0.02 * 44,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),

                  // Pending out indicator
                  if (pendingOut > 0) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Confirmed ₪ ${_formatAmount(balance)} · Pending ₪ ${_formatAmount(pendingOut)}',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: const Color(0x99FAF8F5), // 60% opacity
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  // IBAN or public key
                  if (iban != null)
                    Text(
                      iban!,
                      style: KashiTypography.mono(
                        fontSize: 13,
                        color: const Color(0xCCFAF8F5), // 80% opacity
                      ),
                    )
                  else if (publicKey != null)
                    Text(
                      _truncateKey(publicKey!),
                      style: KashiTypography.mono(
                        fontSize: 13,
                        color: const Color(0xCCFAF8F5),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double value) {
    final parts = value.toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    // Add thousand separators
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '${buffer.toString()}.$decPart';
  }

  static String _truncateKey(String key) {
    if (key.length <= 16) return key;
    return '${key.substring(0, 8)}…${key.substring(key.length - 8)}';
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.isOnline});
  final bool isOnline;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(31), // 12% opacity
        borderRadius: KashiRadii.pillBorder,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? KashiColors.success : KashiColors.terracotta,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            isOnline ? 'Online' : 'Offline',
            style: GoogleFonts.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: KashiColors.bgLight,
            ),
          ),
        ],
      ),
    );
  }
}
