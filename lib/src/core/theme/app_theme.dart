import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Kashi Design System — Colors
// ─────────────────────────────────────────────────────────────────────────────

abstract final class KashiColors {
  // Brand — Olive (Primary)
  static const olive = Color(0xFF2D5F3F);
  static const olive700 = Color(0xFF234B32);
  static const olive300 = Color(0xFF6B9B7C);
  static const olive50 = Color(0xFFEAF2EC);

  // Brand — Terracotta (Secondary)
  static const terracotta = Color(0xFFC76F3F);
  static const terracotta700 = Color(0xFFA4582E);
  static const terracotta50 = Color(0xFFFBEFE6);

  // Brand — Gold (Accent)
  static const gold = Color(0xFFD4A24C);
  static const gold700 = Color(0xFFB0833A);
  static const gold50 = Color(0xFFFBF3E1);

  // Semantic
  static const success = Color(0xFF4CAF50);
  static const successBg = Color(0xFFE8F5E9);
  static const successOnBg = Color(0xFF2E7D32);
  static const warning = Color(0xFFFF9800);
  static const warningBg = Color(0xFFFFF4E5);
  static const warningOnBg = Color(0xFFB86E00);
  static const error = Color(0xFFE53935);
  static const errorBg = Color(0xFFFCEAEA);
  static const errorOnBg = Color(0xFFB71C1C);

  // Neutrals — Light
  static const bgLight = Color(0xFFFAF8F5);
  static const surfaceLight = Color(0xFFFFFFFF);
  static const surface2Light = Color(0xFFF4F1EB);
  static const fgLight = Color(0xFF1A1A1A);
  static const fg2Light = Color(0xFF6B6B6B);
  static const fg3Light = Color(0xFF9A9A9A);
  static const borderLight = Color(0xFFE8E5E0);
  static const borderStrongLight = Color(0xFFD4CFC6);

  // Neutrals — Dark
  static const bgDark = Color(0xFF0F1612);
  static const surfaceDark = Color(0xFF1A2620);
  static const surface2Dark = Color(0xFF243029);
  static const fgDark = Color(0xFFF5F2EC);
  static const fg2Dark = Color(0xFFA9B0AB);
  static const fg3Dark = Color(0xFF6E7670);
  static const borderDark = Color(0xFF2C3A33);
  static const borderStrongDark = Color(0xFF3C4B43);

  // Dark-mode brand overrides
  static const oliveDark = Color(0xFF4A8A65);
  static const olive700Dark = Color(0xFF3D7355);
  static const olive300Dark = Color(0xFF6FAE8A);
  static const olive50Dark = Color(0xFF1F2E26);
  static const terracotta50Dark = Color(0xFF2A1F18);
  static const gold50Dark = Color(0xFF2B2418);
  static const successBgDark = Color(0xFF16291A);
  static const warningBgDark = Color(0xFF2B1F0F);
  static const errorBgDark = Color(0xFF2B1414);
}

// ─────────────────────────────────────────────────────────────────────────────
// Border Radii
// ─────────────────────────────────────────────────────────────────────────────

abstract final class KashiRadii {
  static const double input = 12;
  static const double card = 16;
  static const double button = 24;
  static const double balance = 24;
  static const double pill = 999;

  static final inputBorder = BorderRadius.circular(input);
  static final cardBorder = BorderRadius.circular(card);
  static final buttonBorder = BorderRadius.circular(button);
  static final balanceBorder = BorderRadius.circular(balance);
  static final pillBorder = BorderRadius.circular(pill);
}

// ─────────────────────────────────────────────────────────────────────────────
// Shadows
// ─────────────────────────────────────────────────────────────────────────────

abstract final class KashiShadows {
  // Light
  static const sm = [
    BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x0A1A1A1A)),
  ];
  static const md = [
    BoxShadow(offset: Offset(0, 4), blurRadius: 12, color: Color(0x0F1A1A1A)),
  ];
  static const lg = [
    BoxShadow(offset: Offset(0, 12), blurRadius: 32, color: Color(0x141A1A1A)),
  ];
  static const balance = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x2E2D5F3F)),
  ];

  // Dark
  static const smDark = [
    BoxShadow(offset: Offset(0, 1), blurRadius: 2, color: Color(0x4D000000)),
  ];
  static const mdDark = [
    BoxShadow(offset: Offset(0, 4), blurRadius: 12, color: Color(0x59000000)),
  ];
  static const lgDark = [
    BoxShadow(offset: Offset(0, 12), blurRadius: 32, color: Color(0x73000000)),
  ];
  static const balanceDark = [
    BoxShadow(offset: Offset(0, 8), blurRadius: 24, color: Color(0x80000000)),
  ];
}

// ─────────────────────────────────────────────────────────────────────────────
// Spacing (8px grid)
// ─────────────────────────────────────────────────────────────────────────────

abstract final class KashiSpacing {
  static const double s1 = 4;
  static const double s2 = 8;
  static const double s3 = 12;
  static const double s4 = 16;
  static const double s5 = 20;
  static const double s6 = 24;
  static const double s8 = 32;
  static const double s10 = 40;
  static const double s12 = 48;
  static const double s16 = 64;
  static const double touchMin = 48;
  static const double navHeight = 72;
}

// ─────────────────────────────────────────────────────────────────────────────
// Typography helpers
// ─────────────────────────────────────────────────────────────────────────────

abstract final class KashiTypography {
  /// Tabular-figure style for currency / amounts.
  static TextStyle numeral({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w600,
    Color? color,
  }) {
    return GoogleFonts.inter(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
    );
  }

  /// Monospace style for IBANs and codes.
  static TextStyle mono({
    double fontSize = 13,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
      fontFeatures: const [FontFeature.tabularFigures()],
      letterSpacing: 0.04 * fontSize,
    );
  }

  /// Arabic text style.
  static TextStyle arabic({
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
    Color? color,
  }) {
    return GoogleFonts.ibmPlexSansArabic(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: color,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Theme builder
// ─────────────────────────────────────────────────────────────────────────────

class AppTheme {
  AppTheme._();

  // ── Light ────────────────────────────────────────────────────────────────

  static ThemeData light() {
    final colorScheme = ColorScheme(
      brightness: Brightness.light,
      primary: KashiColors.olive,
      onPrimary: Colors.white,
      primaryContainer: KashiColors.olive50,
      onPrimaryContainer: KashiColors.olive700,
      secondary: KashiColors.terracotta,
      onSecondary: Colors.white,
      secondaryContainer: KashiColors.terracotta50,
      onSecondaryContainer: KashiColors.terracotta700,
      tertiary: KashiColors.gold,
      onTertiary: KashiColors.fgLight,
      tertiaryContainer: KashiColors.gold50,
      onTertiaryContainer: KashiColors.gold700,
      error: KashiColors.error,
      onError: Colors.white,
      errorContainer: KashiColors.errorBg,
      onErrorContainer: KashiColors.errorOnBg,
      surface: KashiColors.surfaceLight,
      onSurface: KashiColors.fgLight,
      onSurfaceVariant: KashiColors.fg2Light,
      surfaceContainerHighest: KashiColors.surface2Light,
      outline: KashiColors.fg3Light,
      outlineVariant: KashiColors.borderLight,
      scrim: const Color(0x800F1612),
    );

    return _buildTheme(colorScheme, Brightness.light);
  }

  // ── Dark ─────────────────────────────────────────────────────────────────

  static ThemeData dark() {
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,
      primary: KashiColors.oliveDark,
      onPrimary: Colors.white,
      primaryContainer: KashiColors.olive50Dark,
      onPrimaryContainer: KashiColors.olive300Dark,
      secondary: KashiColors.terracotta,
      onSecondary: Colors.white,
      secondaryContainer: KashiColors.terracotta50Dark,
      onSecondaryContainer: KashiColors.terracotta700,
      tertiary: KashiColors.gold,
      onTertiary: KashiColors.fgDark,
      tertiaryContainer: KashiColors.gold50Dark,
      onTertiaryContainer: KashiColors.gold700,
      error: KashiColors.error,
      onError: Colors.white,
      errorContainer: KashiColors.errorBgDark,
      onErrorContainer: KashiColors.errorOnBg,
      surface: KashiColors.surfaceDark,
      onSurface: KashiColors.fgDark,
      onSurfaceVariant: KashiColors.fg2Dark,
      surfaceContainerHighest: KashiColors.surface2Dark,
      outline: KashiColors.fg3Dark,
      outlineVariant: KashiColors.borderDark,
      scrim: const Color(0x99000000),
    );

    return _buildTheme(colorScheme, Brightness.dark);
  }

  // ── Shared builder ───────────────────────────────────────────────────────

  static ThemeData _buildTheme(ColorScheme scheme, Brightness brightness) {
    final isLight = brightness == Brightness.light;
    final bg = isLight ? KashiColors.bgLight : KashiColors.bgDark;

    final textTheme = GoogleFonts.interTextTheme(
      TextTheme(
        displayLarge: TextStyle(
          fontSize: 48,
          fontWeight: FontWeight.w700,
          height: 1.1,
          letterSpacing: -0.02 * 48,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.w700,
          height: 1.25,
          letterSpacing: -0.01 * 32,
        ),
        headlineMedium: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
        headlineSmall: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.25,
        ),
        bodyLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w400,
          height: 1.5,
        ),
        bodyMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        bodySmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
          letterSpacing: 0.02 * 12,
        ),
        labelLarge: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.5,
        ),
        labelMedium: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          height: 1.4,
        ),
        labelSmall: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          height: 1.3,
          letterSpacing: 0.02 * 12,
        ),
      ),
    ).apply(bodyColor: scheme.onSurface, displayColor: scheme.onSurface);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: bg,
      textTheme: textTheme,

      // AppBar
      appBarTheme: AppBarTheme(
        backgroundColor: bg,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: textTheme.headlineSmall?.copyWith(
          color: scheme.onSurface,
        ),
      ),

      // Cards
      cardTheme: CardThemeData(
        color: scheme.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: KashiRadii.cardBorder),
      ),

      // Filled buttons
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          minimumSize: const Size.fromHeight(KashiSpacing.touchMin),
          shape: RoundedRectangleBorder(borderRadius: KashiRadii.buttonBorder),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Elevated buttons
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size.fromHeight(KashiSpacing.touchMin),
          shape: RoundedRectangleBorder(borderRadius: KashiRadii.buttonBorder),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Outlined buttons
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: scheme.onSurface,
          minimumSize: const Size.fromHeight(KashiSpacing.touchMin),
          shape: RoundedRectangleBorder(borderRadius: KashiRadii.buttonBorder),
          side: BorderSide(
            color: isLight
                ? KashiColors.borderStrongLight
                : KashiColors.borderStrongDark,
          ),
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Text buttons (ghost)
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: scheme.primary,
          textStyle: textTheme.labelLarge,
        ),
      ),

      // Input decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: KashiSpacing.s4,
          vertical: KashiSpacing.s3,
        ),
        border: OutlineInputBorder(
          borderRadius: KashiRadii.inputBorder,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: KashiRadii.inputBorder,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: KashiRadii.inputBorder,
          borderSide: BorderSide(color: scheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: KashiRadii.inputBorder,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: KashiRadii.inputBorder,
          borderSide: BorderSide(color: scheme.error, width: 1.5),
        ),
        hintStyle: textTheme.bodyLarge?.copyWith(color: scheme.outline),
        labelStyle: textTheme.bodyMedium?.copyWith(
          color: scheme.onSurfaceVariant,
        ),
      ),

      // Dividers
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 0,
      ),

      // Bottom nav
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: scheme.surface.withAlpha(217), // ~85% opacity
        selectedItemColor: scheme.primary,
        unselectedItemColor: scheme.onSurfaceVariant,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
