import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// Per-language visual identity: a brand-ish accent colour and a short
/// monogram, used to give each language a recognisable badge across the list,
/// detail, filter and editor surfaces. Keyed by the seeded language `id`
/// (see `seed_data.dart`); unknown/`null` ids fall back to a neutral glyph.
class LanguageVisual {
  const LanguageVisual(this.color, this.mono);

  /// Accent colour (solid badge background). Foreground is derived for contrast.
  final Color color;

  /// 1–3 character monogram shown inside the badge (e.g. "Py", "JS", "C#").
  final String mono;

  static const LanguageVisual _fallback =
      LanguageVisual(Color(0xFF8A8A99), '');

  static const Map<String, LanguageVisual> _byId = {
    'python': LanguageVisual(Color(0xFF3776AB), 'Py'),
    'javascript': LanguageVisual(Color(0xFFE9B40B), 'JS'),
    'typescript': LanguageVisual(Color(0xFF3178C6), 'TS'),
    'dart': LanguageVisual(Color(0xFF0A9EDC), 'Dt'),
    'go': LanguageVisual(Color(0xFF00ACD7), 'Go'),
    'rust': LanguageVisual(Color(0xFFD86B3C), 'Rs'),
    'java': LanguageVisual(Color(0xFFE76F00), 'Jv'),
    'kotlin': LanguageVisual(Color(0xFF8A6CF0), 'Kt'),
    'swift': LanguageVisual(Color(0xFFF05138), 'Sw'),
    'c': LanguageVisual(Color(0xFF5B6BBF), 'C'),
    'cpp': LanguageVisual(Color(0xFF0095CF), 'C+'),
    'csharp': LanguageVisual(Color(0xFF8A4FA8), 'C#'),
    'php': LanguageVisual(Color(0xFF777BB4), 'Ph'),
    'ruby': LanguageVisual(Color(0xFFCC342D), 'Rb'),
    'sql': LanguageVisual(Color(0xFF4F8FB3), 'SQL'),
    'bash': LanguageVisual(Color(0xFF59A83D), '>_'),
    'html': LanguageVisual(Color(0xFFE34F26), '<>'),
    'css': LanguageVisual(Color(0xFF2D8FD5), '{}'),
    'json': LanguageVisual(Color(0xFF7E8B99), '{}'),
    'yaml': LanguageVisual(Color(0xFFCB4B4B), 'Ym'),
    'markdown': LanguageVisual(Color(0xFF5C6BC0), 'Md'),
    'plaintext': LanguageVisual(Color(0xFF8A8A99), ''),
  };

  static LanguageVisual of(String? languageId) =>
      languageId == null ? _fallback : (_byId[languageId] ?? _fallback);

  /// Readable foreground for text/icons drawn on top of [color].
  Color get onColor =>
      ThemeData.estimateBrightnessForColor(color) == Brightness.dark
          ? Colors.white
          : Colors.black;
}

/// A small, solid, rounded-square badge carrying a language's monogram (or a
/// generic code glyph when the language is unknown). Recognisable at a glance.
class LanguageBadge extends StatelessWidget {
  const LanguageBadge({super.key, required this.languageId, this.size = 24});

  final String? languageId;
  final double size;

  @override
  Widget build(BuildContext context) {
    final visual = LanguageVisual.of(languageId);
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: visual.color,
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: visual.mono.isEmpty
          ? Icon(Icons.code, size: size * 0.6, color: visual.onColor)
          : Text(
              visual.mono,
              style: TextStyle(
                fontFamily: AppTheme.monoFamily,
                fontWeight: FontWeight.w700,
                height: 1,
                // Shrink the glyph for longer monograms so it always fits.
                fontSize: size * (visual.mono.length >= 3 ? 0.34 : 0.42),
                color: visual.onColor,
                letterSpacing: -0.5,
              ),
            ),
    );
  }
}

/// A compact language pill: badge + name, tinted with the language accent.
/// Use where a labelled language indicator is wanted (cards, detail meta).
class LanguagePill extends StatelessWidget {
  const LanguagePill({super.key, required this.languageId, required this.name});

  final String? languageId;
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final visual = LanguageVisual.of(languageId);
    return Container(
      padding: const EdgeInsets.fromLTRB(4, 3, 9, 3),
      decoration: BoxDecoration(
        color: visual.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: visual.color.withValues(alpha: 0.28)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          LanguageBadge(languageId: languageId, size: 16),
          const SizedBox(width: 6),
          Text(
            name,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: theme.colorScheme.onSurface,
              letterSpacing: 0,
            ),
          ),
        ],
      ),
    );
  }
}
