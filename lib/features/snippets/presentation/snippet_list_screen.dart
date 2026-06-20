import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/routing/route_paths.dart';
import '../application/snippet_providers.dart';
import '../domain/snippet.dart';
import '../domain/snippet_query.dart';
import 'snippet_detail_screen.dart';
import 'widgets/snippet_card.dart';

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

    return Row(
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
          child: selectedId == null
              ? const DetailPanePlaceholder()
              : InlineSnippetDetail(snippetId: selectedId),
        ),
      ],
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
    final query = ref.watch(libraryQueryProvider);
    final controller = ref.read(libraryQueryProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Padding(
          padding: EdgeInsets.fromLTRB(12, 12, 12, 8),
          child: _SearchField(),
        ),
        _SortHeader(value: query.sort, onChanged: controller.setSort),
        const Divider(height: 1),
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

/// Snippet's "Recently created ▾" sort header, wired to [setSort].
class _SortHeader extends StatelessWidget {
  const _SortHeader({required this.value, required this.onChanged});

  final SnippetSort value;
  final ValueChanged<SnippetSort> onChanged;

  static const _labels = {
    SnippetSort.recent: 'Recently updated',
    SnippetSort.created: 'Recently created',
    SnippetSort.titleAsc: 'Title A–Z',
    SnippetSort.relevance: 'Relevance',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: PopupMenuButton<SnippetSort>(
        initialValue: value,
        onSelected: onChanged,
        tooltip: 'Sort',
        itemBuilder: (context) => [
          for (final entry in _labels.entries)
            PopupMenuItem(value: entry.key, child: Text(entry.value)),
        ],
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _labels[value] ?? 'Sort',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  size: 18, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

/// Search field driving [libraryQueryProvider] (kept as a [TextField] so the
/// integration test that looks for the 'Search snippets…' hint keeps passing).
class _SearchField extends ConsumerStatefulWidget {
  const _SearchField();

  @override
  ConsumerState<_SearchField> createState() => _SearchFieldState();
}

class _SearchFieldState extends ConsumerState<_SearchField> {
  late final TextEditingController _controller;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _controller =
        TextEditingController(text: ref.read(libraryQueryProvider).text ?? '');
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 150), () {
      final trimmed = value.trim();
      ref
          .read(libraryQueryProvider.notifier)
          .setText(trimmed.isEmpty ? null : trimmed);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: ref.watch(searchFocusProvider),
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: 'Search snippets…',
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        suffixIcon: _controller.text.isEmpty
            ? null
            : IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _controller.clear();
                  _onChanged('');
                  setState(() {});
                },
              ),
      ),
    );
  }
}

class _ResultsArea extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return snippetsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child:
              Text('Something went wrong:\n$error', textAlign: TextAlign.center),
        ),
      ),
      data: (snippets) {
        if (snippets.isEmpty) {
          return _EmptyState(filtered: isFiltered);
        }
        return ListView.builder(
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
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({this.filtered = false});

  final bool filtered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, title, subtitle) = filtered
        ? (
            Icons.search_off,
            'No matching snippets',
            'Try a different search or clear the filters.',
          )
        : (
            Icons.code_outlined,
            'No snippets yet',
            'Tap “New snippet” to create your first one.',
          );
    final scheme = theme.colorScheme;
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
          ],
        ),
      ),
    );
  }
}
