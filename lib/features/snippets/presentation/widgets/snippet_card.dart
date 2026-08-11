import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../../core/highlight/language_visuals.dart';
import '../../../../core/theme/app_theme.dart';
import '../../application/snippet_providers.dart';
import '../../domain/snippet.dart';
import '../../domain/value_objects.dart';
import '../snippet_editor_modal.dart';
import 'label_chip.dart';
import 'snippet_copy.dart';

/// A snippet ROW in the master list: a lock glyph (private), the
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

  // Manual double-click detection: an InkWell.onDoubleTap would delay every
  // single tap by the disambiguation window, which reads as lag on the list's
  // primary action. Instead the first click selects immediately and a second
  // click on the same row within the window opens the editor.
  static String? _lastTapId;
  static int _lastTapMs = 0;

  void _handleTap(BuildContext context) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final isDoubleClick =
        _lastTapId == snippet.id && now - _lastTapMs < 350;
    _lastTapId = snippet.id;
    _lastTapMs = now;
    onTap();
    if (isDoubleClick) {
      showSnippetEditor(context, snippetId: snippet.id);
    }
  }

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

    return _KeepVisibleWhenSelected(
      selected: selected,
      child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: InkWell(
          onTap: () => _handleTap(context),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: selected ? scheme.surfaceContainerHigh : Colors.transparent,
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
                    const SizedBox(width: 4),
                    CopyIconButton(
                      text: snippetPrimaryText(snippet),
                      tooltip: l10n.cardCopyTooltip,
                      copiedMessage: l10n.exportMenuCopiedSnack,
                    ),
                    IconButton(
                      visualDensity: VisualDensity.compact,
                      iconSize: 18,
                      padding: const EdgeInsetsDirectional.only(start: 4),
                      constraints:
                          const BoxConstraints(minWidth: 40, minHeight: 40),
                      tooltip: snippet.isFavorite
                          ? l10n.cardUnfavorite
                          : l10n.cardFavorite,
                      icon: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 200),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeOut,
                        transitionBuilder: (child, animation) => ScaleTransition(
                          scale: animation,
                          child:
                              FadeTransition(opacity: animation, child: child),
                        ),
                        child: Icon(
                          snippet.isFavorite ? Icons.star : Icons.star_border,
                          key: ValueKey(snippet.isFavorite),
                          color: snippet.isFavorite ? Colors.amber : null,
                        ),
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
      ),
    );
  }
}

/// Scrolls itself into view when [selected] flips true, so the keyboard
/// selection (↑/↓ in the library list) never walks off-screen. Only reacts to
/// the flip — initial mounts and taps on already-visible rows don't yank the
/// scroll position.
class _KeepVisibleWhenSelected extends StatefulWidget {
  const _KeepVisibleWhenSelected({required this.selected, required this.child});

  final bool selected;
  final Widget child;

  @override
  State<_KeepVisibleWhenSelected> createState() =>
      _KeepVisibleWhenSelectedState();
}

class _KeepVisibleWhenSelectedState extends State<_KeepVisibleWhenSelected> {
  @override
  void didUpdateWidget(_KeepVisibleWhenSelected oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected && !oldWidget.selected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        // The keepVisibleAtEnd+keepVisibleAtStart pair scrolls the minimal
        // amount to make the row fully visible, and not at all when it is.
        Scrollable.ensureVisible(context,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtEnd);
        Scrollable.ensureVisible(context,
            alignmentPolicy: ScrollPositionAlignmentPolicy.keepVisibleAtStart);
      });
    }
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

/// A compact relative/short date from an epoch-ms timestamp.
String _shortDate(AppLocalizations l10n, int epochMs) {
  final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final now = DateTime.now();
  final diff = now.difference(date);
  if (diff.inDays == 0 && now.day == date.day) {
    return DateFormat.jm(l10n.localeName).format(date);
  }
  if (diff.inDays < 7 && diff.inDays >= 0) {
    return l10n.cardDaysAgo(diff.inDays + 1);
  }
  // Locale-aware month/day (the hand-rolled predecessor leaked English month
  // abbreviations into all nine non-English locales).
  return date.year == now.year
      ? DateFormat.MMMd(l10n.localeName).format(date)
      : DateFormat.yMMMd(l10n.localeName).format(date);
}
