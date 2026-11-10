import 'package:flutter/widgets.dart';

import '../components/cards.dart';
import '../components/chrome.dart';
import '../components/detail.dart';
import '../design/dsl.dart';
import '../design/tokens.dart';

/// Figma frame `Customer detail` (7:120).
///
/// Every offset below is the literal `get_metadata` value for its node; the
/// `State` marker for the active stage ships as an SVG asset in the file, so it
/// is used verbatim rather than reconstructed.
class CustomerDetailScreen extends StatelessWidget {
  const CustomerDetailScreen({super.key, this.colors = DsColors.light});

  final DsColors colors;

  static const _stages = <DsPipelineStageData>[
    DsPipelineStageData(
      name: 'Qualified',
      detail: 'Oct 12',
      value: r'$24,500',
      state: DsStageState.complete,
    ),
    DsPipelineStageData(
      name: 'Proposal',
      detail: 'Due Oct 30',
      value: r'$24,500',
      state: DsStageState.current,
      valueEmphasis: true,
    ),
    DsPipelineStageData(
      name: 'Negotiation',
      detail: 'Next step',
      value: '—',
      state: DsStageState.upcoming,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return DsFrame(
      background: c.bg,
      children: [
        Positioned(left: 0, top: 0, child: DsStatusBar(colors: c)),

        // Navigation row: back button, 16/600 title, overflow menu.
        Positioned(
          left: 12,
          top: 30,
          child: DsIconButtonGhost(colors: c, icon: 'arrow_left'),
        ),
        Positioned(
          left: 68,
          top: 43,
          child: Text('Customer', style: DsType.h3.copyWith(color: c.fg)),
        ),
        Positioned(
          left: 340,
          top: 32,
          child: DsIconButtonGhost(colors: c, icon: 'more_vertical'),
        ),

        // Identity block. The name and company are left-aligned at x = 106 in
        // the file (their text boxes are 155 / 190 wide), so they are not
        // centred under the avatar — reproduced as-is.
        Positioned(
          left: 170,
          top: 96,
          child: Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(DsRadius.full),
            ),
            alignment: Alignment.center,
            child: Text('OM', style: DsType.h2.copyWith(color: c.primaryText)),
          ),
        ),
        Positioned(
          left: 106,
          top: 180,
          child: Text(
            'Olivia Martin',
            maxLines: 1,
            softWrap: false,
            style: DsType.h1.copyWith(color: c.fg),
          ),
        ),
        Positioned(
          left: 106,
          top: 212,
          child: Text(
            'Head of Operations · Acme Studio',
            maxLines: 1,
            softWrap: false,
            style: DsType.caption.copyWith(color: c.mutedFg),
          ),
        ),
        Positioned(
          left: 175,
          top: 238,
          child: DsStatusChip(colors: c, status: DsStatus.active, label: 'Active'),
        ),

        // Quick actions.
        Positioned(
          left: 24,
          top: 286,
          child: DsQuickActionTile(colors: c, icon: 'phone', label: 'Call'),
        ),
        Positioned(
          left: 148,
          top: 286,
          child: DsQuickActionTile(colors: c, icon: 'mail', label: 'Email'),
        ),
        Positioned(
          left: 272,
          top: 286,
          child: DsQuickActionTile(colors: c, icon: 'edit', label: 'Note'),
        ),

        // Customer stats strip.
        Positioned(
          left: 24,
          top: 366,
          child: Container(
            width: 364,
            height: 76,
            decoration: BoxDecoration(
              color: c.card,
              borderRadius: BorderRadius.circular(DsRadius.lg),
              boxShadow: DsShadow.card,
            ),
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(DsRadius.lg),
              border: Border.all(color: c.border),
            ),
            child: Stack(
              children: [
                // 1 × 36 hairlines between the three stats (7:167, 7:171).
                for (final x in const [125.0, 238.0])
                  Positioned(
                    left: x,
                    top: 20,
                    child: Container(width: 1, height: 36, color: c.border),
                  ),
                for (final (i, stat) in const [
                  ('4', 'Open deals'),
                  (r'$24.5K', 'Pipeline'),
                  ('2 days', 'Last contact'),
                ].indexed)
                  Positioned(
                    left: 13.0 + 113 * i,
                    top: 18,
                    child: DsMiniStat(colors: c, value: stat.$1, label: stat.$2),
                  ),
              ],
            ),
          ),
        ),

        Positioned(
          left: 24,
          top: 468,
          child: DsSectionHeader(
            colors: c,
            title: 'Deal pipeline',
            action: 'View deal',
          ),
        ),

        Positioned(
          left: 24,
          top: 500,
          child: DsPipelineCard(colors: c, stages: _stages),
        ),

        Positioned(
          left: 24,
          top: 690,
          child: DsSectionHeader(
            colors: c,
            title: 'Recent notes',
            action: 'Add note',
          ),
        ),
        Positioned(
          left: 24,
          top: 722,
          child: DsNoteCard(
            colors: c,
            note: 'Prefers async updates. Renewal due Nov 15.',
            meta: '2 days ago · Alex Morgan',
          ),
        ),

        Positioned(
          left: 0,
          top: 812,
          child: DsBottomAction(colors: c, label: 'Log activity'),
        ),
      ],
    );
  }
}
