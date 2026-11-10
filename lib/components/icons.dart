import 'package:flutter/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// A single-colour glyph from the design's icon set.
///
/// The file bakes a colour into every exported SVG, and that colour depends on
/// the *state* of the node it was exported from (active / inactive / accent),
/// not on the theme. Rendering is therefore done with a `srcIn` colour filter so
/// one glyph can serve any state in any theme.
class DsGlyph extends StatelessWidget {
  const DsGlyph(
    this.name, {
    super.key,
    required this.color,
    this.size = 24,
    this.width,
    this.height,
  });

  /// Renders a two-tone asset verbatim, ignoring [color].
  const DsGlyph.raw(
    this.name, {
    super.key,
    this.size = 24,
    this.width,
    this.height,
  }) : color = null;

  final String name;
  final Color? color;
  final double size;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/icons/$name.svg',
      width: width ?? size,
      height: height ?? size,
      colorFilter:
          color == null ? null : ColorFilter.mode(color!, BlendMode.srcIn),
    );
  }
}
