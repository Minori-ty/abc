import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../components/chrome.dart';
import '../design/dsl.dart';
import '../design/tokens.dart';

/// 设计稿 Logo 里的绿色点 / 横条 (#87E6B4)。它只存在于品牌标内部，
/// 不属于 `CRM Tokens` 的语义色，所以留在本地而不塞进 DsColors。
const _brandGreen = Color(0xFF87E6B4);

/// `MF Tool` 字标 —— Poppins SemiBold 28/35。
const _wordmark = TextStyle(
  fontFamily: DsFont.poppins,
  fontSize: 28,
  fontWeight: FontWeight.w600,
  height: 35 / 28,
  leadingDistribution: TextLeadingDistribution.even,
);

/// Logo 里的 `MF` —— Poppins ExtraBold 45/56。
const _mark = TextStyle(
  fontFamily: DsFont.poppins,
  fontSize: 45,
  fontWeight: FontWeight.w800,
  height: 56 / 45,
  leadingDistribution: TextLeadingDistribution.even,
  color: Color(0xFFFFFFFF),
  decoration: TextDecoration.none,
);

/// Figma 里两行说明文字用了 rgba(71,85,105,.72) / rgba(71,85,105,.75)；
/// 直接给 ARGB，省掉每帧算 withValues。
const _metaColor = Color(0xB8475569);
const _versionColor = Color(0xBF475569);

/// Figma frame `01 Splash` (203:1011)。
///
/// 同一个 widget 承担两件完全不同的事，由 [onDone] 区分：
///
/// * **展示模式**（`onDone == null`）—— 设计稿的逐像素还原：412 × 892 画布、
///   连假状态栏一起画、没有任何计时器和动画。
/// * **真机首屏**（`onDone != null`）—— 全屏、不画假状态栏（真状态栏在），
///   并且把系统 splash 的蓝色底 + 白色字标「回声」盖在上面溶解掉，让
///   `windowSplashScreenBackground` → 首帧之间没有可见的硬切。
///
/// 设计稿的 `LoadingTrack` / `LoadingFill`（203:1018、203:1019）没有实现：
/// 去掉进度动画之后，一根冻在 40% 的进度条看起来就像卡住了。
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.onDone,
    this.showStatusBar = true,
    this.echoNativeSplash = false,
    this.minDisplay = const Duration(milliseconds: 620),
  });

  /// 首屏停留结束后的回调；为 null 时是纯静态还原，不会自己跳走。
  final VoidCallback? onDone;

  /// 是否画设计稿里那条假状态栏。真机上必须关掉，否则会和系统状态栏叠在一起。
  final bool showStatusBar;

  /// 是否从系统 splash 的蓝色底溶解过来。
  final bool echoNativeSplash;

  /// 首屏最少停留时长。它不 `await` 任何东西，只是给品牌色一个呼吸，
  /// 目标页面在它结束之前不会被阻塞。
  final Duration minDisplay;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _echo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    value: widget.echoNativeSplash ? 0.0 : 1.0,
  );

  Timer? _handoff;

  @override
  void initState() {
    super.initState();
    if (widget.echoNativeSplash) {
      // 第一帧必须还是纯品牌蓝。溶解要等这一帧真的上屏之后再跑，
      // 否则 debug 包首帧一慢，溶解会在用户看到之前就结束 —— 等于没做。
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _echo.forward();
      });
    }
    final done = widget.onDone;
    if (done != null) {
      // 不做进度条动画，也不 await 任何初始化 —— 这里只是把品牌色留住一会儿。
      _handoff = Timer(widget.minDisplay, done);
    }
  }

  @override
  void dispose() {
    _handoff?.cancel();
    _echo.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // `MaterialApp` 在没有 `Material` / `Scaffold` 的子树里会套一个
    // `_errorTextStyle`（红字 + 黄色双下划线，本意是提醒「把 Text 放进
    // Material」）。首屏没有 Scaffold，不盖掉它的话字标下面会长出两条黄线，
    // 字号越大越明显。这里把继承链切断，样式全部由本文件的常量决定。
    return DefaultTextStyle(
      style: const TextStyle(decoration: TextDecoration.none),
      child: _buildBody(),
    );
  }

  Widget _buildBody() {
    final frame = _buildFrame();
    if (!widget.echoNativeSplash) return frame;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      // 浅色首屏 → 状态栏图标用深色。上一步的系统 splash 是蓝底，
      // 但那只持续几百毫秒，不值得为它单独切一次 overlay style。
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: const Color(0x00000000),
        systemNavigationBarColor: const Color(0x00000000),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          // FittedBox 在极端比例下会留边，兜一层同色底免得看见黑。
          ColoredBox(color: DsColors.light.bg, child: frame),
          FadeTransition(
            opacity: ReverseAnimation(_echo),
            child: const _NativeSplashEcho(),
          ),
        ],
      ),
    );
  }

  Widget _buildFrame() {
    const c = DsColors.light;
    return DsFrame(
      background: c.bg,
      children: [
        // TopGlow 203:1014 —— 412 × 380，#DBEAFE → 62% rgba(238,244,255,.65)
        // → rgba(248,250,252,0)
        const Positioned(left: 0, top: 0, child: _TopGlow()),

        if (widget.showStatusBar)
          Positioned(left: 0, top: 0, child: DsStatusBar(colors: c)),

        // Logo/App/120 204:990
        const Positioned(left: 146, top: 306, child: _LogoCard()),

        // Wordmark 203:1015
        Positioned(
          left: 152.5,
          top: 462,
          child: Text(
            'MF Tool',
            softWrap: false,
            maxLines: 1,
            style: _wordmark.copyWith(color: c.fg),
          ),
        ),

        // Tagline 203:1016
        Positioned(
          left: 140,
          top: 502,
          child: Text(
            '专业高效的地推管理平台',
            softWrap: false,
            maxLines: 1,
            style: DsType.caption.copyWith(color: c.mutedFg),
          ),
        ),

        // Meta 203:1017
        Positioned(
          left: 124.5,
          top: 528,
          child: Text(
            '门店拜访 · 任务执行 · 数据回传',
            softWrap: false,
            maxLines: 1,
            style: DsType.caption.copyWith(color: _metaColor),
          ),
        ),

        // Version 203:1020
        Positioned(
          left: 153.5,
          top: 812,
          child: Text(
            'MR FOG · v0.1.0 (1)',
            softWrap: false,
            maxLines: 1,
            style: DsType.caption.copyWith(color: _versionColor),
          ),
        ),
      ],
    );
  }
}

/// 203:1014 —— 顶部 380 高的纵向渐变光晕。
class _TopGlow extends StatelessWidget {
  const _TopGlow();

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 412,
      height: 380,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFDBEAFE),
              Color(0xA6EEF4FF), // rgba(238,244,255,.65)
              Color(0x00F8FAFC), // rgba(248,250,252,0)
            ],
            stops: [0.0, 0.62, 1.0],
          ),
        ),
      ),
    );
  }
}

/// 204:990 —— 120 × 120 / r28 / 品牌蓝 / Shadow·Card。
class _LogoCard extends StatelessWidget {
  const _LogoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      height: 120,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: DsColors.light.primary,
        borderRadius: BorderRadius.circular(28),
        boxShadow: DsShadow.card,
      ),
      child: Stack(
        children: [
          // 205:978 —— Poppins ExtraBold 45/56，盒顶 28。
          // 必须显式给宽：Stack 只会给 94 宽的松约束，而 "MF" 的 advance 是
          // 132，被夹住会触发文字溢出路径。
          Positioned(
            left: 26,
            top: 28,
            width: 132,
            child: const Text('MF', softWrap: false, maxLines: 1, style: _mark),
          ),
          // 205:979 —— ⌀8 圆点
          Positioned(
            left: 38.5,
            top: 90,
            child: Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: _brandGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),
          // 205:980 —— 30 × 8 / r4 横条
          Positioned(
            left: 51.5,
            top: 90,
            child: Container(
              width: 30,
              height: 8,
              decoration: BoxDecoration(
                color: _brandGreen,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// 系统 splash 的「回声」：品牌蓝底 + 白色 MF 字标。
///
/// 几何与 `tool/gen_splash_assets.py::draw_mark` 同一套比例，只是画在
/// Android 12+ 固定的 288dp 图标画布上 —— 这样从 `windowSplashScreenBackground`
/// 交接过来时，字标既不会跳也不会缩。
///
/// 用 Dart 画而不是 `Image.asset`：图片解码发生在首帧之后，会先闪一两帧空白蓝底，
/// 等于白做；这里的绘制是同步的，首帧就到位，而且是矢量的。
class _NativeSplashEcho extends StatelessWidget {
  const _NativeSplashEcho();

  static const _canvas = 288.0;
  static const _mfW = 132.0;
  static const _gap = 22.0;
  static const _barW = 66.0;
  static const _barH = 18.0;
  static const _step = _gap * 0.55;
  static const _groupCenterY = 136.0; // R_CY：整组上移 8 平衡重心

  // Poppins ExtraBold 度量（unitsPerEm = 1000）：asc 1050 / desc 350 / cap 709，
  // "MF" 的 advance 是 1.496 em —— 与生成脚本里 fit_font 的二分结果一致。
  static const _advMf = 1.496;
  static const _asc = 1.05;
  static const _desc = 0.35;
  static const _cap = 0.709;

  @override
  Widget build(BuildContext context) {
    final fs = _mfW / _advMf; // 88.24
    final capPx = _cap * fs; // 62.56
    final groupTop = _groupCenterY - (capPx + _gap + _barH) / 2;
    // Text 盒顶 → 字冠的距离。height:1.0 + even leading 下正好是这 0.141em。
    final inkLift = ((1 - _asc - _desc) / 2 + _asc - _cap) * fs;

    return ColoredBox(
      // 与 values-v31/styles.xml 里的 windowSplashScreenBackground 同一个值。
      color: DsColors.light.primary,
      child: Center(
        child: SizedBox(
          width: _canvas,
          height: _canvas,
          child: Stack(
            children: [
              Positioned(
                left: (_canvas - _mfW) / 2,
                top: groupTop - inkLift,
                child: Text(
                  'MF',
                  style: _mark.copyWith(fontSize: fs, height: 1.0),
                ),
              ),
              Positioned(
                left: (_canvas - (_barH + _step + _barW)) / 2,
                top: groupTop + capPx + _gap,
                child: Row(
                  children: [
                    Container(
                      width: _barH,
                      height: _barH,
                      decoration: const BoxDecoration(
                        color: _brandGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: _step),
                    Container(
                      width: _barW,
                      height: _barH,
                      decoration: BoxDecoration(
                        color: _brandGreen,
                        borderRadius: BorderRadius.circular(_barH / 2),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
