import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../core/highlight/language_visuals.dart';
import '../../../core/theme/app_theme.dart';
import '../../snippets/application/snippet_providers.dart';
import '../../snippets/domain/snippet_query.dart';
import '../../snippets/domain/snippet_type.dart';
import '../../snippets/domain/value_objects.dart';
import '../../snippets/presentation/type_visuals.dart';

/// Search field + filter chips + sort for the Library tab. All controls drive
/// [libraryQueryProvider]; the list rebuilds reactively.
class LibraryFilterBar extends ConsumerWidget {
  const LibraryFilterBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
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
        padding: const EdgeInsetsDirectional.fromSTEB(12, 10, 12, 8),
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
              alignment: AlignmentDirectional.centerStart,
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _FilterChipMenu<SnippetType?>(
                    icon: Icons.category_outlined,
                    label: query.type == null
                        ? l10n.filterTypeChipDefault
                        : labelForType(l10n, query.type!),
                    active: query.type != null,
                    value: query.type,
                    items: [
                      PopupMenuItem(
                          value: null, child: Text(l10n.filterAllTypes)),
                      for (final t in SnippetType.values)
                        PopupMenuItem(value: t, child: Text(labelForType(l10n, t))),
                    ],
                    onSelected: controller.setType,
                  ),
                  _FilterChipMenu<String?>(
                    icon: Icons.translate,
                    label: _nameOf(languages, query.languageId) ??
                        l10n.filterLanguageChipDefault,
                    active: query.languageId != null,
                    value: query.languageId,
                    leading: query.languageId == null
                        ? null
                        : LanguageBadge(languageId: query.languageId, size: 16),
                    items: [
                      PopupMenuItem(
                          value: null, child: Text(l10n.filterAllLanguages)),
                      for (final l in languages)
                        PopupMenuItem(value: l.id, child: Text(l.name)),
                    ],
                    onSelected: controller.setLanguage,
                  ),
                  _FilterChipMenu<String?>(
                    icon: Icons.folder_outlined,
                    label: _collectionName(collections, query.collectionId) ??
                        l10n.filterCollectionChipDefault,
                    active: query.collectionId != null,
                    value: query.collectionId,
                    items: [
                      PopupMenuItem(
                          value: null, child: Text(l10n.filterAllCollections)),
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
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 150),
                    switchInCurve: Curves.easeOut,
                    switchOutCurve: Curves.easeOut,
                    transitionBuilder: (child, animation) =>
                        ScaleTransition(scale: animation, child: child),
                    child: query.hasFilters
                        ? ActionChip(
                            key: const ValueKey('clear-filters'),
                            avatar: const Icon(Icons.clear, size: 16),
                            label: Text(l10n.filterClearChip),
                            onPressed: controller.clearFilters,
                          )
                        : const SizedBox.shrink(),
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
    final l10n = AppLocalizations.of(context);
    return TextField(
      controller: _controller,
      // Shared focus node so the global Cmd/Ctrl+F shortcut can focus search.
      focusNode: ref.watch(searchFocusProvider),
      onChanged: _onChanged,
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: l10n.filterSearchHint,
        prefixIcon: const Icon(Icons.search),
        isDense: true,
        // Zero-min so the empty state reserves no space; the animated close
        // button keeps its own tap target when present.
        suffixIconConstraints: const BoxConstraints(),
        suffixIcon: AnimatedSwitcher(
          duration: const Duration(milliseconds: 150),
          switchInCurve: Curves.easeOut,
          switchOutCurve: Curves.easeOut,
          transitionBuilder: (child, animation) =>
              ScaleTransition(scale: animation, child: child),
          child: _controller.text.isEmpty
              ? const SizedBox.shrink()
              : IconButton(
                  key: const ValueKey('clear-search'),
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    _controller.clear();
                    _onChanged('');
                    setState(() {});
                  },
                ),
        ),
      ),
    );
  }
}

class _SortButton extends StatelessWidget {
  const _SortButton({required this.value, required this.onChanged});

  final SnippetSort value;
  final ValueChanged<SnippetSort> onChanged;

  static Map<SnippetSort, String> _labels(AppLocalizations l10n) => {
        SnippetSort.recent: l10n.filterSortRecentlyUpdated,
        SnippetSort.created: l10n.filterSortRecentlyCreated,
        SnippetSort.titleAsc: l10n.filterSortTitleAsc,
        SnippetSort.relevance: l10n.filterSortRelevance,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<SnippetSort>(
      tooltip: l10n.commonSort,
      icon: const Icon(Icons.sort),
      initialValue: value,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final entry in _labels(l10n).entries)
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
    final l10n = AppLocalizations.of(context);
    final chosen = {...selected};
    var all = matchAll;
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.filterByLabelsDialogTitle),
          content: SizedBox(
            width: 320,
            child: labels.isEmpty
                ? Text(l10n.filterNoLabelsYet)
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(l10n.filterMatchLabel),
                          const SizedBox(width: 8),
                          SegmentedButton<bool>(
                            segments: [
                              ButtonSegment(
                                  value: false,
                                  label: Text(l10n.filterMatchAny)),
                              ButtonSegment(
                                  value: true,
                                  label: Text(l10n.filterMatchAll)),
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
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonApply),
            ),
          ],
        ),
      ),
    );
    if ((result ?? false)) onApply(chosen.toList(), all);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final label = selected.isEmpty
        ? l10n.filterLabelsChipDefault
        : l10n.filterLabelsChipWithCount(selected.length);
    return InkWell(
      borderRadius: BorderRadius.circular(AppTheme.radiusPill),
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
    final scheme = theme.colorScheme;
    final fg = active ? scheme.primary : scheme.onSurfaceVariant;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      padding: const EdgeInsets.fromLTRB(10, 6, 6, 6),
      decoration: BoxDecoration(
        color: active
            ? scheme.primary.withValues(alpha: 0.12)
            : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(
          color:
              active ? scheme.primary.withValues(alpha: 0.45) : scheme.outlineVariant,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          leading ?? Icon(icon, size: 15, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.labelMedium
                ?.copyWith(color: fg, fontWeight: FontWeight.w600),
          ),
          Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: fg),
        ],
      ),
    );
  }
}
