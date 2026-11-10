import 'package:flutter/widgets.dart';

import '../components/cards.dart';
import '../components/chrome.dart';
import '../components/detail.dart';
import '../components/inputs.dart';
import '../design/dsl.dart';
import '../design/tokens.dart';

/// Figma frames `Deals` (7:307) and `Deals · Dark` (64:789).
///
/// The dark frame has identical geometry, so it is the same widget with the
/// dark token set. The `Recently won` card (7:379) sits at y=830 and is fully
/// covered by the BottomNav in the file, so it contributes no pixels and is
/// not rendered here.
class DealsScreen extends StatelessWidget {
  const DealsScreen({super.key, this.colors = DsColors.light});

  final DsColors colors;

  static const _deals = <DsDealData>[
    DsDealData(
      title: 'Platform renewal',
      account: 'Acme Studio',
      amount: r'$24,500',
      stage: DsStatus.proposal,
      stageLabel: 'Proposal',
      stageChipWidth: 80,
      close: 'Close Oct 30',
    ),
    DsDealData(
      title: 'Annual seat expansion',
      account: 'Northwind Labs',
      amount: r'$18,200',
      stage: DsStatus.pending,
      stageLabel: 'Negotiation',
      stageChipWidth: 98,
      close: 'Close Nov 04',
    ),
    DsDealData(
      title: 'Onboarding package',
      account: 'BrightPath Co',
      amount: r'$9,800',
      stage: DsStatus.active,
      stageLabel: 'Qualified',
      stageChipWidth: 82,
      close: 'Close Nov 12',
    ),
    DsDealData(
      title: 'Website redesign',
      account: 'Vertex Retail',
      amount: r'$12,000',
      stage: DsStatus.proposal,
      stageLabel: 'Proposal',
      stageChipWidth: 80,
      close: 'Close Nov 18',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final c = colors;

    return DsFrame(
      background: c.bg,
      children: [
        Positioned(left: 0, top: 0, child: DsStatusBar(colors: c)),
        Positioned(
          left: 24,
          top: 44,
          child: Text('Deals', style: DsType.h1.copyWith(color: c.fg)),
        ),
        Positioned(
          left: 24,
          top: 76,
          child: Text(
            '12 open · \$184K pipeline',
            maxLines: 1,
            softWrap: false,
            style: DsType.caption.copyWith(color: c.mutedFg),
          ),
        ),
        Positioned(
          left: 284,
          top: 44,
          child: DsBellButton(colors: c, count: 2),
        ),
        Positioned(
          left: 340,
          top: 44,
          child: DsIconButtonGhost(colors: c, icon: 'more_vertical'),
        ),

        Positioned(
          left: 24,
          top: 116,
          child: DsDealsSummary(
            colors: c,
            left: DsDealMetric(
              label: 'Open pipeline',
              value: r'$184K',
              sub: '+8.2% this month',
            ),
            right: DsDealMetric(
              label: 'Won this month',
              value: r'$42K',
              sub: '6 deals closed',
            ),
          ),
        ),

        Positioned(
          left: 24,
          top: 228,
          child: DsFilterChipBar(
            colors: c,
            labels: const ['All', 'Qualified', 'Proposal', 'Negotiation'],
            selectedIndex: 0,
          ),
        ),

        Positioned(
          left: 24,
          top: 282,
          child: Text('Open deals', style: DsType.h3.copyWith(color: c.fg)),
        ),
        for (final (i, deal) in _deals.indexed)
          Positioned(
            left: 24,
            top: 318 + 117.0 * i,
            child: DsDealCard(colors: c, data: deal),
          ),

        Positioned(
          left: 332,
          top: 728,
          child: DsFab(colors: c),
        ),

        Positioned(
          left: 24,
          top: 794,
          child: Text('Recently won', style: DsType.h3.copyWith(color: c.fg)),
        ),

        Positioned(
          left: 0,
          top: 820,
          child: DsBottomNav(colors: c, active: DsNavTab.deals),
        ),
      ],
    );
  }
}
