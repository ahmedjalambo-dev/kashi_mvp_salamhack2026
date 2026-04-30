import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/app_theme.dart';

/// A currency amount input field following the Kashi Design System.
///
/// Features a currency prefix (₪ by default) rendered in JetBrains Mono,
/// numeral text in Inter with tabular figures, and focus/error states
/// matching the design tokens.
class AmountInput extends StatelessWidget {
  const AmountInput({
    super.key,
    this.controller,
    this.label,
    this.hintText = '0.00',
    this.errorText,
    this.currencySymbol = '₪',
    this.onChanged,
    this.enabled = true,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? label;
  final String hintText;
  final String? errorText;
  final String currencySymbol;
  final ValueChanged<String>? onChanged;
  final bool enabled;
  final bool autofocus;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final hasError = errorText != null && errorText!.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (label != null) ...[
          Text(
            label!,
            style: GoogleFonts.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: scheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 6),
        ],

        // Input field with currency prefix
        TextField(
          controller: controller,
          onChanged: onChanged,
          enabled: enabled,
          autofocus: autofocus,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[\d.,]')),
          ],
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: scheme.onSurface,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
          decoration: InputDecoration(
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 8),
              child: Text(
                currencySymbol,
                style: KashiTypography.mono(
                  fontSize: 14,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
            prefixIconConstraints: const BoxConstraints(
              minWidth: 0,
              minHeight: KashiSpacing.touchMin,
            ),
            hintText: hintText,
            hintStyle: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: scheme.outline,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            // Override error styling for the custom focus ring
            errorBorder: OutlineInputBorder(
              borderRadius: KashiRadii.inputBorder,
              borderSide: BorderSide(color: scheme.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: KashiRadii.inputBorder,
              borderSide: BorderSide(color: scheme.error, width: 1.5),
            ),
            // Remove default error text — we show it ourselves below
            errorStyle: const TextStyle(height: 0, fontSize: 0),
            errorText: hasError ? '' : null,
          ),
        ),

        // Error message
        if (hasError) ...[
          const SizedBox(height: 6),
          Row(
            children: [
              Icon(Icons.warning_amber_rounded, size: 14, color: scheme.error),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  errorText!,
                  style: GoogleFonts.inter(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: scheme.error,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
