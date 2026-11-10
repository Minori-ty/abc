import 'package:flutter/widgets.dart';

import '../design/tokens.dart';
import 'icons.dart';
import 'inputs.dart';

/// StatusBar from the design (mock OS status bar drawn inside the frame).
/// Node 5:101 / 64:739 — 412 × 28.
class DsStatusBar extends StatelessWidget {
  const DsStatusBar({super.key, required this.colors, this.time = '9:41'});

  final DsColors colors;
  final String time;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: DsFrameSpec.width,
      height: DsFrameSpec.statusBarHeight,
      child: Stack(
        children: [
          Positioned(
            left: 20,
            top: 6,
            child: Text(
              time,
              style: DsType.captionStrong.copyWith(color: colors.fg),
            ),
          ),
          Positioned(
            left: 334,
            top: 7,
            child: DsGlyph('system_icons', color: colors.fg, width: 58, height: 14),
          ),
        ],
      ),
    );
  }
}

enum DsNavTab { home, customers, deals, settings }

/// BottomNav — 412 × 72, four 103-wide items, active item gets a 44×28 pill.
class DsBottomNav extends StatelessWidget {
  const DsBottomNav({
    super.key,
    required this.colors,
    required this.active,
    this.onTap,
  });

  final DsColors colors;
  final DsNavTab active;
  final ValueChanged<DsNavTab>? onTap;

  static const _items = <(DsNavTab, String, String)>[
    (DsNavTab.home, 'Home', 'home'),
    (DsNavTab.customers, 'Customers', 'users'),
    (DsNavTab.deals, 'Deals', 'briefcase'),
    (DsNavTab.settings, 'Settings', 'settings_gear'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: DsFrameSpec.width,
      height: DsFrameSpec.bottomNavHeight,
      decoration: BoxDecoration(color: colors.card),
      foregroundDecoration: BoxDecoration(border: Border.all(color: colors.border)),
      child: Row(
        children: [
          for (final item in _items)
            SizedBox(
              width: 103,
              child: _NavItem(
                colors: colors,
                tab: item.$1,
                label: item.$2,
                icon: item.$3,
                active: item.$1 == active,
                onTap: onTap,
              ),
            ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.colors,
    required this.tab,
    required this.label,
    required this.icon,
    required this.active,
    this.onTap,
  });

  final DsColors colors;
  final DsNavTab tab;
  final String label;
  final String icon;
  final bool active;
  final ValueChanged<DsNavTab>? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap == null ? null : () => onTap!(tab),
      child: SizedBox(
        height: 57,
        child: Stack(
          children: [
            if (active)
              Positioned(
                left: 29.5,
                top: 3,
                child: Container(
                  width: 44,
                  height: 28,
                  decoration: BoxDecoration(
                    color: colors.primarySoft,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  DsGlyph(
                    icon,
                    color: active ? colors.primary : colors.mutedFg,
                    size: 20,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: DsType.captionStrong.copyWith(
                      fontSize: 11,
                      height: 1.2,
                      color: active ? colors.primary : colors.mutedFg,
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
}

/// 48×48 ghost icon button (more-vertical, back, etc).
class DsIconButtonGhost extends StatelessWidget {
  const DsIconButtonGhost({
    super.key,
    required this.colors,
    required this.icon,
    this.size = 48,
    this.iconSize = 24,
    this.color,
    this.onTap,
  });

  final DsColors colors;
  final String icon;
  final double size;
  final double iconSize;
  final Color? color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: size,
        height: size,
        child: Center(
          child: DsGlyph(icon, color: color ?? colors.fg, size: iconSize),
        ),
      ),
    );
  }
}

/// Bell button with the 16px unread badge (badge sits at 24,7 inside 48×48).
///
/// The badge is drawn natively — the file exports it as a two-tone SVG whose
/// ring is the page background, so a token-driven ring is both simpler and
/// correct in both themes.
class DsBellButton extends StatelessWidget {
  const DsBellButton({
    super.key,
    required this.colors,
    this.count = 2,
    this.onTap,
  });

  final DsColors colors;
  final int count;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 48,
        height: 48,
        child: Stack(
          children: [
            Positioned(
              left: 12,
              top: 12,
              child: DsGlyph('bell', color: colors.fg, size: 24),
            ),
            if (count > 0)
              Positioned(
                left: 24,
                top: 7,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: colors.destructive,
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.bg, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$count',
                    style: DsType.captionStrong.copyWith(
                      fontSize: 8,
                      height: 1.0,
                      color: colors.onPrimary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Sticky bottom action bar — 412 × 80, card fill inside a 1px border, one
/// full-width primary button at (25, 16). Figma node 7:206.
class DsBottomAction extends StatelessWidget {
  const DsBottomAction({
    super.key,
    required this.colors,
    required this.label,
    this.onTap,
  });

  final DsColors colors;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    // The file strokes all four sides, so the left/right hairlines land on the
    // frame edges and only the top/bottom ones read as separators.
    return Container(
      width: DsFrameSpec.width,
      height: 80,
      decoration: BoxDecoration(color: colors.card),
      foregroundDecoration: BoxDecoration(
        border: Border.all(color: colors.border),
      ),
      child: Stack(
        children: [
          Positioned(
            left: 25,
            top: 16,
            child: DsButton(colors: colors, label: label, width: 362, onTap: onTap),
          ),
        ],
      ),
    );
  }
}

/// 56×56 primary FAB.
class DsFab extends StatelessWidget {
  const DsFab({super.key, required this.colors, this.icon = 'plus', this.onTap});

  final DsColors colors;
  final String icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: colors.primary,
          borderRadius: BorderRadius.circular(DsRadius.full),
        ),
        child: Center(
          child: DsGlyph(icon, color: colors.onPrimary, size: 24),
        ),
      ),
    );
  }
}

/// Inverted snackbar — 364 × 56, `fg` fill, 12 radius, message + action.
/// Figma node 9:689.
class DsSnackbar extends StatelessWidget {
  const DsSnackbar({
    super.key,
    required this.colors,
    required this.message,
    this.action,
    this.width = 364,
    this.onAction,
  });

  final DsColors colors;
  final String message;
  final String? action;
  final double width;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.fg,
        borderRadius: BorderRadius.circular(DsRadius.md),
        boxShadow: DsShadow.menu,
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              message,
              maxLines: 1,
              softWrap: false,
              overflow: TextOverflow.clip,
              style: DsType.body.copyWith(color: colors.onPrimary),
            ),
          ),
          if (action != null) ...[
            const SizedBox(width: 16),
            GestureDetector(
              onTap: onAction,
              child: Text(
                action!,
                style: DsType.captionStrong.copyWith(color: colors.primarySoft),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
