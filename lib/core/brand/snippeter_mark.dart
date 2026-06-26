/// Snippeter brand mark, drawn vectorially (no PNG, no flutter_svg).
///
/// The mark is the **"prompt" concept**: a terminal prompt chevron `>` followed
/// by a green block caret (`>▍` — a snippet, ready to paste), set on a dark
/// machined tile. See `brand/README.md` for the palette and platform assets.
///
/// The geometry here mirrors the master `brand/glyph-dark.svg` and
/// `brand/icon.svg` exactly, so the in-app mark stays in sync with every
/// generated favicon/app-icon. Canonical geometry, in a 512×512 tile
/// (`k = size / 512` scales it for any size):
///
///  * Tile: rounded square, corner radius `114` (22.27% of side), filled with a
///    linear gradient from `(147.8, 24)` to `(364.2, 488)`:
///    `#1C1F27 → #111319`.
///  * Optional radial green glow centred at `(328, 246)`, radius `236`,
///    `#65EA92 @16%` fading to transparent at 72%.
///  * 3px inset hairline ring `#24272F` just inside the tile edge.
///  * Glyph: `translate(173.02, 173.02) scale(4.881)`, then in that space a
///    chevron `M0,0 L17,17 L0,34` (stroke `#EDEEF2`, width 8, round) and a caret
///    rounded rect `x=27 y=0 w=11 h=34 rx=4` filled with a vertical gradient
///    `#7CF5A2 → #5EE38B`.
///
/// If you change either SVG, mirror the change here (and in landing's
/// `components/LogoMark.tsx`).
library;

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

// --- Canonical glyph painting (shared by the tile mark and the bare glyph) ---

/// Builds the caret's vertical green gradient paint, in natural glyph
/// coordinates (`y` runs 0..34). Used on dark surfaces.
Paint _caretGradientPaint() => Paint()
  ..shader = ui.Gradient.linear(
    const Offset(32, 0),
    const Offset(32, 34),
    const [Color(0xFF7CF5A2), Color(0xFF5EE38B)],
  );

/// Draws the chevron + caret in the canonical glyph coordinate space, assuming
/// the canvas has already been translated/scaled to position it. The chevron
/// and caret share the same height (0..34).
void _paintGlyph(
  Canvas canvas, {
  required Color chevron,
  required Paint caretPaint,
}) {
  final chevronPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 8
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..color = chevron;
  final chevronPath = Path()
    ..moveTo(0, 0)
    ..lineTo(17, 17)
    ..lineTo(0, 34);
  canvas.drawPath(chevronPath, chevronPaint);

  final caret = RRect.fromRectAndRadius(
    const Rect.fromLTWH(27, 0, 11, 34),
    const Radius.circular(4),
  );
  canvas.drawRRect(caret, caretPaint);
}

/// The full Snippeter mark: the dark rounded tile plus the chevron + green
/// caret glyph. Drawn entirely with a [CustomPainter] — no images.
class SnippeterMark extends StatelessWidget {
  const SnippeterMark({super.key, this.size = 32, this.glow = true});

  /// Edge length of the (square) tile, in logical pixels.
  final double size;

  /// Whether to overlay the subtle radial green glow.
  final bool glow;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: _MarkPainter(size: size, glow: glow),
      ),
    );
  }
}

class _MarkPainter extends CustomPainter {
  _MarkPainter({required this.size, required this.glow});

  final double size;
  final bool glow;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    final k = size / 512;
    final rect = Rect.fromLTWH(0, 0, 512 * k, 512 * k);
    final tile = RRect.fromRectAndRadius(rect, Radius.circular(114 * k));

    // Tile gradient (155°-ish): top-light to bottom-deep.
    final tilePaint = Paint()
      ..shader = ui.Gradient.linear(
        Offset(147.8 * k, 24 * k),
        Offset(364.2 * k, 488 * k),
        const [Color(0xFF1C1F27), Color(0xFF111319)],
      );
    canvas.drawRRect(tile, tilePaint);

    // Optional radial green glow (#65EA92 @ ~16% → transparent at 72%).
    if (glow) {
      final glowPaint = Paint()
        ..shader = ui.Gradient.radial(
          Offset(328 * k, 246 * k),
          236 * k,
          const [Color(0x2965EA92), Color(0x0065EA92)],
          const [0.0, 0.72],
        );
      canvas.drawRRect(tile, glowPaint);
    }

    // Subtle inset hairline ring, sitting just inside the tile edge.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3 * k
      ..color = const Color(0xFF24272F);
    final ring = RRect.fromRectAndRadius(
      rect.deflate(1.5 * k),
      Radius.circular(112.5 * k),
    );
    canvas.drawRRect(ring, ringPaint);

    // Glyph in the canonical scaled space.
    canvas.save();
    canvas.translate(173.02 * k, 173.02 * k);
    canvas.scale(4.881 * k);
    _paintGlyph(
      canvas,
      chevron: const Color(0xFFEDEEF2),
      caretPaint: _caretGradientPaint(),
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(_MarkPainter oldDelegate) =>
      oldDelegate.size != size || oldDelegate.glow != glow;
}

/// The bare Snippeter glyph (chevron + caret) on a transparent background — no
/// tile. Use it inline on an existing surface.
///
/// On dark surfaces the chevron is light (`#EDEEF2`) and the caret uses the
/// green vertical gradient. Pass [onLight] for light surfaces: the chevron
/// becomes ink (`#16181D`) and the caret a solid on-light green (`#259F56`).
class SnippeterGlyph extends StatelessWidget {
  const SnippeterGlyph({
    super.key,
    this.size = 24,
    this.chevron = const Color(0xFFEDEEF2),
    this.onLight = false,
  });

  /// Edge length of the (square) layout box, in logical pixels.
  final double size;

  /// Chevron colour on dark surfaces. Overridden to ink when [onLight] is set.
  final Color chevron;

  /// Render for a light surface (ink chevron + solid green caret).
  final bool onLight;

  @override
  Widget build(BuildContext context) {
    final chevronColor = onLight ? const Color(0xFF16181D) : chevron;
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        size: Size.square(size),
        painter: _GlyphPainter(
          size: size,
          chevron: chevronColor,
          onLight: onLight,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  _GlyphPainter({
    required this.size,
    required this.chevron,
    required this.onLight,
  });

  final double size;
  final Color chevron;
  final bool onLight;

  @override
  void paint(Canvas canvas, Size canvasSize) {
    // The glyph's natural bounding box runs (-4,-4)..(38,38): the chevron's
    // round stroke (width 8) bleeds 4 units past its path on every side, and
    // the caret's right edge sits at x=38. That is a 42-unit square.
    const box = 42.0;
    final margin = size * 0.07;
    final scale = (size - 2 * margin) / box;

    canvas.save();
    // Map natural (-4,-4) to (margin, margin) so the glyph fills the box evenly.
    canvas.translate(margin + 4 * scale, margin + 4 * scale);
    canvas.scale(scale);
    final caretPaint = onLight
        ? (Paint()..color = const Color(0xFF259F56))
        : _caretGradientPaint();
    _paintGlyph(canvas, chevron: chevron, caretPaint: caretPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(_GlyphPainter oldDelegate) =>
      oldDelegate.size != size ||
      oldDelegate.chevron != chevron ||
      oldDelegate.onLight != onLight;
}
