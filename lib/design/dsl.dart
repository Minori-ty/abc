import 'package:flutter/widgets.dart';

import 'tokens.dart';

/// Renders a 412 × 892 Figma frame. The frame is laid out at its design size and
/// scaled to the available viewport, so every coordinate below is the literal
/// value read from Figma — no responsive re-interpretation.
class DsFrame extends StatelessWidget {
  const DsFrame({
    super.key,
    required this.background,
    required this.children,
  });

  final Color background;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return FittedBox(
      fit: BoxFit.contain,
      child: SizedBox(
        width: DsFrameSpec.width,
        height: DsFrameSpec.height,
        child: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            Positioned.fill(child: ColoredBox(color: background)),
            ...children,
          ],
        ),
      ),
    );
  }
}

/// Positioned container with the frame's decoration vocabulary
/// (fill / 1px border / radius / shadow).
class DsBox extends StatelessWidget {
  const DsBox({
    super.key,
    required this.l,
    required this.t,
    required this.w,
    required this.h,
    this.fill,
    this.borderColor,
    this.borderWidth = 1,
    this.radius,
    this.shadow,
    this.opacity,
    this.child,
    this.clip = false,
  });

  final double l;
  final double t;
  final double w;
  final double h;
  final Color? fill;
  final Color? borderColor;
  final double borderWidth;
  final double? radius;
  final List<BoxShadow>? shadow;
  final double? opacity;
  final Widget? child;
  final bool clip;

  @override
  Widget build(BuildContext context) {
    Widget box = Container(
      width: w,
      height: h,
      clipBehavior: clip ? Clip.antiAlias : Clip.none,
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius == null ? null : BorderRadius.circular(radius!),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!, width: borderWidth),
        boxShadow: shadow,
      ),
      child: child,
    );
    if (opacity != null) {
      box = Opacity(opacity: opacity!, child: box);
    }
    return Positioned(left: l, top: t, child: box);
  }
}

/// Positioned text. `w` is the text box width measured in Figma.
class DsText extends StatelessWidget {
  const DsText(
    this.text, {
    super.key,
    required this.l,
    required this.t,
    this.w,
    this.h,
    required this.style,
    required this.color,
    this.align = TextAlign.left,
    this.maxLines,
    this.softWrap = false,
    this.opacity,
    this.textHeightBehavior,
  });

  final String text;
  final double l;
  final double t;
  final double? w;
  final double? h;
  final TextStyle style;
  final Color color;
  final TextAlign align;
  final int? maxLines;
  final bool softWrap;
  final double? opacity;
  final TextHeightBehavior? textHeightBehavior;

  @override
  Widget build(BuildContext context) {
    Widget content = Text(
      text,
      textAlign: align,
      maxLines: maxLines,
      softWrap: softWrap,
      overflow: TextOverflow.clip,
      style: style.copyWith(color: color),
    );
    if (h != null) {
      content = SizedBox(height: h, child: content);
    }
    if (w != null) {
      content = SizedBox(width: w, child: content);
    }
    if (opacity != null) {
      content = Opacity(opacity: opacity!, child: content);
    }
    return Positioned(left: l, top: t, child: content);
  }
}

/// Centers a child inside a fixed Figma box (icon / avatar / pill slots).
class DsSlot extends StatelessWidget {
  const DsSlot({
    super.key,
    required this.l,
    required this.t,
    required this.w,
    required this.h,
    required this.child,
  });

  final double l;
  final double t;
  final double w;
  final double h;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: l,
      top: t,
      child: SizedBox(
        width: w,
        height: h,
        child: Center(child: child),
      ),
    );
  }
}
