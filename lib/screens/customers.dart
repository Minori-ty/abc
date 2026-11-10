import 'package:flutter/widgets.dart';

import '../components/cards.dart';
import '../components/chrome.dart';
import '../components/inputs.dart';
import '../design/dsl.dart';
import '../design/tokens.dart';

class CustomerRecord {
  const CustomerRecord(this.initials, this.name, this.company);

  final String initials;
  final String name;
  final String company;
}

const customers = <CustomerRecord>[
  CustomerRecord('OM', 'Olivia Martin', 'Acme Studio'),
  CustomerRecord('LC', 'Liam Chen', 'Northwind Labs'),
  CustomerRecord('SR', 'Sofia Reyes', 'BrightPath Co'),
  CustomerRecord('NP', 'Noah Patel', 'Vertex Retail'),
  CustomerRecord('EW', 'Emma Wilson', 'Lumen Health'),
  CustomerRecord('DK', 'Daniel Kim', 'Atlas Freight'),
  CustomerRecord('MR', 'Maya Rossi', 'Nova Legal'),
  CustomerRecord('EB', 'Ethan Brooks', 'Summit Realty'),
];

/// Figma frames `Customers` (5:100) and `Customers · Dark` (64:738).
///
/// The dark frame drops the section header (Figma removed it), so the list
/// starts 36px higher and the follow-up card sits at 864 instead of 900.
class CustomersScreen extends StatelessWidget {
  const CustomersScreen({
    super.key,
    this.colors = DsColors.light,
    this.withSectionHeader = true,
  });

  final DsColors colors;
  final bool withSectionHeader;

  @override
  Widget build(BuildContext context) {
    final c = colors;
    final rowsTop = withSectionHeader ? 268.0 : 232.0;
    final followUpTop = withSectionHeader ? 900.0 : 864.0;

    return DsFrame(
      background: c.bg,
      children: [
        Positioned(
          left: 0,
          top: 0,
          child: DsStatusBar(colors: c),
        ),
        Positioned(
          left: 24,
          top: 44,
          child: Text('Customers', style: DsType.h1.copyWith(color: c.fg)),
        ),
        Positioned(
          left: 24,
          top: 76,
          child: Text(
            '1,284 contacts · 12 active deals',
            style: DsType.caption.copyWith(color: c.mutedFg),
          ),
        ),
        Positioned(
          left: 340,
          top: 44,
          child: DsIconButtonGhost(colors: c, icon: 'more_vertical'),
        ),
        Positioned(
          left: 284,
          top: 44,
          child: DsBellButton(colors: c, count: 2),
        ),
        Positioned(
          left: 24,
          top: 116,
          child: DsSearchField(
            colors: c,
            hint: withSectionHeader ? 'Search customers...' : 'Search customers…',
          ),
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
        if (withSectionHeader)
          Positioned(
            left: 24,
            top: 232,
            child: DsSectionHeader(
              colors: c,
              title: 'Recent customers',
              action: 'See all',
            ),
          ),
        for (var i = 0; i < customers.length; i++)
          Positioned(
            left: 24,
            top: rowsTop + i * 74,
            child: DsCustomerRow(
              colors: c,
              initials: customers[i].initials,
              name: customers[i].name,
              company: customers[i].company,
            ),
          ),
        Positioned(
          left: 24,
          top: followUpTop,
          child: DsFollowUpCard(
            colors: c,
            title: '3 customers need follow-up',
            subtitle: 'Last contact over 7 days ago',
          ),
        ),
        Positioned(
          left: 332,
          top: 740,
          child: DsFab(colors: c),
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
