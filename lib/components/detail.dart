import 'package:flutter/widgets.dart';

import '../design/tokens.dart';
import 'cards.dart';
import 'icons.dart';

/// QuickActions tile — 116 × 64: 24 icon above a 12/600 label, 6 gap.
/// Figma node 7:151 (`Action/Call`).
class DsQuickActionTile extends StatelessWidget {
  const DsQuickActionTile({
    super.key,
    required this.colors,
    required this.icon,
    required this.label,
    this.width = 116,
    this.height = 64,
    this.onTap,
  });

  final DsColors colors;
  final String icon;
  final String label;
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
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(DsRadius.md),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DsRadius.md),
          border: Border.all(color: colors.border),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DsGlyph(icon, color: colors.primary, size: 24),
            const SizedBox(height: 6),
            Text(label, style: DsType.captionStrong.copyWith(color: colors.fg)),
          ],
        ),
      ),
    );
  }
}

/// MiniStat — 14/600 value over a 12/400 label, 2 gap, centred in 112 × 40.
/// Figma node 7:164 (`Stat/Open deals`).
class DsMiniStat extends StatelessWidget {
  const DsMiniStat({
    super.key,
    required this.colors,
    required this.value,
    required this.label,
    this.width = 112,
  });

  final DsColors colors;
  final String value;
  final String label;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 40,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value, style: DsType.bodyStrong.copyWith(color: colors.fg)),
          const SizedBox(height: 2),
          Text(label, style: DsType.caption.copyWith(color: colors.mutedFg)),
        ],
      ),
    );
  }
}

/// Visual state of a pipeline stage marker.
enum DsStageState { complete, current, upcoming }

class DsPipelineStageData {
  const DsPipelineStageData({
    required this.name,
    required this.detail,
    required this.value,
    required this.state,
    this.valueEmphasis = false,
  });

  final String name;
  final String detail;
  final String value;
  final DsStageState state;

  /// `true` paints the value in the primary colour (the active stage).
  final bool valueEmphasis;
}

/// One 332 × 44 stage row: 24 marker, 12 gap, two-line copy, right value.
/// Figma nodes 7:179 / 7:187 / 7:194.
class DsPipelineStage extends StatelessWidget {
  const DsPipelineStage({
    super.key,
    required this.colors,
    required this.data,
    this.width = 332,
  });

  final DsColors colors;
  final DsPipelineStageData data;
  final double width;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: 44,
      child: Row(
        children: [
          _marker(),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: DsType.bodyStrong.copyWith(
                    color: data.state == DsStageState.upcoming
                        ? colors.mutedFg
                        : colors.fg,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  data.detail,
                  maxLines: 1,
                  softWrap: false,
                  overflow: TextOverflow.clip,
                  style: DsType.caption.copyWith(color: colors.mutedFg),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Text(
            data.value,
            maxLines: 1,
            softWrap: false,
            style: DsType.captionStrong.copyWith(
              color: data.valueEmphasis ? colors.primary : colors.mutedFg,
            ),
          ),
        ],
      ),
    );
  }

  Widget _marker() {
    switch (data.state) {
      case DsStageState.complete:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors.accent,
            borderRadius: BorderRadius.circular(DsRadius.full),
          ),
          alignment: Alignment.center,
          child: DsGlyph('check', color: colors.onPrimary, size: 16),
        );
      case DsStageState.current:
        // The marker ships as an SVG in the file (`state.svg`: primary disc
        // with a 4r white core), so it is used as-is instead of being redrawn.
        return const DsGlyph.raw('state', size: 24);
      case DsStageState.upcoming:
        return Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: colors.muted,
            borderRadius: BorderRadius.circular(DsRadius.full),
          ),
          foregroundDecoration: BoxDecoration(
            borderRadius: BorderRadius.circular(DsRadius.full),
            border: Border.all(color: colors.border),
          ),
        );
    }
  }
}

/// PipelineCard — 364 × 170: three stage rows at 48 step, rails between them.
/// Figma node 7:178.
class DsPipelineCard extends StatelessWidget {
  const DsPipelineCard({
    super.key,
    required this.colors,
    required this.stages,
    this.width = 364,
  });

  final DsColors colors;
  final List<DsPipelineStageData> stages;
  final double width;

  @override
  Widget build(BuildContext context) {
    // Row i sits at 15 + 48i inside the card (1px stroke + 14 padding).
    const firstTop = 15.0;
    const step = 48.0;
    final height = 2 * firstTop + step * stages.length - (step - 44);

    return Container(
      width: width,
      height: height,
      clipBehavior: Clip.none,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(DsRadius.lg),
        boxShadow: DsShadow.card,
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DsRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Connectors are 2 × 28 (nodes 161:902 / 161:903) and run *under*
          // the markers, so they are painted first and the discs cover their
          // ends.
          for (var i = 0; i < stages.length - 1; i++)
            Positioned(
              left: 28,
              top: firstTop + step * i + 32,
              child: Container(
                width: 2,
                height: 28,
                color: stages[i].state == DsStageState.complete
                    ? colors.accent
                    : colors.border,
              ),
            ),
          for (var i = 0; i < stages.length; i++)
            Positioned(
              left: 17,
              top: firstTop + step * i,
              child: DsPipelineStage(colors: colors, data: stages[i]),
            ),
        ],
      ),
    );
  }
}

/// NoteCard — 364 × 68: 14/400 body then 12/400 meta, 4 gap.
/// Figma node 7:203.
class DsNoteCard extends StatelessWidget {
  const DsNoteCard({
    super.key,
    required this.colors,
    required this.note,
    required this.meta,
    this.width = 364,
  });

  final DsColors colors;
  final String note;
  final String meta;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 68,
      padding: const EdgeInsets.only(left: 15, top: 13, right: 15),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(DsRadius.md),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DsRadius.md),
        border: Border.all(color: colors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            note,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: DsType.body.copyWith(color: colors.fg),
          ),
          const SizedBox(height: 4),
          Text(
            meta,
            maxLines: 1,
            softWrap: false,
            overflow: TextOverflow.clip,
            style: DsType.caption.copyWith(color: colors.mutedFg),
          ),
        ],
      ),
    );
  }
}

/// One metric inside [DsDealsSummary] — 12/400 label, 26/600 value, 12/400 sub.
class DsDealMetric {
  const DsDealMetric({
    required this.label,
    required this.value,
    required this.sub,
  });

  final String label;
  final String value;
  final String sub;
}

/// DealsSummary — 364 × 92 primary card holding two metrics side by side.
/// Figma node 7:328; the file has no divider between them.
class DsDealsSummary extends StatelessWidget {
  const DsDealsSummary({
    super.key,
    required this.colors,
    required this.left,
    required this.right,
    this.width = 364,
  });

  final DsColors colors;
  final DsDealMetric left;
  final DsDealMetric right;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 92,
      decoration: BoxDecoration(
        color: colors.primary,
        borderRadius: BorderRadius.circular(DsRadius.lg),
        boxShadow: DsShadow.card,
      ),
      child: Stack(
        children: [
          Positioned(
            left: 18,
            top: 11.5,
            child: _metric(left, width / 2 - 18),
          ),
          Positioned(
            left: width / 2,
            top: 11.5,
            child: _metric(right, width / 2 - 18),
          ),
        ],
      ),
    );
  }

  Widget _metric(DsDealMetric m, double w) {
    return SizedBox(
      width: w,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(m.label, style: DsType.caption.copyWith(color: colors.onPrimary)),
          const SizedBox(height: 2),
          Text(m.value, style: DsType.number.copyWith(color: colors.onPrimary)),
          const SizedBox(height: 2),
          Text(m.sub, style: DsType.caption.copyWith(color: colors.onPrimary)),
        ],
      ),
    );
  }
}

/// Data for one [DsDealCard].
class DsDealData {
  const DsDealData({
    required this.title,
    required this.account,
    required this.amount,
    required this.stage,
    required this.stageLabel,
    required this.stageChipWidth,
    required this.close,
  });

  final String title;
  final String account;
  final String amount;
  final DsStatus stage;
  final String stageLabel;
  final double stageChipWidth;
  final String close;
}

/// DealCard — 364 × 103: title/account + amount, then stage chip + close date.
/// Figma node 7:346.
class DsDealCard extends StatelessWidget {
  const DsDealCard({
    super.key,
    required this.colors,
    required this.data,
    this.width = 364,
    this.onTap,
  });

  final DsColors colors;
  final DsDealData data;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: 103,
        decoration: BoxDecoration(
          color: colors.card,
          borderRadius: BorderRadius.circular(DsRadius.lg),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(DsRadius.lg),
          border: Border.all(color: colors.border),
        ),
        child: Stack(
          children: [
            Positioned(
              left: 17,
              top: 15,
              child: SizedBox(
                width: width - 34,
                height: 40,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            data.title,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.clip,
                            style: DsType.bodyStrong.copyWith(color: colors.fg),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            data.account,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.clip,
                            style: DsType.caption.copyWith(color: colors.mutedFg),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      data.amount,
                      maxLines: 1,
                      softWrap: false,
                      style: DsType.bodyStrong.copyWith(color: colors.accentText),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 17,
              top: 63,
              child: Row(
                children: [
                  DsStatusChip(
                    colors: colors,
                    status: data.stage,
                    label: data.stageLabel,
                    width: data.stageChipWidth,
                    padding: 9,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    data.close,
                    maxLines: 1,
                    softWrap: false,
                    style: DsType.caption.copyWith(color: colors.mutedFg),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder row used by the loading / pull-to-refresh frames — 364 × 64
/// card with a round avatar block, two bars and a chevron block, all in the
/// `muted` token (nodes 10:758 … 10:782).
class DsSkeletonRow extends StatelessWidget {
  const DsSkeletonRow({super.key, required this.colors, this.width = 364});

  final DsColors colors;
  final double width;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 64,
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(DsRadius.lg),
      ),
      foregroundDecoration: BoxDecoration(
        borderRadius: BorderRadius.circular(DsRadius.lg),
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 12,
            top: 12,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: colors.muted,
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            left: 64,
            top: 17,
            child: _block(128, 12, 6),
          ),
          Positioned(
            left: 64,
            top: 37,
            child: _block(92, 10, 5),
          ),
          Positioned(
            left: 336,
            top: 24,
            child: _block(16, 16, 8),
          ),
        ],
      ),
    );
  }

  Widget _block(double w, double h, double r) {
    return Container(
      width: w,
      height: h,
      decoration: BoxDecoration(
        color: colors.muted,
        borderRadius: BorderRadius.circular(r),
      ),
    );
  }
}
