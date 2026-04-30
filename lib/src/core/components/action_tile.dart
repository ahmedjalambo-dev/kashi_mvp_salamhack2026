import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

class ActionTile extends StatelessWidget {
  const ActionTile({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isGoldAccent = false,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isGoldAccent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bgColor = isGoldAccent
        ? (isDark ? KashiColors.gold50Dark : KashiColors.gold50)
        : (isDark ? KashiColors.olive50Dark : KashiColors.olive50);

    final iconColor = isGoldAccent
        ? (isDark ? KashiColors.gold : KashiColors.gold700)
        : (isDark ? KashiColors.olive : KashiColors.olive);

    return Material(
      color: theme.colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: KashiRadii.cardBorder,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: KashiRadii.cardBorder,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: bgColor,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Icon(icon, color: iconColor, size: 20),
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurface,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
