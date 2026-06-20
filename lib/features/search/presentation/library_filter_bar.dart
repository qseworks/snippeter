import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/highlight/language_visuals.dart';
import '../../snippets/application/snippet_providers.dart';
import '../../snippets/domain/snippet_query.dart';
import '../../snippets/domain/snippet_type.dart';
import '../../snippets/domain/value_objects.dart';

/// Search field + filter chips + sort for the Library tab. All controls drive
/// [libraryQueryProvider]; the list rebuilds reactively.
class LibraryFilterBar extends ConsumerWidget {
  const LibraryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = ref.watch(libraryQueryProvider);
    final controller = ref.read(libraryQueryProvider.notifier);
    final languages = ref.watch(languagesProvider).value ?? const <Language>[];
    final collections =
        ref.watch(collectionsProvider).value ?? const <Collection>[];
    final labels = ref.watch(labelsProvider).value ?? const <Label>[];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        border: Border(
          bottom:
              BorderSide(color: Theme.of(context).colorScheme.outlineVariant),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
        child: Column(
          children: [
            Row(
              children: [
                const Expanded(child: _SearchField()),
                const SizedBox(width: 8),
                _SortButton(value: query.sort, onChanged: controller.setSort),
              ],
            ),
            const SizedBox(height: 8),
            // Wrap (not a horizontal scroller) so every filter — including the
            // Labels chip — stays fully visible on narrow layouts.
            Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChipMenu<SnippetType?>(
                    icon: Icons.category_outlined,
                    label: query.type?.label ?? 'Type',
                    active: query.type != null,
                    value: query.type,
                    items: [
                      const PopupMenuItem(value: null, child: Text('All types')),
                      for (final t in SnippetType.values)
                        PopupMenuItem(value: t, child: Text(t.label)),
                    ],
                    onSelected: controller.setType,
                  ),
                  _FilterChipMenu<String?>(
                    icon: Icons.translate,
                    label: _nameOf(languages, query.languageId) ?? 'Language',
                    active: query.languageId != null,
                    value: query.languageId,
                    leading: query.languageId == null
                        ? null
                        : LanguageBadge(languageId: query.languageId, size: 16),
                    items: [
                      const PopupMenuItem(
                          value: null, child: Text('All languages')),
                      for (final l in languages)
                        PopupMenuItem(value: l.id, child: Text(l.name)),
                    ],
                    onSelected: controller.setLanguage,
                  ),
                  _FilterChipMenu<String?>(
                    icon: Icons.folder_outlined,
                    label: _collectionName(collections, query.collectionId) ??
                        'Collection',
                    active: query.collectionId != null,
                    value: query.collectionId,
                    items: [
                      const PopupMenuItem(
                          value: null, child: Text('All collections')),
                      for (final c in collections)
                        PopupMenuItem(value: c.id, child: Text(c.name)),
                    ],
                    onSelected: controller.setCollection,
                  ),
                  _LabelsChip(
                    labels: labels,
                    selected: query.labelIds,
                    matchAll: query.labelsMatchAll,
                    onApply: (ids, matchAll) {
                      controller.setLabels(ids);
                      controller.setLabelsMatchAll(all: matchAll);
                    },
                  ),
                  if (query.hasFilters)
                    ActionChip(
                      avatar: const Icon(Icons.clear, size: 16),
                      label: const Text('Clear'),
                      onPressed: controller.clearFilters,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String? _nameOf(List<Language> langs, String? id) =>
      id == null ? null : langs.where((l) => l.id == id).firstOrNull?.name;

  static String? _collectionName(List<Collection> cols, String? id) =>
      id == null ? null : cols.where((c) => c.id == id).firstOrNull?.name;
}

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

class _SortButton extends StatelessWidget {
  const _SortButton({required this.value, required this.onChanged});

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
    return PopupMenuButton<SnippetSort>(
      tooltip: 'Sort',
      icon: const Icon(Icons.sort),
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final entry in _labels.entries)
          PopupMenuItem(value: entry.key, child: Text(entry.value)),
      ],
    );
  }
}

class _FilterChipMenu<T> extends StatelessWidget {
  const _FilterChipMenu({
    required this.icon,
    required this.label,
    required this.active,
    required this.value,
    required this.items,
    required this.onSelected,
    this.leading,
  });

  final IconData icon;
  final String label;
  final bool active;
  final T value;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;

  /// Optional badge shown in place of [icon] on the chip face.
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<T>(
      initialValue: value,
      onSelected: onSelected,
      itemBuilder: (context) => items,
      child:
          _ChipFace(icon: icon, label: label, active: active, leading: leading),
    );
  }
}

class _LabelsChip extends StatelessWidget {
  const _LabelsChip({
    required this.labels,
    required this.selected,
    required this.matchAll,
    required this.onApply,
  });

  final List<Label> labels;
  final List<String> selected;
  final bool matchAll;
  final void Function(List<String> ids, bool matchAll) onApply;

  Future<void> _open(BuildContext context) async {
    final chosen = {...selected};
    var all = matchAll;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Filter by labels'),
          content: SizedBox(
            width: 320,
            child: labels.isEmpty
                ? const Text('No labels yet.')
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Text('Match'),
                          const SizedBox(width: 8),
                          SegmentedButton<bool>(
                            segments: const [
                              ButtonSegment(value: false, label: Text('Any')),
                              ButtonSegment(value: true, label: Text('All')),
                            ],
                            selected: {all},
                            onSelectionChanged: (s) =>
                                setState(() => all = s.first),
                          ),
                        ],
                      ),
                      const Divider(),
                      Flexible(
                        child: ListView(
                          shrinkWrap: true,
                          children: [
                            for (final l in labels)
                              CheckboxListTile(
                                dense: true,
                                value: chosen.contains(l.id),
                                title: Text('#${l.name}'),
                                onChanged: (v) => setState(() {
                                  if (v ?? false) {
                                    chosen.add(l.id);
                                  } else {
                                    chosen.remove(l.id);
                                  }
                                }),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
    if ((result ?? false)) onApply(chosen.toList(), all);
  }

  @override
  Widget build(BuildContext context) {
    final label = selected.isEmpty ? 'Labels' : 'Labels (${selected.length})';
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => _open(context),
      child: _ChipFace(
        icon: Icons.label_outline,
        label: label,
        active: selected.isNotEmpty,
      ),
    );
  }
}

class _ChipFace extends StatelessWidget {
  const _ChipFace({
    required this.icon,
    required this.label,
    required this.active,
    this.leading,
  });

  final IconData icon;
  final String label;
  final bool active;

  /// Optional badge shown in place of [icon] (e.g. the selected language).
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = active
        ? theme.colorScheme.onSecondaryContainer
        : theme.colorScheme.onSurfaceVariant;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: active
            ? theme.colorScheme.secondaryContainer
            : theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading ?? Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium?.copyWith(color: fg)),
          Icon(Icons.arrow_drop_down, size: 18, color: fg),
        ],
      ),
    );
  }
}
