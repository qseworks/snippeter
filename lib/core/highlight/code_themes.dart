import 'package:flutter/widgets.dart';
import 'package:re_highlight/styles/all.dart';

/// highlight.js theme maps (scope name -> [TextStyle]) used for displaying and
/// exporting code. [builtinAllThemes] ships dozens; we expose a curated set and
/// pick light/dark for the app chrome. Export-card themes (Phase 5) reuse these.
class CodeThemes {
  CodeThemes._();

  static final Map<String, TextStyle> dark =
      builtinAllThemes['atom-one-dark']!;
  static final Map<String, TextStyle> light = builtinAllThemes['github']!;

  static Map<String, TextStyle> forBrightness(Brightness brightness) =>
      brightness == Brightness.dark ? dark : light;

  /// Named themes offered for PNG export (all verified present in re_highlight).
  static const List<String> exportThemeNames = [
    'atom-one-dark',
    'github-dark',
    'monokai',
    'nord',
    'tokyo-night-dark',
    'vs2015',
    'github',
    'atom-one-light',
    'vs',
  ];

  static Map<String, TextStyle>? byName(String name) => builtinAllThemes[name];
}
