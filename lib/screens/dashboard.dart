import 'package:flutter/widgets.dart';

import '../components/cards.dart';
import '../components/chrome.dart';
import '../components/icons.dart';
import '../design/dsl.dart';
import '../design/tokens.dart';

/// Figma frames `Dashboard` (5:2) and `Dashboard · Dark` (64:672).
///
/// The dark frame is not a pure recolour: its FocusCard grows to 131 and the
/// `View tasks` pill to 44 (`64:694`), so everything below the card shifts
/// down by `pillHeight - 31`.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
    this.colors = DsColors.light,
    this.pillHeight = 31,
  });

  final DsColors colors;

  /// Height of the `View tasks` pill: 31 in 5:2, 44 in 64:672.
  final double pillHeight;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final shift = pillHeight - 31;
    return DsFrame(
      background: c.bg,
      children: [
        Positioned(left: 0, top: 0, child: DsStatusBar(colors: c)),

        Positioned(
          left: 24,
          top: 44,
          child: Text('Good morning, Alex',
              style: DsType.caption.copyWith(color: c.mutedFg)),
        ),
        Positioned(
          left: 24,
          top: 62,
          child: Text('Dashboard', style: DsType.h1.copyWith(color: c.fg)),
        ),

        Positioned(
          left: 284,
          top: 48,
          child: DsBellButton(colors: c, count: 2),
        ),
        Positioned(
          left: 340,
          top: 48,
          child: DsIconButtonGhost(colors: c, icon: 'more_vertical'),
        ),

        Positioned(
          left: 24,
          top: 124,
          child: DsStatCard(
            colors: c,
            icon: 'users',
            delta: '+12.4%',
            value: '1,284',
            label: 'Total customers',
          ),
        ),
        Positioned(
          left: 212,
          top: 124,
          child: DsStatCard(
            colors: c,
            icon: 'dollar',
            iconTileColor: c.accentSoft,
            iconColor: c.accent,
            delta: '+8.2%',
            value: r'$184K',
            label: 'Pipeline value',
          ),
        ),

        // FocusCard — 364 × 118, primary fill.
        Positioned(
          left: 24,
          top: 286,
          child: Container(
            width: 364,
            height: 118 + shift,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(DsRadius.lg),
              boxShadow: DsShadow.card,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("TODAY'S FOCUS",
                    style: DsType.captionStrong.copyWith(color: c.onPrimary)),
                const SizedBox(height: 8),
                Text('3 follow-ups need your attention',
                    style: DsType.h3.copyWith(color: c.onPrimary)),
                const SizedBox(height: 8),
                Container(
                  height: pillHeight,
                  padding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: (pillHeight - 17) / 2,
                  ),
                  decoration: BoxDecoration(
                    // Light: white pill / primaryText label; dark: the pill
                    // inverts to the onPrimary ink (64:694).
                    color: c.onPrimary,
                    borderRadius: BorderRadius.circular(DsRadius.full),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('View tasks',
                          style: DsType.captionStrong
                              .copyWith(color: c.primaryText)),
                      const SizedBox(width: 6),
                      DsGlyph('chevron_right', color: c.primary, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          left: 24,
          top: 412 + shift,
          child: DsSectionHeader(
            colors: c,
            title: 'Recent activity',
            action: 'See all',
          ),
        ),

        // ActivityFeed — 364 × 187.
        Positioned(
          left: 24,
          top: 448 + shift,
          child: Container(
            width: 364,
            height: 187,
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(DsRadius.lg), boxShadow: DsShadow.card),
      foregroundDecoration: BoxDecoration(borderRadius: BorderRadius.circular(DsRadius.lg), border: Border.all(color: c.border)),
            child: Padding(
              // Activity/0..2 sit at x=7 inside the 364-wide feed (node
              // 8:375), so the rows are inset 7 and then padded 10 of their
              // own — icon lands at 41, text at 87, time right edge at 371.
              padding: const EdgeInsets.symmetric(horizontal: 7),
              child: Column(
                children: [
                  const SizedBox(height: 7),
                  _ActivityRow(
                    colors: c,
                    icon: 'trending_up',
                    iconBg: c.accentSoft,
                    iconColor: c.accent,
                    headline: 'Deal moved to Proposal',
                    meta: 'Olivia Martin · Acme Studio',
                    time: '12 min ago',
                  ),
                  _Divider(colors: c),
                  _ActivityRow(
                    colors: c,
                    icon: 'mail',
                    iconBg: c.primarySoft,
                    iconColor: c.primary,
                    headline: 'Email sent to Liam Chen',
                    meta: 'Northwind Labs · follow-up',
                    time: '1 hr ago',
                  ),
                  _Divider(colors: c),
                  _ActivityRow(
                    colors: c,
                    icon: 'phone',
                    iconBg: c.muted,
                    iconColor: c.mutedFg,
                    headline: 'Call logged with Sofia Reyes',
                    meta: 'BrightPath Co · 8 min call',
                    time: '3 hrs ago',
                  ),
                ],
              ),
            ),
          ),
        ),

        // MonthlyTarget — 364 × 62.
        Positioned(
          left: 24,
          top: 690 + shift,
          child: Container(
            width: 364,
            height: 62,
            decoration: BoxDecoration(color: c.card, borderRadius: BorderRadius.circular(DsRadius.lg), boxShadow: DsShadow.card),
      foregroundDecoration: BoxDecoration(borderRadius: BorderRadius.circular(DsRadius.lg), border: Border.all(color: c.border)),
            child: Stack(
              children: [
                Positioned(
                  left: 17,
                  top: 11.5,
                  child: Text('Monthly target',
                      style: DsType.bodyStrong.copyWith(color: c.fg)),
                ),
                Positioned(
                  right: 17,
                  top: 11.5,
                  child: Text('72%',
                      style: DsType.bodyStrong.copyWith(color: c.accentText)),
                ),
                Positioned(
                  left: 17,
                  top: 37,
                  child: Container(
                    width: 332,
                    height: 8,
                    decoration: BoxDecoration(
                      color: c.muted,
                      borderRadius: BorderRadius.circular(DsRadius.full),
                    ),
                  ),
                ),
                Positioned(
                  left: 17,
                  top: 37,
                  child: Container(
                    width: 239,
                    height: 8,
                    decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(DsRadius.full),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        Positioned(
          left: 0,
          top: 820,
          child: DsBottomNav(colors: c, active: DsNavTab.home),
        ),
      ],
    );
  }
}

class _ActivityRow extends StatelessWidget {
  const _ActivityRow({
    required this.colors,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.headline,
    required this.meta,
    required this.time,
  });

  final DsColors colors;
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String headline;
  final String meta;
  final String time;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 57,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: iconBg,
                borderRadius: BorderRadius.circular(DsRadius.md),
              ),
              alignment: Alignment.center,
              child: DsGlyph(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(headline,
                      maxLines: 1,
                      style: DsType.bodyStrong.copyWith(color: colors.fg)),
                  const SizedBox(height: 1),
                  Text(meta,
                      maxLines: 1,
                      style: DsType.caption.copyWith(color: colors.mutedFg)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(time, style: DsType.caption.copyWith(color: colors.mutedFg)),
          ],
        ),
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider({required this.colors});

  final DsColors colors;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      color: colors.border,
    );
  }
}
