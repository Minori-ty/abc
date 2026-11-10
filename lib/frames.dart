import 'package:flutter/material.dart';

import 'design/tokens.dart';
import 'screens/customer_detail.dart';
import 'screens/customers.dart';
import 'screens/customers_states.dart';
import 'screens/deals.dart';
import 'screens/dashboard.dart';
import 'screens/splash.dart';

/// One entry per Figma frame in the `Screens` canvas (node ids from the file).
class FrameEntry {
  const FrameEntry({
    required this.nodeId,
    required this.name,
    required this.build,
    this.dark = false,
    this.blocked,
  });

  final String nodeId;
  final String name;
  final WidgetBuilder? build;
  final bool dark;

  /// Reason the frame is not implemented yet (kept visible, never faked).
  final String? blocked;

  bool get implemented => build != null;
}

final List<FrameEntry> frames = [
  FrameEntry(
    nodeId: '203:1011',
    name: '01 Splash',
    // 展示用：不给 onDone，就是一张纯静态还原，不会自己跳走。
    build: (_) => const SplashScreen(),
  ),
  FrameEntry(
    nodeId: '5:2',
    name: 'Dashboard',
    build: (_) => const DashboardScreen(),
  ),
  FrameEntry(
    nodeId: '5:100',
    name: 'Customers',
    build: (_) => const CustomersScreen(),
  ),
  FrameEntry(
    nodeId: '64:738',
    name: 'Customers · Dark',
    dark: true,
    build: (_) => const CustomersScreen(colors: DsColors.dark, withSectionHeader: false),
  ),
  FrameEntry(
    nodeId: '7:120',
    name: 'Customer detail',
    build: (_) => const CustomerDetailScreen(),
  ),
  FrameEntry(
    nodeId: '64:672',
    name: 'Dashboard · Dark',
    dark: true,
    build: (_) => const DashboardScreen(colors: DsColors.dark, pillHeight: 44),
  ),
  FrameEntry(
    nodeId: '7:307',
    name: 'Deals',
    build: (_) => const DealsScreen(),
  ),
  FrameEntry(
    nodeId: '64:789',
    name: 'Deals · Dark',
    dark: true,
    build: (_) => const DealsScreen(colors: DsColors.dark),
  ),
  FrameEntry(
    nodeId: '10:652',
    name: 'Customers · Loading',
    build: (_) => const CustomersLoadingScreen(),
  ),
  FrameEntry(
    nodeId: '9:583',
    name: 'Customers · Delete success',
    build: (_) => const CustomersDeleteSuccessScreen(),
  ),
];

/// Frames that still need their style pass (Figma Dev Mode MCP hit its daily
/// rate limit before their `get_design_context` payloads were captured).
const pendingFrames = <String>[
  '7:422 Customer detail · More menu',
  '7:531 Add customer · Dialog',
  '7:601 Delete customer · Confirm',
  '7:659 Customers · Filter sheet',
  '9:354 Customers · No results',
  '9:470 Customers · Empty state',
  '9:695 Add customer · Validation',
  '9:831 Settings',
  '10:542 Customers · Pull to refresh',
  '11:620 Deal detail',
  '11:703 Notifications',
  '16:649 Customers · Offline',
  '64:875 Settings · Dark',
];
