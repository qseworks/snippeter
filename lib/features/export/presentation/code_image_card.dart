import 'package:flutter/material.dart';

import '../../../core/highlight/code_highlighter.dart';
import '../../../core/highlight/code_themes.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/code_view.dart';
import '../domain/snippet_export_data.dart';
import 'export_background.dart';

/// carbon.now.sh-style export card. **Text + vector only** — deliberately no
/// raster `Image`/`DecorationImage`, so `RepaintBoundary.toImage` captures it
/// correctly on Flutter Web (CanvasKit drops embedded raster images, see
/// flutter#106314). The widget test in test/ asserts this invariant.
class CodeImageCard extends StatelessWidget {
  const CodeImageCard({
    super.key,
    required this.data,
    required this.themeName,
    required this.background,
    this.windowTitle,
    this.showWatermark = true,
    this.width = 720,
    this.fontSize = 14,
  });

  final SnippetExportData data;
  final String themeName;
  final ExportBackground background;
  final String? windowTitle;
  final bool showWatermark;
  final double width;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final theme = CodeThemes.byName(themeName) ?? CodeThemes.dark;
    final root = theme['root'];
    final codeBackground = root?.backgroundColor ?? const Color(0xFF282C34);
    final baseColor = root?.color ?? Colors.white;

    final base = TextStyle(
      fontFamily: kMonoFallback.first,
      fontFamilyFallback: kMonoFallback.sublist(1),
      fontSize: fontSize,
      height: 1.5,
      color: baseColor,
    );
    final span = CodeHighlighter.instance.highlight(
      code: data.body.isEmpty ? ' ' : data.body,
      grammarId: data.grammarId,
      baseStyle: base,
      theme: theme,
    );

    final title = windowTitle?.trim().isNotEmpty == true
        ? windowTitle!.trim()
        : data.sourceFileName;
    final watermarkColor =
        (background.isDarkish ? Colors.white : Colors.black).withValues(alpha: 0.7);

    return Container(
      width: width,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(gradient: background.toGradient(codeBackground)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            decoration: BoxDecoration(
              color: codeBackground,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.35),
                  blurRadius: 28,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
                  child: Row(
                    children: [
                      _Dot(Color(0xFFFF5F56)),
                      const SizedBox(width: 8),
                      _Dot(Color(0xFFFFBD2E)),
                      const SizedBox(width: 8),
                      _Dot(Color(0xFF27C93F)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: baseColor.withValues(alpha: 0.6),
                            fontSize: 12,
                            fontFamily: kMonoFallback.first,
                            fontFamilyFallback: kMonoFallback.sublist(1),
                          ),
                        ),
                      ),
                      const SizedBox(width: 52), // balance the dots
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
                  child: Directionality(
                    textDirection: TextDirection.ltr,
                    child: Align(
                      alignment: Alignment.topLeft,
                      child: Text.rich(span),
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (showWatermark)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                'Snippeter · ${data.languageName}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: watermarkColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.3,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        width: 13,
        height: 13,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}
