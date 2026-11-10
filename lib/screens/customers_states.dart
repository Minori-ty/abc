import 'package:flutter/widgets.dart';

import '../components/cards.dart';
import '../components/chrome.dart';
import '../components/detail.dart';
import '../components/inputs.dart';
import '../design/dsl.dart';
import '../design/tokens.dart';
import 'customers.dart';

/// Figma frame `Customers · Loading` (10:652).
///
/// Same header/search/chips as [CustomersScreen] but with five skeleton rows
/// and no section header, bell button or FAB.
class CustomersLoadingScreen extends StatelessWidget {
  const CustomersLoadingScreen({super.key, this.colors = DsColors.light});

  final DsColors colors;

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
          child: Text('Customers', style: DsType.h1.copyWith(color: c.fg)),
        ),
        Positioned(
          left: 24,
          top: 76,
          child: Text(
            'Loading your workspace...',
            maxLines: 1,
            softWrap: false,
            style: DsType.caption.copyWith(color: c.mutedFg),
          ),
        ),
        Positioned(
          left: 340,
          top: 44,
          child: DsIconButtonGhost(colors: c, icon: 'more_vertical'),
        ),
        Positioned(
          left: 24,
          top: 116,
          child: DsSearchField(colors: c, hint: 'Search customers...'),
        ),
        Positioned(
          left: 24,
          top: 178,
          child: DsFilterChipBar(
            colors: c,
            labels: const ['All', 'Active', 'Pending', 'New'],
            selectedIndex: 0,
          ),
        ),
        for (var i = 0; i < 5; i++)
          Positioned(
            left: 24,
            top: 232 + 74.0 * i,
            child: DsSkeletonRow(colors: c),
          ),
        Positioned(
          left: 0,
          top: 820,
          child: DsBottomNav(colors: c, active: DsNavTab.customers),
        ),
      ],
    );
  }
}

/// Figma frame `Customers · Delete success` (9:583).
///
/// The list has lost its first record (4 rows instead of 5), which also pulls
/// the follow-up card up to y=650, and a snackbar reports the deletion.
class CustomersDeleteSuccessScreen extends StatelessWidget {
  const CustomersDeleteSuccessScreen({super.key, this.colors = DsColors.light});

  final DsColors colors;

  static const _rows = <CustomerRecord>[
    CustomerRecord('LC', 'Liam Chen', 'Northwind Labs'),
    CustomerRecord('SR', 'Sofia Reyes', 'BrightPath Co'),
    CustomerRecord('NP', 'Noah Patel', 'Vertex Retail'),
    CustomerRecord('EW', 'Emma Wilson', 'Lumen Health'),
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
          child: Text('Customers', style: DsType.h1.copyWith(color: c.fg)),
        ),
        Positioned(
          left: 24,
          top: 76,
          child: Text(
            '1,283 contacts · 12 active deals',
            maxLines: 1,
            softWrap: false,
            style: DsType.caption.copyWith(color: c.mutedFg),
          ),
        ),
        Positioned(
          left: 340,
          top: 44,
          child: DsIconButtonGhost(colors: c, icon: 'more_vertical'),
        ),
        Positioned(
          left: 24,
          top: 116,
          child: DsSearchField(colors: c, hint: 'Search customers...'),
        ),
        Positioned(
          left: 24,
          top: 178,
          child: DsFilterChipBar(
            colors: c,
            labels: const ['All', 'Active', 'Pending', 'New'],
            selectedIndex: 0,
          ),
        ),
        Positioned(
          left: 24,
          top: 232,
          child: DsSectionHeader(
            colors: c,
            title: 'Recent customers',
            action: 'See all',
          ),
        ),
        for (final (i, row) in _rows.indexed)
          Positioned(
            left: 24,
            top: 268 + 74.0 * i,
            child: DsCustomerRow(
              colors: c,
              initials: row.initials,
              name: row.name,
              company: row.company,
            ),
          ),
        Positioned(
          left: 24,
          top: 650,
          child: DsFollowUpCard(
            colors: c,
            title: '3 customers need follow-up',
            subtitle: 'Last contact over 7 days ago',
          ),
        ),
        Positioned(
          left: 24,
          top: 744,
          child: DsSnackbar(
            colors: c,
            message: 'Customer deleted',
            action: 'Undo',
          ),
        ),
        Positioned(
          left: 0,
          top: 820,
          child: DsBottomNav(colors: c, active: DsNavTab.customers),
        ),
      ],
    );
  }
}
