import 'package:flutter/widgets.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';

/// Wraps re_highlight: turns code + a highlight.js grammar id into a styled
/// [TextSpan]. Used by the read view, the list preview and the PNG export card.
///
/// Unknown grammars (or plain text) fall back to an unstyled span so the UI can
/// never crash on a missing grammar.
///
/// Results are memoized in a small LRU: tokenizing is O(file length) of
/// synchronous UI-thread work, and the read surfaces re-run build() far more
/// often than content actually changes (selection swaps, search-driven
/// rebuilds, theme lookups). [TextSpan]s are immutable, so sharing one across
/// rebuilds is safe.
class CodeHighlighter {
  CodeHighlighter._() {
    _hl.registerLanguages(builtinAllLanguages);
    _known = _hl.listLanguages().toSet();
  }

  static final CodeHighlighter instance = CodeHighlighter._();

  final Highlight _hl = Highlight();
  late final Set<String> _known;

  // Insertion-ordered map as LRU: hits re-insert, evictions pop the front.
  final Map<_HighlightKey, TextSpan> _cache = {};
  static const int _cacheLimit = 48;

  bool supports(String? grammarId) =>
      grammarId != null && _known.contains(grammarId);

  TextSpan highlight({
    required String code,
    required String? grammarId,
    required TextStyle baseStyle,
    required Map<String, TextStyle> theme,
  }) {
    if (code.isEmpty || !supports(grammarId)) {
      return TextSpan(text: code, style: baseStyle);
    }
    final key = _HighlightKey(code, grammarId!, baseStyle, theme);
    final cached = _cache.remove(key);
    if (cached != null) {
      _cache[key] = cached; // Re-insert: most recently used.
      return cached;
    }
    TextSpan span;
    try {
      final result = _hl.highlight(code: code, language: grammarId);
      final renderer = TextSpanRenderer(baseStyle, theme);
      result.render(renderer);
      span = renderer.span ?? TextSpan(text: code, style: baseStyle);
    } catch (_) {
      // Defensive: a grammar bug must never take down the screen.
      span = TextSpan(text: code, style: baseStyle);
    }
    _cache[key] = span;
    if (_cache.length > _cacheLimit) {
      _cache.remove(_cache.keys.first);
    }
    return span;
  }
}

/// Cache key for one highlight result. The theme map is compared by identity —
/// the app's themes are cached statics (see code_themes.dart), so identity
/// holds; a caller building a fresh map per call simply misses the cache,
/// which is no worse than the uncached behavior.
class _HighlightKey {
  const _HighlightKey(this.code, this.grammarId, this.baseStyle, this.theme);

  final String code;
  final String grammarId;
  final TextStyle baseStyle;
  final Map<String, TextStyle> theme;

  @override
  bool operator ==(Object other) =>
      other is _HighlightKey &&
      identical(other.theme, theme) &&
      other.grammarId == grammarId &&
      other.baseStyle == baseStyle &&
      other.code == code;

  @override
  int get hashCode =>
      Object.hash(code, grammarId, baseStyle, identityHashCode(theme));
}
