import 'package:flutter/foundation.dart';

/// Human-readable shortcut labels for tooltips ("⌘N" on Apple platforms,
/// "Ctrl+N" elsewhere — including the right glyph on desktop web).
String shortcutLabel(String key) {
  final isApple = defaultTargetPlatform == TargetPlatform.macOS ||
      defaultTargetPlatform == TargetPlatform.iOS;
  return isApple ? '⌘$key' : 'Ctrl+$key';
}
