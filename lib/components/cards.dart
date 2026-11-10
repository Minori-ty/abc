import 'package:flutter/widgets.dart';

import '../design/tokens.dart';
import 'icons.dart';

/// Avatar/40 — 40 circle, primarySoft fill, 13/600 initials.
class DsAvatar extends StatelessWidget {
  const DsAvatar({super.key, required this.colors, required this.initials});

  final DsColors colors;
  final String initials;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: colors.primarySoft,
        borderRadius: BorderRadius.circular(DsRadius.full),
      ),
      alignment: Alignment.center,
      child: Text(
        initials,
        style: DsType.label.copyWith(color: colors.primaryText),
      ),
    );
  }
}

/// CustomerRow — 364 × 64 card: avatar + two-line info + chevron.
class DsCustomerRow extends StatelessWidget {
  const DsCustomerRow({
    super.key,
    required this.colors,
    required this.initials,
    required this.name,
    required this.company,
    this.width = 364,
    this.onTap,
  });

  final DsColors colors;
  final String initials;
  final String name;
  final String company;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 64,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(DsRadius.md)),
      foregroundDecoration: BoxDecoration(borderRadius: BorderRadius.circular(DsRadius.md), border: Border.all(color: colors.border)),
        child: Row(
          children: [
            DsAvatar(colors: colors, initials: initials),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: DsType.bodyStrong.copyWith(color: colors.fg),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    company,
                    maxLines: 1,
                    overflow: TextOverflow.clip,
                    style: DsType.caption.copyWith(color: colors.mutedFg),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DsGlyph('chevron_right', color: colors.mutedFg, size: 20),
          ],
        ),
      ),
    );
  }
}

/// SectionHeader — 364 × 24, H3 title left, 12/600 link right.
class DsSectionHeader extends StatelessWidget {
  const DsSectionHeader({
    super.key,
    required this.colors,
    required this.title,
    this.action,
    this.width = 364,
    this.onAction,
  });

  final DsColors colors;
  final String title;
  final String? action;
  final double width;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 24,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: DsType.h3.copyWith(color: colors.fg)),
          if (action != null)
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: DsType.captionStrong.copyWith(color: colors.primary),
              ),
            ),
        ],
      ),
    );
  }
}

/// StatCard — 176 × 142: icon tile + delta, 26 number, caption label.
class DsStatCard extends StatelessWidget {
  const DsStatCard({
    super.key,
    required this.colors,
    required this.icon,
    required this.value,
    required this.label,
    required this.delta,
    this.deltaColor,
    this.iconTileColor,
    this.iconColor,
    this.width = 176,
  });

  final DsColors colors;
  final String icon;
  final String value;
  final String label;
  final String delta;
  final Color? deltaColor;
  final Color? iconTileColor;

  /// Glyph colour; the file uses `primary` for the customer tile and `accent`
  /// for the revenue tile.
  final Color? iconColor;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 142,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(DsRadius.lg), boxShadow: DsShadow.card),
      foregroundDecoration: BoxDecoration(borderRadius: BorderRadius.circular(DsRadius.lg), border: Border.all(color: colors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 36,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: iconTileColor ?? colors.primarySoft,
                    borderRadius: BorderRadius.circular(DsRadius.md),
                  ),
                  alignment: Alignment.center,
                  child: DsGlyph(icon, color: iconColor ?? colors.primary, size: 20),
                ),
                Text(
                  delta,
                  style: DsType.captionStrong
                      .copyWith(color: deltaColor ?? colors.accentText),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(value, style: DsType.number.copyWith(color: colors.fg)),
          const SizedBox(height: 12),
          Text(label, style: DsType.caption.copyWith(color: colors.mutedFg)),
        ],
      ),
    );
  }
}

/// FollowUpCard — 364 × 70: accent icon tile, two-line copy, chevron.
class DsFollowUpCard extends StatelessWidget {
  const DsFollowUpCard({
    super.key,
    required this.colors,
    required this.title,
    required this.subtitle,
    this.icon = 'clock',
    this.width = 364,
    this.height = 70,
    this.onTap,
  });

  final DsColors colors;
  final String title;
  final String subtitle;
  final String icon;
  final double width;
  final double height;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: const EdgeInsets.only(left: 17, top: 15, right: 17, bottom: 15),
        decoration: BoxDecoration(color: colors.card, borderRadius: BorderRadius.circular(DsRadius.lg), boxShadow: DsShadow.card),
      foregroundDecoration: BoxDecoration(borderRadius: BorderRadius.circular(DsRadius.lg), border: Border.all(color: colors.border)),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.accentSoft,
                borderRadius: BorderRadius.circular(DsRadius.md),
              ),
              alignment: Alignment.center,
              child: DsGlyph(icon, color: colors.accent, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: DsType.bodyStrong.copyWith(color: colors.fg)),
                  const SizedBox(height: 2),
                  Text(subtitle,
                      style: DsType.caption.copyWith(color: colors.mutedFg)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DsGlyph('chevron_right', color: colors.mutedFg, size: 20),
          ],
        ),
      ),
    );
  }
}

enum DsStatus {
  active,
  pending,
  isNew,

  /// Deal-stage chip in the primary colour (Figma `Chip/Proposal`, 7:351).
  proposal,
}

/// StatusChip — h25 pill: 6px dot + 12/600 label.
class DsStatusChip extends StatelessWidget {
  const DsStatusChip({
    super.key,
    required this.colors,
    required this.status,
    required this.label,
    this.width,
    this.padding = 8,
  });

  final DsColors colors;
  final DsStatus status;
  final String label;

  /// Pins the pill width to the value measured in Figma.
  final double? width;

  /// Horizontal inset of the dot; the deal chips use 9, `Active` uses 8.
  final double padding;

  Color get _semantic => switch (status) {
        DsStatus.active => colors.accentText,
        DsStatus.pending => colors.warningText,
        DsStatus.isNew => colors.primaryText,
        DsStatus.proposal => colors.primary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 25,
      padding: EdgeInsets.symmetric(horizontal: padding, vertical: 4),
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(DsRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: _semantic,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 4),
          Text(label, style: DsType.captionStrong.copyWith(color: _semantic)),
        ],
      ),
    );
  }
}
