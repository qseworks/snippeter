import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../l10n/app_localizations.dart';
import '../highlight/code_highlighter.dart';
import '../highlight/code_themes.dart';
import '../highlight/language_visuals.dart';
import '../theme/app_theme.dart';

/// Cross-platform monospace stack. [AppTheme.monoFamily] (JetBrains Mono) is
/// bundled, so the first entry is reliable on every platform incl. PNG export;
/// the rest are graceful fallbacks if the asset ever fails to load.
const List<String> kMonoFallback = [
  AppTheme.monoFamily,
  'Menlo',
  'SF Mono',
  'Consolas',
  'Roboto Mono',
  'DejaVu Sans Mono',
  'Courier New',
  'monospace',
];

/// Read-only, syntax-highlighted code as a styled text block. Selectable by
/// default; pass [selectable] = false and a [maxLines] for compact list
/// previews. For the full "window" presentation (header + line numbers + copy)
/// use [CodeBlock].
class CodeView extends StatelessWidget {
  const CodeView({
    super.key,
    required this.code,
    this.grammarId,
    this.selectable = true,
    this.padding = const EdgeInsets.all(16),
    this.fontSize = 13,
    this.maxLines,
  });

  final String code;
  final String? grammarId;
  final bool selectable;
  final EdgeInsets padding;
  final double fontSize;
  final int? maxLines;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final theme = CodeThemes.forBrightness(brightness);
    final background = codeBackgroundFor(theme, brightness);

    final base = codeBaseStyle(
      fontSize: fontSize,
      color: codeBaseColorFor(theme, brightness),
    );

    final span = CodeHighlighter.instance.highlight(
      code: code,
      grammarId: grammarId,
      baseStyle: base,
      theme: theme,
    );

    final Widget text = selectable
        ? SelectableText.rich(span)
        : Text.rich(
            span,
            maxLines: maxLines,
            overflow:
                maxLines != null ? TextOverflow.ellipsis : TextOverflow.clip,
          );

    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: text,
    );
  }
}

/// Base monospace [TextStyle] for highlighted code.
TextStyle codeBaseStyle({required double fontSize, required Color color}) =>
    TextStyle(
      fontFamily: kMonoFallback.first,
      fontFamilyFallback: kMonoFallback.sublist(1),
      fontSize: fontSize,
      height: 1.5,
      color: color,
    );

Color codeBackgroundFor(Map<String, TextStyle> theme, Brightness brightness) =>
    theme['root']?.backgroundColor ??
    (brightness == Brightness.dark
        ? const Color(0xFF282C34)
        : const Color(0xFFF6F8FA));

Color codeBaseColorFor(Map<String, TextStyle> theme, Brightness brightness) =>
    theme['root']?.color ??
    (brightness == Brightness.dark ? Colors.white70 : Colors.black87);

/// A full code "window": a titled header (language badge + name + line count +
/// copy button) over a horizontally-scrollable, line-numbered, syntax-
/// highlighted body. Used by the detail view.
class CodeBlock extends StatelessWidget {
  const CodeBlock({
    super.key,
    required this.code,
    this.grammarId,
    this.languageId,
    this.languageName,
    this.fontSize = 13.5,
    this.showLineNumbers = true,
  });

  final String code;
  final String? grammarId;
  final String? languageId;
  final String? languageName;
  final double fontSize;
  final bool showLineNumbers;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final brightness = Theme.of(context).brightness;
    final themeMap = CodeThemes.forBrightness(brightness);
    final background = codeBackgroundFor(themeMap, brightness);
    final baseColor = codeBaseColorFor(themeMap, brightness);
    final base = codeBaseStyle(fontSize: fontSize, color: baseColor);
    final muted = baseColor.withValues(alpha: 0.45);

    final span = CodeHighlighter.instance.highlight(
      code: code,
      grammarId: grammarId,
      baseStyle: base,
      theme: themeMap,
    );

    final lineCount = '\n'.allMatches(code).length + 1;

    final gutter = showLineNumbers
        ? Padding(
            padding: const EdgeInsets.only(right: 14),
            child: Text(
              [for (var i = 1; i <= lineCount; i++) '$i'].join('\n'),
              textAlign: TextAlign.right,
              style: base.copyWith(color: muted),
            ),
          )
        : null;

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(color: baseColor.withValues(alpha: 0.10)),
        ),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header bar.
          Container(
            padding: const EdgeInsets.fromLTRB(12, 8, 6, 8),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: baseColor.withValues(alpha: 0.10)),
              ),
            ),
            child: Row(
              children: [
                LanguageBadge(languageId: languageId, size: 20),
                const SizedBox(width: 8),
                Text(
                  languageName ?? l10n.codeViewPlainText,
                  style: TextStyle(
                    color: baseColor.withValues(alpha: 0.85),
                    fontFamily: AppTheme.uiFamily,
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                  ),
                ),
                const Spacer(),
                Text(
                  l10n.codeViewLineCount(lineCount),
                  style: TextStyle(color: muted, fontSize: 11.5),
                ),
                const SizedBox(width: 4),
                _CopyButton(text: code, color: baseColor.withValues(alpha: 0.7)),
              ],
            ),
          ),
          // Body: pinned line-number gutter + horizontally scrollable code.
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 8, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ?gutter,
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: SelectableText.rich(span),
                  ),
                ),
              ],
            ),
          ),
        ],
        ),
      ),
    );
  }
}

/// Copy-to-clipboard affordance that briefly flips to a check mark.
class _CopyButton extends StatefulWidget {
  const _CopyButton({required this.text, required this.color});

  final String text;
  final Color color;

  @override
  State<_CopyButton> createState() => _CopyButtonState();
}

class _CopyButtonState extends State<_CopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return IconButton(
      tooltip: l10n.codeViewCopyTooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 18,
      onPressed: _copy,
      icon: Icon(
        _copied ? Icons.check_rounded : Icons.copy_rounded,
        color: _copied ? const Color(0xFF27C93F) : widget.color,
      ),
    );
  }
}
