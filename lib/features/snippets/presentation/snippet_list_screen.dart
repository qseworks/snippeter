import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../core/routing/route_paths.dart';
import '../../../core/widgets/async_states.dart';
import '../../search/presentation/library_filter_bar.dart';
import '../application/snippet_providers.dart';
import '../domain/snippet.dart';
import 'snippet_detail_screen.dart';
import 'snippet_editor_modal.dart';
import 'widgets/snippet_card.dart';
import 'widgets/snippet_copy.dart';

/// The bare library body rendered inside the Snippet shell (no Scaffold / AppBar
/// / FAB — the shell owns those). On wide content it's a list+detail two-pane;
/// on narrow content it's a single list pane that navigates to the detail route.
class LibraryContent extends ConsumerWidget {
  const LibraryContent({super.key});

  static const double _twoPaneBreakpoint = 880;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(libraryQueryProvider);
    final snippetsAsync = ref.watch(snippetListProvider(query));
    final isFiltered = query.hasText || query.hasFilters;

    return LayoutBuilder(
      builder: (context, constraints) {
        final twoPane = constraints.maxWidth >= _twoPaneBreakpoint;
        if (twoPane) {
          return _TwoPaneLibrary(
            snippetsAsync: snippetsAsync,
            isFiltered: isFiltered,
          );
        }
        return _ListPane(
          snippetsAsync: snippetsAsync,
          isFiltered: isFiltered,
          onTap: (snippet) =>
              context.push(RoutePaths.snippetDetail(snippet.id)),
        );
      },
    );
  }
}

/// Wide layout: list pane on the left, inline detail on the right.
class _TwoPaneLibrary extends ConsumerWidget {
  const _TwoPaneLibrary({
    required this.snippetsAsync,
    required this.isFiltered,
  });

  final AsyncValue<List<Snippet>> snippetsAsync;
  final bool isFiltered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedId = ref.watch(selectedSnippetProvider);

    return _ListKeyboardScope(
      snippets: snippetsAsync.value ?? const <Snippet>[],
      child: Row(
        children: [
          SizedBox(
            width: 380,
            child: _ListPane(
              snippetsAsync: snippetsAsync,
              isFiltered: isFiltered,
              selectedId: selectedId,
              onTap: (snippet) =>
                  ref.read(selectedSnippetProvider.notifier).select(snippet.id),
            ),
          ),
          const VerticalDivider(width: 1),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 180),
              switchInCurve: Curves.easeOut,
              switchOutCurve: Curves.easeOut,
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: selectedId == null
                  ? const DetailPanePlaceholder(key: ValueKey('placeholder'))
                  : InlineSnippetDetail(
                      key: ValueKey(selectedId),
                      snippetId: selectedId,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keyboard driving for the two-pane library — the baseline interaction of a
/// pro desktop list: ↑/↓ move the selection, Enter opens the editor, Delete/
/// Backspace ask to delete, Cmd/Ctrl+Shift+C copies the snippet's content.
///
/// Implemented as a raw [Focus] key handler (not [CallbackShortcuts]) so it
/// can *decline* events — anything typed while an [EditableText] (search,
/// label field…) has focus is left alone.
class _ListKeyboardScope extends ConsumerWidget {
  const _ListKeyboardScope({required this.snippets, required this.child});

  final List<Snippet> snippets;
  final Widget child;

  KeyEventResult _onKeyEvent(
      BuildContext context, WidgetRef ref, KeyEvent event) {
    if (event is KeyUpEvent || snippets.isEmpty) {
      return KeyEventResult.ignored;
    }
    final focusContext = FocusManager.instance.primaryFocus?.context;
    if (focusContext?.findAncestorStateOfType<EditableTextState>() != null) {
      return KeyEventResult.ignored;
    }

    final key = event.logicalKey;
    final index =
        snippets.indexWhere((s) => s.id == ref.read(selectedSnippetProvider));

    if (key == LogicalKeyboardKey.arrowDown ||
        key == LogicalKeyboardKey.arrowUp) {
      final delta = key == LogicalKeyboardKey.arrowDown ? 1 : -1;
      final next = index == -1
          ? (delta > 0 ? 0 : snippets.length - 1)
          : (index + delta).clamp(0, snippets.length - 1);
      ref.read(selectedSnippetProvider.notifier).select(snippets[next].id);
      return KeyEventResult.handled;
    }

    if (event is! KeyDownEvent || index == -1) return KeyEventResult.ignored;
    final selected = snippets[index];

    if (key == LogicalKeyboardKey.enter ||
        key == LogicalKeyboardKey.numpadEnter) {
      showSnippetEditor(context, snippetId: selected.id);
      return KeyEventResult.handled;
    }
    if (key == LogicalKeyboardKey.delete ||
        key == LogicalKeyboardKey.backspace) {
      // Hand the selection to a neighbor so the detail pane doesn't blank.
      final nextId = index + 1 < snippets.length
          ? snippets[index + 1].id
          : (index > 0 ? snippets[index - 1].id : null);
      confirmAndDeleteSnippet(
        context,
        ref,
        selected,
        onAfterDelete: () =>
            ref.read(selectedSnippetProvider.notifier).select(nextId),
      );
      return KeyEventResult.handled;
    }
    final hk = HardwareKeyboard.instance;
    if (key == LogicalKeyboardKey.keyC &&
        hk.isShiftPressed &&
        (hk.isMetaPressed || hk.isControlPressed)) {
      copyWithFeedback(
        context,
        snippetPrimaryText(selected),
        AppLocalizations.of(context).exportMenuCopiedSnack,
      );
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (node, event) => _onKeyEvent(context, ref, event),
      child: child,
    );
  }
}

/// The list column: a search field, a sort header, then the results list.
class _ListPane extends ConsumerWidget {
  const _ListPane({
    required this.snippetsAsync,
    required this.isFiltered,
    required this.onTap,
    this.selectedId,
  });

  final AsyncValue<List<Snippet>> snippetsAsync;
  final bool isFiltered;
  final ValueChanged<Snippet> onTap;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Search, sort and composable Type/Language/Collection/Label facets all live
    // in the shared LibraryFilterBar now (it drives libraryQueryProvider, which
    // the results list watches reactively).
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const LibraryFilterBar(),
        Expanded(
          child: _ResultsArea(
            snippetsAsync: snippetsAsync,
            isFiltered: isFiltered,
            selectedId: selectedId,
            onTap: onTap,
          ),
        ),
      ],
    );
  }
}

class _ResultsArea extends ConsumerWidget {
  const _ResultsArea({
    required this.snippetsAsync,
    required this.isFiltered,
    required this.onTap,
    this.selectedId,
  });

  final AsyncValue<List<Snippet>> snippetsAsync;
  final bool isFiltered;
  final ValueChanged<Snippet> onTap;
  final String? selectedId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    // Discriminator drives the cross-fade between the loading/error/empty/
    // data PHASES only. Within the data phase the ListView updates in place —
    // fading result-set changes meant two full lists alive per keystroke-
    // committed search and a scroll reset on every refinement.
    final String discriminator;
    final Widget child;

    if (snippetsAsync.isLoading && !snippetsAsync.hasValue) {
      // First load only — once we have a value we keep it visible while the
      // query-keyed family refetches, so sort/filter/search never blanks.
      discriminator = 'loading';
      child = const AppLoader();
    } else if (snippetsAsync.hasError && !snippetsAsync.hasValue) {
      discriminator = 'error';
      child = AppErrorState(
        message: l10n.settingsGenericError,
        onRetry: () {
          final query = ref.read(libraryQueryProvider);
          ref.invalidate(snippetListProvider(query));
          ref.invalidate(libraryStatsStreamProvider);
        },
      );
    } else {
      final snippets = snippetsAsync.value ?? const <Snippet>[];
      if (snippets.isEmpty) {
        discriminator = 'empty';
        child = _EmptyState(filtered: isFiltered);
      } else {
        discriminator = 'data';
        child = ListView.builder(
          padding: const EdgeInsets.fromLTRB(8, 8, 8, 96),
          itemCount: snippets.length,
          itemBuilder: (context, index) {
            final snippet = snippets[index];
            return SnippetCard(
              snippet: snippet,
              selected: snippet.id == selectedId,
              onTap: () => onTap(snippet),
            );
          },
        );
      }
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 180),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeOut,
      child: KeyedSubtree(key: ValueKey(discriminator), child: child),
    );
  }
}

class _EmptyState extends ConsumerWidget {
  const _EmptyState({this.filtered = false});

  final bool filtered;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final (icon, title, subtitle) = filtered
        ? (
            Icons.search_off,
            l10n.listEmptyFilteredTitle,
            l10n.listEmptyFilteredSubtitle,
          )
        : (
            Icons.code_outlined,
            l10n.listEmptyTitle,
            l10n.listEmptySubtitle,
          );
    final scheme = theme.colorScheme;

    // CTA: an empty library offers "New snippet"; a filtered-empty result
    // offers to clear the active filters (only when filters — not just search
    // text — are in play, matching the filter bar's own Clear chip).
    final Widget? action;
    if (!filtered) {
      action = FilledButton.icon(
        onPressed: () => showSnippetEditor(context),
        icon: const Icon(Icons.add),
        label: Text(l10n.sidebarNewSnippetButton),
      );
    } else if (ref.watch(libraryQueryProvider).hasFilters) {
      action = TextButton.icon(
        onPressed: () =>
            ref.read(libraryQueryProvider.notifier).clearFilters(),
        icon: const Icon(Icons.clear, size: 18),
        label: Text(l10n.filterClearChip),
      );
    } else {
      action = null;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 104,
              height: 104,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: scheme.surfaceContainerHighest,
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.16),
                    scheme.secondary.withValues(alpha: 0.10),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Icon(icon, size: 46, color: scheme.primary),
            ),
            const SizedBox(height: 22),
            Text(
              title,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: scheme.onSurfaceVariant),
            ),
            if (action != null) ...[
              const SizedBox(height: 22),
              action,
            ],
          ],
        ),
      ),
    );
  }
}
