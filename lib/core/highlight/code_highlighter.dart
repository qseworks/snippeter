import 'package:flutter/widgets.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';

/// Wraps re_highlight: turns code + a highlight.js grammar id into a styled
/// [TextSpan]. Used by the read view, the list preview and the PNG export card.
///
/// Unknown grammars (or plain text) fall back to an unstyled span so the UI can
/// never crash on a missing grammar.
class CodeHighlighter {
  CodeHighlighter._() {
    _hl.registerLanguages(builtinAllLanguages);
    _known = _hl.listLanguages().toSet();
  }

  static final CodeHighlighter instance = CodeHighlighter._();

  final Highlight _hl = Highlight();
  late final Set<String> _known;

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
    try {
      final result = _hl.highlight(code: code, language: grammarId!);
      final renderer = TextSpanRenderer(baseStyle, theme);
      result.render(renderer);
      return renderer.span ?? TextSpan(text: code, style: baseStyle);
    } catch (_) {
      // Defensive: a grammar bug must never take down the screen.
      return TextSpan(text: code, style: baseStyle);
    }
  }
}
