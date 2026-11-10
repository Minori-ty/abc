import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'design/tokens.dart';
import 'frames.dart';
import 'screens/splash.dart';

void main() => runApp(const DesignShowcaseApp());

class DesignShowcaseApp extends StatelessWidget {
  const DesignShowcaseApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRM Design Restoration',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0E1014),
        fontFamily: DsFont.openSans,
      ),
      home: const SplashGate(),
    );
  }
}

/// 真机入口：先放设计稿的第一屏，再进展示外壳。
///
/// 首屏不 `await` 任何东西 —— 展示外壳在它停留的那段时间里已经建好了，
/// 所以这一屏纯粹是品牌呼吸，不占启动时间。
class SplashGate extends StatelessWidget {
  const SplashGate({super.key});

  @override
  Widget build(BuildContext context) {
    return SplashScreen(
      // 真状态栏就在上面，再画一条假的就叠了。
      showStatusBar: false,
      // 从系统 splash 的蓝底 + 白字标溶解过来，去掉硬切。
      echoNativeSplash: true,
      onDone: () => Navigator.of(context).pushReplacement(_showcaseRoute()),
    );
  }

  static Route<void> _showcaseRoute() {
    return PageRouteBuilder<void>(
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (_, _, _) => const ShowcaseHome(),
      transitionsBuilder: (_, animation, _, child) =>
          FadeTransition(opacity: animation, child: child),
    );
  }
}

class ShowcaseHome extends StatefulWidget {
  const ShowcaseHome({super.key});

  @override
  State<ShowcaseHome> createState() => _ShowcaseHomeState();
}

class _ShowcaseHomeState extends State<ShowcaseHome> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final frame = frames[_index];
    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 展示壳是深色底，状态栏图标要跟着翻成浅色；否则从浅色首屏切过来
      // 之后会留下深色图标，在深色背景上几乎看不见。
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: const Color(0x00000000),
        systemNavigationBarColor: const Color(0x00000000),
      ),
      child: Scaffold(
        body: Row(
          children: [
            _Sidebar(
              selected: _index,
              onSelect: (i) => setState(() => _index = i),
            ),
            Expanded(
              child: Column(
                children: [
                  _Header(frame: frame),
                  Expanded(
                    child: Container(
                      color: const Color(0xFF0E1014),
                      padding: const EdgeInsets.all(24),
                      child: Center(
                        child: AspectRatio(
                          aspectRatio: DsFrameSpec.width / DsFrameSpec.height,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              border: Border.all(
                                color: const Color(0xFF2A2F3A),
                              ),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(2),
                              child: frame.build!(context),
                            ),
                          ),
                        ),
                      ),
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

class _Sidebar extends StatelessWidget {
  const _Sidebar({required this.selected, required this.onSelect});

  final int selected;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        color: Color(0xFF14161B),
        border: Border(right: BorderSide(color: Color(0xFF23262E))),
      ),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, 16),
            child: Text(
              'CRM · 22 frames',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFFEDEFF3),
              ),
            ),
          ),
          for (var i = 0; i < frames.length; i++)
            _SidebarItem(
              label: frames[i].name,
              nodeId: frames[i].nodeId,
              selected: i == selected,
              onTap: () => onSelect(i),
            ),
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 8),
            child: Text(
              'PENDING EXTRACT',
              style: TextStyle(
                fontSize: 10,
                letterSpacing: 0.8,
                color: Color(0xFF6B7280),
              ),
            ),
          ),
          for (final f in pendingFrames)
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 6),
              child: Text(
                f,
                style: const TextStyle(fontSize: 11, color: Color(0xFF4B5563)),
              ),
            ),
        ],
      ),
    );
  }
}

class _SidebarItem extends StatelessWidget {
  const _SidebarItem({
    required this.label,
    required this.nodeId,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final String nodeId;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 1),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFF1E2633) : null,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12.5,
                  color: selected
                      ? const Color(0xFFFFFFFF)
                      : const Color(0xFFA8AFBD),
                ),
              ),
            ),
            Text(
              nodeId,
              style: const TextStyle(fontSize: 10, color: Color(0xFF5B6270)),
            ),
          ],
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.frame});

  final FrameEntry frame;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFF23262E))),
      ),
      child: Row(
        children: [
          Text(
            frame.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Color(0xFFEDEFF3),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${frame.nodeId} · 412×892${frame.dark ? ' · dark' : ''}',
            style: const TextStyle(fontSize: 11, color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }
}
