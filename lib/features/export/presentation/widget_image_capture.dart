import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Renders [child] off-screen at its natural size and captures it as PNG bytes.
///
/// Uses framework primitives (NOT the stale `screenshot` package): the widget
/// is mounted in an [OverlayEntry] positioned off the visible viewport — so it
/// is genuinely laid out and painted (avoiding the `Offstage` `!debugNeedsPaint`
/// trap) — then captured via `RepaintBoundary.toImage`. Identical renderer
/// behavior to the on-screen path; works on Flutter Web under CanvasKit.
Future<Uint8List?> captureWidgetToPng(
  BuildContext context,
  Widget child, {
  double pixelRatio = 3.0,
}) async {
  final overlay = Overlay.of(context, rootOverlay: true);
  final mediaQuery = MediaQuery.of(context);
  final key = GlobalKey();

  final entry = OverlayEntry(
    builder: (_) => Positioned(
      left: -100000, // off the visible viewport, but still painted
      top: 0,
      child: MediaQuery(
        data: mediaQuery,
        child: Directionality(
          textDirection: TextDirection.ltr,
          child: Material(
            type: MaterialType.transparency,
            child: RepaintBoundary(key: key, child: child),
          ),
        ),
      ),
    ),
  );

  overlay.insert(entry);
  try {
    // Let the overlay build, lay out and paint before capturing.
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;

    final boundary = key.currentContext?.findRenderObject();
    if (boundary is! RenderRepaintBoundary) return null;

    // Clamp the effective ratio so the bitmap never exceeds the GPU/Skia
    // texture ceiling (~32k px/side): a very long snippet at 3.0 would
    // otherwise fail toImage or OOM. Degrades resolution, not the export.
    final longestSide =
        math.max(boundary.size.width, boundary.size.height);
    final effectiveRatio = longestSide <= 0
        ? pixelRatio
        : math.min(pixelRatio, 16000 / longestSide);

    final image = await boundary.toImage(pixelRatio: effectiveRatio);
    try {
      final data = await image.toByteData(format: ui.ImageByteFormat.png);
      return data?.buffer.asUint8List();
    } finally {
      image.dispose();
    }
  } finally {
    entry.remove();
  }
}
