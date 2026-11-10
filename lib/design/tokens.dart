import 'package:flutter/widgets.dart';

/// Design tokens extracted from the Figma file `最满意的`
/// (fileKey: VHrGFBHISrJt8uSnkTjwdc, variable set "CRM Tokens").
/// Values are the resolved variable values per mode — never eyeballed.
@immutable
class DsColors {
  const DsColors({
    required this.bg,
    required this.card,
    required this.muted,
    required this.border,
    required this.fg,
    required this.mutedFg,
    required this.primary,
    required this.primaryText,
    required this.primarySoft,
    required this.onPrimary,
    required this.accent,
    required this.accentText,
    required this.accentSoft,
    required this.warning,
    required this.warningText,
    required this.destructive,
    required this.destructiveText,
    required this.destructiveSoft,
    required this.scrim,
    required this.isDark,
  });

  final Color bg;
  final Color card;
  final Color muted;
  final Color border;
  final Color fg;
  final Color mutedFg;
  final Color primary;
  final Color primaryText;
  final Color primarySoft;
  final Color onPrimary;
  final Color accent;
  final Color accentText;
  final Color accentSoft;
  final Color warning;
  final Color warningText;
  final Color destructive;
  final Color destructiveText;
  final Color destructiveSoft;
  final Color scrim;

  /// Whether this mode is the dark one — icon SVGs ship per-mode in the file
  /// (their stroke colours are baked into the asset), so the mode selects the
  /// asset folder instead of recolouring anything.
  final bool isDark;

  static const light = DsColors(
    bg: Color(0xFFF8FAFC),
    card: Color(0xFFFFFFFF),
    muted: Color(0xFFF1F5FD),
    border: Color(0xFFE4ECFC),
    fg: Color(0xFF0F172A),
    mutedFg: Color(0xFF475569),
    primary: Color(0xFF2563EB),
    primaryText: Color(0xFF1D4ED8),
    primarySoft: Color(0xFFDBEAFE),
    onPrimary: Color(0xFFFFFFFF),
    accent: Color(0xFF059669),
    accentText: Color(0xFF047857),
    accentSoft: Color(0xFFD1FAE5),
    warning: Color(0xFFF59E0B),
    warningText: Color(0xFFB45309),
    destructive: Color(0xFFDC2626),
    destructiveText: Color(0xFFB91C1C),
    destructiveSoft: Color(0xFFFEE2E2),
    scrim: Color(0xFF0F172A),
    isDark: false,
  );

  static const dark = DsColors(
    bg: Color(0xFF0B1220),
    card: Color(0xFF111C2E),
    muted: Color(0xFF172437),
    border: Color(0xFF2B3C57),
    fg: Color(0xFFE6EDF8),
    mutedFg: Color(0xFF9FB0C7),
    primary: Color(0xFF60A5FA),
    primaryText: Color(0xFF60A5FA),
    primarySoft: Color(0xFF1B3350),
    onPrimary: Color(0xFF0B1220),
    accent: Color(0xFF34D399),
    accentText: Color(0xFF34D399),
    accentSoft: Color(0xFF12352B),
    warning: Color(0xFFFBBF24),
    warningText: Color(0xFFFBBF24),
    destructive: Color(0xFFF87171),
    destructiveText: Color(0xFFF87171),
    destructiveSoft: Color(0xFF3A1D22),
    scrim: Color(0xFF0B1220),
    isDark: true,
  );
}

/// Typography scale from the "Internal Only Canvas" text styles.
abstract final class DsFont {
  static const poppins = 'Poppins';
  static const openSans = 'Open Sans';
}

abstract final class DsType {
  /// Display/32 — Poppins Bold, 32/38.
  static const display = TextStyle(
    fontFamily: DsFont.poppins,
    fontSize: 32,
    fontWeight: FontWeight.w700,
    height: 38 / 32,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// H1/24 — Poppins SemiBold, 24/30.
  static const h1 = TextStyle(
    fontFamily: DsFont.poppins,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    height: 1.25,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// H2/20 — Poppins, 20/26.
  static const h2 = TextStyle(
    fontFamily: DsFont.poppins,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    height: 1.3,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// H3/16 — Poppins SemiBold, 16/22. Section headers and page titles.
  ///
  /// The file only ever uses `Poppins:SemiBold` (600) — there is no Poppins
  /// Bold anywhere in it, so this must not be w700.
  static const h3 = TextStyle(
    fontFamily: DsFont.poppins,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 22 / 16,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Body/14 — Open Sans Regular, 14/21.
  static const body = TextStyle(
    fontFamily: DsFont.openSans,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// BodyStrong/14 — Open Sans SemiBold, 14/21.
  static const bodyStrong = TextStyle(
    fontFamily: DsFont.openSans,
    fontSize: 14,
    fontWeight: FontWeight.w600,
    height: 1.5,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Label/13 — Open Sans SemiBold, 13/18.
  static const label = TextStyle(
    fontFamily: DsFont.openSans,
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 18 / 13,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Caption/12 — Open Sans Regular, 12/17.
  static const caption = TextStyle(
    fontFamily: DsFont.openSans,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 17 / 12,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// CaptionStrong/12 — Open Sans SemiBold, 12/17.
  static const captionStrong = TextStyle(
    fontFamily: DsFont.openSans,
    fontSize: 12,
    fontWeight: FontWeight.w600,
    height: 17 / 12,
    leadingDistribution: TextLeadingDistribution.even,
  );

  /// Number/26 — Poppins SemiBold, 26/31.
  static const number = TextStyle(
    fontFamily: DsFont.poppins,
    fontSize: 26,
    fontWeight: FontWeight.w600,
    height: 31 / 26,
    leadingDistribution: TextLeadingDistribution.even,
  );
}

abstract final class DsRadius {
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 24.0;
  static const full = 999.0;
}

abstract final class DsSpace {
  static const s1 = 4.0;
  static const s2 = 8.0;
  static const s3 = 12.0;
  static const s4 = 16.0;
  static const s5 = 20.0;
  static const s6 = 24.0;
  static const s8 = 32.0;
  static const s12 = 48.0;
}

abstract final class DsShadow {
  /// Shadow/Card — 0 4 12 rgba(15,23,41,0.06).
  static const card = <BoxShadow>[
    BoxShadow(
      color: Color(0x0F0F1729),
      offset: Offset(0, 4),
      blurRadius: 12,
      spreadRadius: 0,
    ),
  ];

  /// Shadow/Menu — 0 10 28 rgba(15,23,41,0.18).
  static const menu = <BoxShadow>[
    BoxShadow(
      color: Color(0x2E0F1729),
      offset: Offset(0, 10),
      blurRadius: 28,
      spreadRadius: 4,
    ),
  ];

  /// Shadow/Dialog — 0 18 48 rgba(15,23,41,0.24).
  static const dialog = <BoxShadow>[
    BoxShadow(
      color: Color(0x3D0F1729),
      offset: Offset(0, 18),
      blurRadius: 48,
      spreadRadius: 6,
    ),
  ];
}

/// Frame geometry shared by every screen in the design file.
abstract final class DsFrameSpec {
  static const width = 412.0;
  static const height = 892.0;
  static const statusBarHeight = 28.0;
  static const bottomNavHeight = 72.0;
  static const pagePadding = 24.0;
  static const contentWidth = 364.0;
}
