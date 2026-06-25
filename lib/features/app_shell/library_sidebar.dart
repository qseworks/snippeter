import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../core/routing/route_paths.dart';
import '../../core/theme/app_theme.dart';
import '../auth/application/auth_providers.dart';
import '../import/gist_import_dialog.dart';
import '../snippets/application/snippet_providers.dart';
import '../sync/application/sync_providers.dart';
import '../snippets/domain/snippet_query.dart';
import '../snippets/domain/value_objects.dart';
import '../snippets/presentation/snippet_editor_modal.dart';
import '../snippets/presentation/widgets/label_chip.dart';

/// The dark Snippet-style sidebar: header, NEW SNIPPET button, nav items with
/// counts, and the LABELS / LANGUAGES filter sections. Drives the library query
/// via [libraryQueryProvider] and highlights the active selection.
class LibrarySidebar extends ConsumerWidget {
  const LibrarySidebar({super.key, this.inDrawer = false});

  /// When rendered inside a [Drawer] (narrow layout) taps should close it.
  final bool inDrawer;

  void _closeDrawerIfNeeded(BuildContext context) {
    if (inDrawer) Navigator.of(context).maybePop();
  }

  /// Ensures we're on /library before applying a filter (the filter is a no-op
  /// visually while Settings is showing).
  void _goLibrary(BuildContext context) {
    if (GoRouterState.of(context).uri.path != RoutePaths.library) {
      context.go(RoutePaths.library);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final stats = ref.watch(libraryStatsProvider);
    final query = ref.watch(libraryQueryProvider);
    final controller = ref.read(libraryQueryProvider.notifier);
    final labels = ref.watch(labelsProvider).value ?? const <Label>[];
    final languageMap = ref.watch(languageMapProvider);

    // Derive which nav item / filter is active from the current query.
    final active = _ActiveSelection.fromQuery(query);

    return Material(
      color: AppTheme.sidebarBg,
      child: SafeArea(
        right: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header.
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 14, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.sidebarPersonalLibraryTitle,
                      style: const TextStyle(
                        color: AppTheme.sidebarText,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.1,
                      ),
                    ),
                  ),
                  _SyncIndicator(onCloseDrawer: () => _closeDrawerIfNeeded(context)),
                  IconButton(
                    tooltip: l10n.sidebarImportFromGistTooltip,
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    color: AppTheme.sidebarMuted,
                    icon: const Icon(Icons.cloud_download_outlined),
                    onPressed: () => showGistImportDialog(context),
                  ),
                  IconButton(
                    tooltip: l10n.commonRefresh,
                    visualDensity: VisualDensity.compact,
                    iconSize: 18,
                    color: AppTheme.sidebarMuted,
                    icon: const Icon(Icons.refresh),
                    onPressed: () => ref.invalidate(allSnippetsProvider),
                  ),
                ],
              ),
            ),
            // NEW SNIPPET.
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  onPressed: () {
                    _closeDrawerIfNeeded(context);
                    showSnippetEditor(context);
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: Text(l10n.sidebarNewSnippetButton),
                ),
              ),
            ),
            // Scrollable nav + sections.
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: 8),
                children: [
                  _NavItem(
                    icon: Icons.inbox_outlined,
                    label: l10n.sidebarNavAllSnippets,
                    count: stats.total,
                    selected: active.isAll(),
                    onTap: () {
                      _goLibrary(context);
                      controller.showAll();
                      _closeDrawerIfNeeded(context);
                    },
                  ),
                  _NavItem(
                    icon: Icons.star_outline,
                    label: l10n.sidebarNavStarred,
                    count: stats.starred,
                    selected: active.isStarred(),
                    onTap: () {
                      _goLibrary(context);
                      controller.showStarred();
                      _closeDrawerIfNeeded(context);
                    },
                  ),
                  _NavItem(
                    icon: Icons.label_off_outlined,
                    label: l10n.sidebarNavUnlabeled,
                    count: stats.unlabeled,
                    selected: active.isUnlabeled(),
                    onTap: () {
                      _goLibrary(context);
                      controller.showUnlabeled();
                      _closeDrawerIfNeeded(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SectionHeader(
                    title: l10n.sidebarSectionLabels,
                    trailing: _SectionAction(
                      icon: Icons.add,
                      tooltip: l10n.sidebarCreateLabelTooltip,
                      onTap: () => _showCreateLabelDialog(context, ref),
                    ),
                  ),
                  _LabelTree(
                    labels: labels,
                    stats: stats,
                    active: active,
                    onSelect: (id) {
                      _goLibrary(context);
                      controller.selectLabel(id);
                      _closeDrawerIfNeeded(context);
                    },
                  ),
                  const SizedBox(height: 12),
                  _SectionHeader(title: l10n.sidebarSectionLanguages),
                  for (final entry in stats.byLanguageId.entries)
                    if (entry.value > 0)
                      _LanguageRow(
                        name: languageMap[entry.key]?.name ?? entry.key,
                        count: entry.value,
                        selected: active.isLanguage(entry.key),
                        onTap: () {
                          _goLibrary(context);
                          controller.selectLanguage(entry.key);
                          _closeDrawerIfNeeded(context);
                        },
                      ),
                ],
              ),
            ),
            const Divider(height: 1, color: AppTheme.sidebarSelected),
            // Settings gear.
            _NavItem(
              icon: Icons.settings_outlined,
              label: l10n.sidebarNavSettings,
              selected:
                  GoRouterState.of(context).uri.path == RoutePaths.settings,
              onTap: () {
                context.go(RoutePaths.settings);
                _closeDrawerIfNeeded(context);
              },
            ),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }

  Future<void> _showCreateLabelDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final l10n = AppLocalizations.of(context);
    final nameController = TextEditingController();
    // Existing labels offered as possible parents. Only top-level labels are
    // offered so we keep the hierarchy at a single level of nesting (Snippet-like).
    final labels = ref.read(labelsProvider).value ?? const <Label>[];
    final parentChoices = [
      for (final l in labels)
        if (l.parentId == null) l,
    ];
    // A small Snippet-like palette to choose from.
    const palette = [
      Color(0xFF16B378),
      Color(0xFFE5484D),
      Color(0xFF8E4EC6),
      Color(0xFFFFB224),
      Color(0xFF12A594),
      Color(0xFF3E63DD),
      Color(0xFFE93D82),
      Color(0xFF5753C6),
    ];
    var selectedColor = palette.first;
    String? selectedParentId;

    final created = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(l10n.sidebarNewLabelDialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: InputDecoration(hintText: l10n.sidebarLabelNameHint),
              ),
              if (parentChoices.isNotEmpty) ...[
                const SizedBox(height: 16),
                DropdownButtonFormField<String?>(
                  initialValue: selectedParentId,
                  isExpanded: true,
                  decoration:
                      InputDecoration(labelText: l10n.sidebarParentLabelDropdownLabel),
                  items: [
                    DropdownMenuItem<String?>(
                      value: null,
                      child: Text(l10n.sidebarParentLabelNone),
                    ),
                    for (final p in parentChoices)
                      DropdownMenuItem<String?>(
                        value: p.id,
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            LabelDot(color: labelColor(p)),
                            const SizedBox(width: 8),
                            Flexible(
                              child: Text(
                                p.name,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                  onChanged: (value) =>
                      setState(() => selectedParentId = value),
                ),
              ],
              const SizedBox(height: 16),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  for (final c in palette)
                    GestureDetector(
                      onTap: () => setState(() => selectedColor = c),
                      child: Container(
                        width: 26,
                        height: 26,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: selectedColor == c
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.commonCreate),
            ),
          ],
        ),
      ),
    );

    if ((created ?? false) && nameController.text.trim().isNotEmpty) {
      final hex = '#${(selectedColor.toARGB32() & 0xFFFFFF)
          .toRadixString(16)
          .padLeft(6, '0')
          .toUpperCase()}';
      await ref.read(snippetRepositoryProvider).createLabel(
            nameController.text.trim(),
            color: hex,
            parentId: selectedParentId,
          );
    }
    nameController.dispose();
  }
}

/// Compact auth+sync status chip shown in the sidebar header.
///
/// * Supabase unconfigured ([authServiceProvider] null) -> hidden entirely; the
///   app is running local-only and there's nothing to indicate.
/// * Signed out -> a subtle "cloud-off" icon, tooltip "Not syncing — sign in",
///   tapping opens Settings (where sign-in lives).
/// * Signed in -> a "cloud done" icon, tooltip shows the email, tapping triggers
///   an immediate [SupabaseSyncService.syncOnce].
class _SyncIndicator extends ConsumerWidget {
  const _SyncIndicator({required this.onCloseDrawer});

  final VoidCallback onCloseDrawer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    // No backend configured: keep the header clean, render nothing.
    if (ref.watch(authServiceProvider) == null) {
      return const SizedBox.shrink();
    }

    final user = ref.watch(currentUserProvider);
    final signedIn = user != null;

    final IconData icon;
    final Color color;
    final String tooltip;
    final VoidCallback onTap;

    if (signedIn) {
      icon = Icons.cloud_done_outlined;
      color = AppTheme.accent;
      tooltip = l10n.sidebarSyncingAsTooltip(
          user.email ?? l10n.sidebarSyncAccountFallback);
      onTap = () => ref.read(syncServiceProvider)?.syncOnce();
    } else {
      icon = Icons.cloud_off_outlined;
      color = AppTheme.sidebarSection;
      tooltip = l10n.sidebarNotSyncingTooltip;
      onTap = () {
        context.go(RoutePaths.settings);
        onCloseDrawer();
      };
    }

    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        hoverColor: AppTheme.sidebarHover,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(icon, size: 18, color: color),
        ),
      ),
    );
  }
}

enum _ActiveKind { all, starred, unlabeled, label, language, none }

/// Which sidebar entry is currently "active", derived from the live query.
class _ActiveSelection {
  const _ActiveSelection(this.kind, [this.id]);

  final _ActiveKind kind;
  final String? id;

  static const all = _ActiveSelection(_ActiveKind.all);
  static const starred = _ActiveSelection(_ActiveKind.starred);
  static const unlabeled = _ActiveSelection(_ActiveKind.unlabeled);

  bool isAll() => kind == _ActiveKind.all;
  bool isStarred() => kind == _ActiveKind.starred;
  bool isUnlabeled() => kind == _ActiveKind.unlabeled;
  bool isLabel(String labelId) => kind == _ActiveKind.label && id == labelId;
  bool isLanguage(String langId) =>
      kind == _ActiveKind.language && id == langId;

  static _ActiveSelection fromQuery(SnippetQuery q) {
    if (q.favoritesOnly) return starred;
    if (q.unlabeled) return unlabeled;
    if (q.labelIds.length == 1) {
      return _ActiveSelection(_ActiveKind.label, q.labelIds.first);
    }
    if (q.languageId != null) {
      return _ActiveSelection(_ActiveKind.language, q.languageId);
    }
    if (!q.hasFilters) return all;
    return const _ActiveSelection(_ActiveKind.none);
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.count,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int? count;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppTheme.sidebarText : AppTheme.sidebarMuted;
    return _SidebarRow(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 18, color: fg),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          if (count != null) _CountBadge(count: count!, selected: selected),
        ],
      ),
    );
  }
}

/// Renders the LABELS section as a nested tree built from [Label.parentId].
/// Top-level labels (parentId == null) are roots; a label that has children
/// shows an expand/collapse chevron and renders its children indented below it.
/// Expand state is local to this widget.
class _LabelTree extends StatefulWidget {
  const _LabelTree({
    required this.labels,
    required this.stats,
    required this.active,
    required this.onSelect,
  });

  final List<Label> labels;
  final LibraryStats stats;
  final _ActiveSelection active;
  final ValueChanged<String> onSelect;

  @override
  State<_LabelTree> createState() => _LabelTreeState();
}

class _LabelTreeState extends State<_LabelTree> {
  /// Ids of parent labels whose children are currently expanded.
  final Set<String> _expanded = <String>{};

  @override
  Widget build(BuildContext context) {
    // Group children by parent id; preserve the incoming (stream) order.
    final childrenByParent = <String, List<Label>>{};
    final roots = <Label>[];
    final ids = {for (final l in widget.labels) l.id};
    for (final label in widget.labels) {
      final parentId = label.parentId;
      // Treat a label whose parent is missing (or self-referential) as a root.
      if (parentId == null || parentId == label.id || !ids.contains(parentId)) {
        roots.add(label);
      } else {
        (childrenByParent[parentId] ??= <Label>[]).add(label);
      }
    }

    final rows = <Widget>[];
    for (final root in roots) {
      final children = childrenByParent[root.id] ?? const <Label>[];
      final hasChildren = children.isNotEmpty;
      final expanded = _expanded.contains(root.id);
      rows.add(
        _LabelRow(
          label: root,
          count: widget.stats.byLabelId[root.id] ?? 0,
          selected: widget.active.isLabel(root.id),
          onTap: () => widget.onSelect(root.id),
          hasChildren: hasChildren,
          expanded: expanded,
          onToggleExpand: hasChildren
              ? () => setState(() {
                    if (!_expanded.remove(root.id)) _expanded.add(root.id);
                  })
              : null,
        ),
      );
      if (hasChildren && expanded) {
        for (final child in children) {
          rows.add(
            _LabelRow(
              label: child,
              count: widget.stats.byLabelId[child.id] ?? 0,
              selected: widget.active.isLabel(child.id),
              onTap: () => widget.onSelect(child.id),
              depth: 1,
            ),
          );
        }
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: rows,
    );
  }
}

class _LabelRow extends StatelessWidget {
  const _LabelRow({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
    this.depth = 0,
    this.hasChildren = false,
    this.expanded = false,
    this.onToggleExpand,
  });

  final Label label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  /// Nesting depth; child rows are indented relative to their parent.
  final int depth;

  /// Whether this row has expandable children (shows a chevron).
  final bool hasChildren;

  /// Whether this row's children are currently shown.
  final bool expanded;

  /// Toggles the children's visibility; null when there are no children.
  final VoidCallback? onToggleExpand;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppTheme.sidebarText : AppTheme.sidebarMuted;
    // Reserve a fixed-width slot for the chevron so dots align across rows.
    final Widget chevron = SizedBox(
      width: 18,
      child: hasChildren
          ? InkWell(
              onTap: onToggleExpand,
              borderRadius: BorderRadius.circular(4),
              child: Icon(
                expanded
                    ? Icons.expand_more
                    : (Directionality.of(context) == TextDirection.rtl
                        ? Icons.chevron_left
                        : Icons.chevron_right),
                size: 16,
                color: AppTheme.sidebarMuted,
              ),
            )
          : null,
    );

    return _SidebarRow(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(width: depth * 16.0),
          chevron,
          LabelDot(color: labelColor(label)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label.name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          _CountBadge(count: count, selected: selected),
        ],
      ),
    );
  }
}

class _LanguageRow extends StatelessWidget {
  const _LanguageRow({
    required this.name,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String name;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fg = selected ? AppTheme.sidebarText : AppTheme.sidebarMuted;
    return _SidebarRow(
      selected: selected,
      onTap: onTap,
      child: Row(
        children: [
          Text('#',
              style: TextStyle(
                  color: AppTheme.sidebarSection,
                  fontSize: 13,
                  fontWeight: FontWeight.w700)),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: fg,
                fontSize: 13,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
            ),
          ),
          _CountBadge(count: count, selected: selected),
        ],
      ),
    );
  }
}

/// Shared interactive row with the selected-state lighter bg + 3px green bar.
class _SidebarRow extends StatelessWidget {
  const _SidebarRow({
    required this.child,
    required this.selected,
    required this.onTap,
  });

  final Widget child;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
      child: Material(
        color: selected ? AppTheme.sidebarSelected : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          hoverColor: AppTheme.sidebarHover,
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
            padding: const EdgeInsetsDirectional.fromSTEB(11, 9, 12, 9),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CountBadge extends StatelessWidget {
  const _CountBadge({required this.count, required this.selected});

  final int count;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$count',
      style: TextStyle(
        color: selected ? AppTheme.sidebarText : AppTheme.sidebarSection,
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(19, 6, 12, 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: AppTheme.sidebarSection,
                fontSize: 10.5,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ?trailing,
        ],
      ),
    );
  }
}

class _SectionAction extends StatelessWidget {
  const _SectionAction({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(6),
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: Icon(icon, size: 16, color: AppTheme.sidebarMuted),
        ),
      ),
    );
  }
}
