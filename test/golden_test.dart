import 'package:abc/design/tokens.dart';
import 'package:abc/screens/customer_detail.dart';
import 'package:abc/screens/customers.dart';
import 'package:abc/screens/customers_states.dart';
import 'package:abc/screens/dashboard.dart';
import 'package:abc/screens/deals.dart';
import 'package:abc/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'test_fonts.dart';

/// Captures a frame at exactly 1 device pixel per design pixel on a 412 × 892
/// surface, so the golden is directly comparable with the Figma export of the
/// same node (`.workbuddy/figma_out/<node>.png`).
///
/// `flutter_test` paints every `BoxShadow` as a hard-edged rectangle by
/// default. The design leans on soft shadows, so they are switched on for the
/// capture and restored before the body returns —
/// `debugAssertAllPaintingVarsUnset` runs after the body, so a `tearDown` is
/// too late.
Future<void> _golden(WidgetTester tester, Widget child, String file) async {
  debugDisableShadows = false;
  try {
    tester.view.physicalSize = const Size(412, 892);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      Directionality(textDirection: TextDirection.ltr, child: child),
    );
    // SVG assets resolve asynchronously; let the bundle settle first.
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 300)),
    );
    await tester.pumpAndSettle();

    await expectLater(find.byWidget(child), matchesGoldenFile(file));
  } finally {
    debugDisableShadows = true;
  }
}

void main() {
  setUpAll(loadAppFonts);

  testWidgets('golden: dashboard', (tester) async {
    await _golden(tester, const DashboardScreen(), 'goldens/dashboard.png');
  });

  testWidgets('golden: customers', (tester) async {
    await _golden(tester, const CustomersScreen(), 'goldens/customers.png');
  });

  testWidgets('golden: customers dark', (tester) async {
    await _golden(
      tester,
      const CustomersScreen(colors: DsColors.dark, withSectionHeader: false),
      'goldens/customers_dark.png',
    );
  });

  testWidgets('golden: dashboard dark', (tester) async {
    await _golden(
      tester,
      const DashboardScreen(colors: DsColors.dark, pillHeight: 44),
      'goldens/dashboard_dark.png',
    );
  });

  testWidgets('golden: deals', (tester) async {
    await _golden(tester, const DealsScreen(), 'goldens/deals.png');
  });

  testWidgets('golden: deals dark', (tester) async {
    await _golden(
      tester,
      const DealsScreen(colors: DsColors.dark),
      'goldens/deals_dark.png',
    );
  });

  testWidgets('golden: customers loading', (tester) async {
    await _golden(
      tester,
      const CustomersLoadingScreen(),
      'goldens/customers_loading.png',
    );
  });

  testWidgets('golden: customers delete success', (tester) async {
    await _golden(
      tester,
      const CustomersDeleteSuccessScreen(),
      'goldens/customers_delete_success.png',
    );
  });

  testWidgets('golden: customer detail', (tester) async {
    await _golden(
      tester,
      const CustomerDetailScreen(),
      'goldens/customer_detail.png',
    );
  });

  testWidgets('golden: splash', (tester) async {
    await _golden(tester, const SplashScreen(), 'goldens/splash.png');
  });

  // 同一帧，但放回 App 真实的上下文：`MaterialApp` 且**没有** `Scaffold` /
  // `Material` 祖先。`MaterialApp` 会给这种子树塞 `_errorTextStyle`（红字 +
  // 黄色双下划线），首屏如果没自己切断继承链，这条 golden 就会长出下划线 ——
  // 这正是真机上发生过的那次回归，所以这里特意不加 `Scaffold`。
  testWidgets('golden: splash in material app', (tester) async {
    await _golden(
      tester,
      MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          brightness: Brightness.dark,
          scaffoldBackgroundColor: const Color(0xFF0E1014),
          fontFamily: DsFont.openSans,
        ),
        home: const SplashScreen(),
      ),
      'goldens/splash_material.png',
    );
  });
}
