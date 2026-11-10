import 'package:abc/app.dart';
import 'package:abc/components/detail.dart';
import 'package:abc/design/tokens.dart';
import 'package:abc/screens/customer_detail.dart';
import 'package:abc/screens/customers.dart';
import 'package:abc/screens/customers_states.dart';
import 'package:abc/screens/dashboard.dart';
import 'package:abc/screens/deals.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_fonts.dart';

Widget _host(Widget child) => MediaQuery(
      data: const MediaQueryData(size: Size(412, 892)),
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: SizedBox(width: 412, height: 892, child: child),
      ),
    );

void main() {
  setUpAll(loadAppFonts);

  testWidgets('Dashboard renders the restored copy', (tester) async {
    await tester.pumpWidget(_host(const DashboardScreen()));

    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('Good morning, Alex'), findsOneWidget);
    expect(find.text('1,284'), findsOneWidget);
    expect(find.text('Pipeline value'), findsOneWidget);
    expect(find.text('Recent activity'), findsOneWidget);
    expect(find.text('Deal moved to Proposal'), findsOneWidget);
    expect(find.text('Monthly target'), findsOneWidget);
  });

  testWidgets('Customers lists all eight records', (tester) async {
    await tester.pumpWidget(_host(const CustomersScreen()));

    // Page title + bottom-nav label.
    expect(find.text('Customers'), findsNWidgets(2));
    expect(find.text('Recent customers'), findsOneWidget);
    for (final c in customers) {
      expect(find.text(c.name), findsOneWidget);
      expect(find.text(c.company), findsOneWidget);
    }
  });

  testWidgets('Customers dark frame drops the section header', (tester) async {
    await tester.pumpWidget(
      _host(const CustomersScreen(colors: DsColors.dark, withSectionHeader: false)),
    );

    expect(find.text('Recent customers'), findsNothing);
    expect(find.text('Olivia Martin'), findsOneWidget);
  });

  testWidgets('Customer detail renders the pipeline and note card', (tester) async {
    await tester.pumpWidget(_host(const CustomerDetailScreen()));

    expect(find.text('Customer'), findsOneWidget);
    expect(find.text('Olivia Martin'), findsOneWidget);
    expect(find.text('Active'), findsOneWidget);
    expect(find.text('Deal pipeline'), findsOneWidget);
    for (final stage in ['Qualified', 'Proposal', 'Negotiation']) {
      expect(find.text(stage), findsOneWidget);
    }
    expect(find.text('Recent notes'), findsOneWidget);
    expect(find.text('Log activity'), findsOneWidget);
  });

  testWidgets('Deals lists four deal cards', (tester) async {
    await tester.pumpWidget(_host(const DealsScreen()));

    expect(find.text('Open pipeline'), findsOneWidget);
    expect(find.text(r'$184K'), findsOneWidget);
    expect(find.text('Open deals'), findsOneWidget);
    for (final title in [
      'Platform renewal',
      'Annual seat expansion',
      'Onboarding package',
      'Website redesign',
    ]) {
      expect(find.text(title), findsOneWidget);
    }
    // Two stages are repeated across the four cards.
    expect(find.text('Proposal'), findsNWidgets(3));
  });

  testWidgets('Customers loading shows five skeleton rows', (tester) async {
    await tester.pumpWidget(_host(const CustomersLoadingScreen()));

    expect(find.text('Loading your workspace...'), findsOneWidget);
    expect(find.byType(DsSkeletonRow), findsNWidgets(5));
    expect(find.text('Olivia Martin'), findsNothing);
  });

  testWidgets('Delete success shows the snackbar without the first record',
      (tester) async {
    await tester.pumpWidget(_host(const CustomersDeleteSuccessScreen()));

    expect(find.text('Customer deleted'), findsOneWidget);
    expect(find.text('Undo'), findsOneWidget);
    expect(find.text('Olivia Martin'), findsNothing);
    expect(find.text('Liam Chen'), findsOneWidget);
  });

  testWidgets('showcase app boots and lists the restored frames', (tester) async {
    await tester.pumpWidget(const DesignShowcaseApp());
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 200)));
    await tester.pump();

    expect(find.text('CRM · 22 frames'), findsOneWidget);
    expect(find.text('Dashboard'), findsWidgets);
    expect(find.text('Customers · Dark'), findsOneWidget);
  });
}
