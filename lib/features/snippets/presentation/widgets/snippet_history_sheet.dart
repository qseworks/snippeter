import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/code_view.dart';
import '../../application/snippet_providers.dart';
import '../../domain/snippet.dart';
import '../../domain/value_objects.dart';

/// Opens the per-snippet version history as a right-side sheet. Lists saved
/// versions newest-first; each entry can be expanded to preview its files and
/// restored as the snippet's current files. The detail view updates reactively
/// after a restore, so the caller need not refresh anything.
Future<void> showSnippetHistory(
  BuildContext context, {
  required String snippetId,
}) {
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'History',
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 220),
    pageBuilder: (context, _, _) => _SnippetHistorySheet(snippetId: snippetId),
    transitionBuilder: (context, animation, _, child) {
      final curved = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
        reverseCurve: Curves.easeInCubic,
      );
      return Align(
        alignment: Alignment.centerRight,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

class _SnippetHistorySheet extends ConsumerStatefulWidget {
  const _SnippetHistorySheet({required this.snippetId});

  final String snippetId;

  @override
  ConsumerState<_SnippetHistorySheet> createState() =>
      _SnippetHistorySheetState();
}

class _SnippetHistorySheetState extends ConsumerState<_SnippetHistorySheet> {
  late Future<List<SnippetVersion>> _future;

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<SnippetVersion>> _load() =>
      ref.read(snippetRepositoryProvider).getVersions(widget.snippetId);

  Future<void> _restore(int savedAt) async {
    await ref
        .read(snippetRepositoryProvider)
        .restoreVersion(widget.snippetId, savedAt);
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final width = MediaQuery.sizeOf(context).width;
    final sheetWidth = width < 560 ? width : 460.0;

    return Align(
      alignment: Alignment.centerRight,
      child: Material(
        color: theme.colorScheme.surface,
        elevation: 8,
        child: SafeArea(
          child: SizedBox(
            width: sheetWidth,
            height: double.infinity,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header.
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 8, 12),
                  child: Row(
                    children: [
                      Icon(Icons.history,
                          size: 20, color: theme.colorScheme.onSurface),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'History',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        tooltip: 'Close',
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: FutureBuilder<List<SnippetVersion>>(
                    future: _future,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      if (snapshot.hasError) {
                        return _EmptyState(
                          icon: Icons.error_outline,
                          text: 'Could not load history.\n${snapshot.error}',
                        );
                      }
                      final versions = snapshot.data ?? const [];
                      if (versions.isEmpty) {
                        return const _EmptyState(
                          icon: Icons.history_toggle_off,
                          text: 'No history yet',
                        );
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(12),
                        itemCount: versions.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (context, i) => _VersionTile(
                          version: versions[i],
                          isLatest: i == 0,
                          onRestore: () => _restore(versions[i].savedAt),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// A single version: header row (timestamp + file summary) that expands to a
/// read-only preview of each file, plus a Restore action.
class _VersionTile extends ConsumerWidget {
  const _VersionTile({
    required this.version,
    required this.isLatest,
    required this.onRestore,
  });

  final SnippetVersion version;
  final bool isLatest;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final languageMap = ref.watch(languageMapProvider);
    final files = version.files;
    final summary = _summary(files);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        // Drop the default ExpansionTile dividers for a cleaner card look.
        data: theme.copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
          title: Row(
            children: [
              Expanded(
                child: Text(
                  _formatTimestamp(version.savedAt),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (isLatest)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Latest',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: AppTheme.accent,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              summary,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          children: [
            for (var i = 0; i < files.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _VersionFilePreview(
                file: files[i],
                languageMap: languageMap,
              ),
            ],
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: FilledButton.tonalIcon(
                onPressed: onRestore,
                icon: const Icon(Icons.restore, size: 18),
                label: const Text('Restore'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _summary(List<SnippetFile> files) {
    if (files.isEmpty) return 'No files';
    final count = files.length;
    final label = count == 1 ? '1 file' : '$count files';
    final first = files.first.filename.trim();
    return first.isEmpty ? label : '$label · $first';
  }
}

/// Read-only preview of a single file within a version: filename caption over a
/// [CodeBlock] reused from the detail view.
class _VersionFilePreview extends StatelessWidget {
  const _VersionFilePreview({required this.file, required this.languageMap});

  final SnippetFile file;
  final Map<String, Language> languageMap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final language =
        file.languageId == null ? null : languageMap[file.languageId];
    final filename = file.filename.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (filename.isNotEmpty) ...[
          Row(
            children: [
              Icon(Icons.insert_drive_file_outlined,
                  size: 14, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  filename,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppTheme.monoFamily,
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
        ],
        CodeBlock(
          code: file.content,
          grammarId: language?.grammarId,
          languageId: file.languageId,
          languageName: language?.name,
          fontSize: 12.5,
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 44, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

/// Formats an epoch-ms (UTC) timestamp into a readable local date + time, e.g.
/// "Jun 20, 2026 · 14:32".
String _formatTimestamp(int epochMs) {
  final dt = DateTime.fromMillisecondsSinceEpoch(epochMs).toLocal();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = months[dt.month - 1];
  final hh = dt.hour.toString().padLeft(2, '0');
  final mm = dt.minute.toString().padLeft(2, '0');
  return '$month ${dt.day}, ${dt.year} · $hh:$mm';
}
