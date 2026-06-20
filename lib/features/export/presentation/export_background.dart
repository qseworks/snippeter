import 'package:flutter/material.dart';

/// A padding-area background for the export card. Vector only (gradients) — no
/// raster images, so the card stays web-capture-safe.
class ExportBackground {
  const ExportBackground(this.name, this.colors);

  final String name;

  /// 2+ colors for a diagonal gradient; empty means "use the code theme's solid
  /// background" (a frameless look).
  final List<Color> colors;

  Gradient toGradient(Color solidFallback) {
    final stops = colors.isEmpty ? [solidFallback, solidFallback] : colors;
    return LinearGradient(
      colors: stops,
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    );
  }

  bool get isDarkish {
    if (colors.isEmpty) return true;
    return ThemeData.estimateBrightnessForColor(colors.first) ==
        Brightness.dark;
  }

  static const List<ExportBackground> presets = [
    ExportBackground('Violet', [Color(0xFF7F7FD5), Color(0xFF86A8E7), Color(0xFF91EAE4)]),
    ExportBackground('Sunset', [Color(0xFFFF512F), Color(0xFFDD2476)]),
    ExportBackground('Ocean', [Color(0xFF2193B0), Color(0xFF6DD5ED)]),
    ExportBackground('Forest', [Color(0xFF134E5E), Color(0xFF71B280)]),
    ExportBackground('Slate', [Color(0xFF232526), Color(0xFF414345)]),
    ExportBackground('None', []),
  ];
}
