import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// A single transaction list item following the Kashi Design System.
///
/// Displays a circular icon, title + subtitle, and an aligned amount.
/// Use [isIncoming] to control the color scheme (green for received,
/// terracotta for sent).
class KashiTransactionTile extends StatelessWidget {
  const KashiTransactionTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.isIncoming,
    this.icon,
    this.showBottomBorder = true,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final double amount;
  final bool isIncoming;
  final IconData? icon;
  final bool showBottomBorder;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final iconBg = isIncoming
        ? KashiColors.successBg
        : KashiColors.terracotta50;
    final iconColor = isIncoming
        ? KashiColors.successOnBg
        : KashiColors.terracotta700;
    final amountColor = isIncoming ? KashiColors.successOnBg : scheme.onSurface;
    final sign = isIncoming ? '+' : '−';
    final effectiveIcon =
        icon ?? (isIncoming ? Icons.arrow_downward : Icons.arrow_upward);

    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: KashiSpacing.s4,
          vertical: 14,
        ),
        decoration: BoxDecoration(
          border: showBottomBorder
              ? Border(
                  bottom: BorderSide(color: scheme.outlineVariant, width: 1),
                )
              : null,
        ),
        child: Row(
          children: [
            // Circular icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(effectiveIcon, size: 20, color: iconColor),
            ),

            const SizedBox(width: KashiSpacing.s3),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: scheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                      color: scheme.onSurfaceVariant,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            const SizedBox(width: KashiSpacing.s3),

            // Amount
            Text(
              '$sign ₪ ${_formatAmount(amount)}',
              style: GoogleFonts.inter(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: amountColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatAmount(double value) {
    final parts = value.abs().toStringAsFixed(2).split('.');
    final intPart = parts[0];
    final decPart = parts[1];
    final buffer = StringBuffer();
    for (var i = 0; i < intPart.length; i++) {
      if (i > 0 && (intPart.length - i) % 3 == 0) buffer.write(',');
      buffer.write(intPart[i]);
    }
    return '${buffer.toString()}.$decPart';
  }
}
