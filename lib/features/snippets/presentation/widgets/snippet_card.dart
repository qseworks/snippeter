import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../../core/highlight/language_visuals.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/snippet_providers.dart';
import '../../domain/snippet.dart';
import '../../domain/value_objects.dart';
import 'label_chip.dart';

/// A Snippet-style snippet ROW in the master list: a lock glyph (private), the
/// title, colored label chips + language pill, and a short date on the right.
/// The selected row shows a 3px green left bar over a subtle background.
class SnippetCard extends ConsumerWidget {
  const SnippetCard({
    super.key,
    required this.snippet,
    required this.onTap,
    this.selected = false,
  });

  final Snippet snippet;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    // Preview language comes from the first file (falls back to the snippet's
    // denormalized language for legacy single-body snippets).
    final previewLanguageId = snippet.files.isNotEmpty
        ? snippet.files.first.languageId
        : snippet.languageId;
    final language = ref.watch(languageMapProvider)[previewLanguageId];
    final isPrivate = snippet.visibility == SnippetVisibility.private;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: BorderDirectional(
                start: BorderSide(
                  color: selected ? AppTheme.accent : Colors.transparent,
                  width: 3,
                ),
              ),
            ),
            padding: const EdgeInsetsDirectional.fromSTEB(11, 10, 8, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      isPrivate ? Icons.lock_outline : Icons.public,
                      size: 14,
                      color: scheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        snippet.title.isEmpty ? l10n.cardUntitled : snippet.title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.1,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _shortDate(l10n, snippet.updatedAt),
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      constraints: const BoxConstraints(),
                      tooltip: snippet.isFavorite
                          ? l10n.cardUnfavorite
                          : l10n.cardFavorite,
                      icon: Icon(
                        snippet.isFavorite ? Icons.star : Icons.star_border,
                        color: snippet.isFavorite ? Colors.amber : null,
                      ),
                      onPressed: () => ref
                          .read(snippetRepositoryProvider)
                          .setFavorite(snippet.id, value: !snippet.isFavorite),
                    ),
                  ],
                ),
                if (language != null || snippet.labels.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsetsDirectional.only(start: 22),
                    child: Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (language != null)
                          LanguagePill(
                            languageId: previewLanguageId,
                            name: language.name,
                          ),
                        for (final label in snippet.labels.take(4))
                          LabelChip(label: label),
                        if (snippet.labels.length > 4)
                          Text(
                            l10n.cardMoreLabelsCount(snippet.labels.length - 4),
                            style: theme.textTheme.labelSmall
                                ?.copyWith(color: scheme.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A compact relative/short date from an epoch-ms timestamp.
String _shortDate(AppLocalizations l10n, int epochMs) {
  final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays == 0 && now.day == date.day) {
    final h = date.hour.toString().padLeft(2, '0');
    final m = date.minute.toString().padLeft(2, '0');
    return l10n.cardTimeFormat(h, m);
  }
  if (diff.inDays < 7 && diff.inDays >= 0) {
    return l10n.cardDaysAgo(diff.inDays + 1);
  }
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = months[date.month - 1];
  return date.year == now.year
      ? l10n.cardDateFormatSameYear(month, date.day)
      : l10n.cardDateFormatOtherYear(month, date.day, date.year);
}
