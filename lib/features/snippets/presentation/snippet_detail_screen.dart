import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/highlight/language_visuals.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/code_view.dart';
import '../../export/presentation/export_menu_button.dart';
import '../application/snippet_providers.dart';
import '../domain/snippet.dart';
import '../domain/snippet_type.dart';
import '../domain/value_objects.dart';
import 'snippet_editor_modal.dart';
import 'type_visuals.dart';
import 'widgets/label_chip.dart';
import 'widgets/snippet_history_sheet.dart';

/// Routed, full-screen detail view (with a back button on narrow layouts).
class SnippetDetailScreen extends ConsumerWidget {
  const SnippetDetailScreen({super.key, required this.snippetId});

  final String snippetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(snippetProvider(snippetId));
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text('Error: $error')),
      ),
      data: (snippet) {
        if (snippet == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Snippet not found')),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(snippet.title.isEmpty ? 'Untitled' : snippet.title),
            actions: snippetActions(
              context,
              ref,
              snippet,
              onAfterDelete: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go(RoutePaths.library);
                }
              },
            ),
          ),
          body: SnippetDetailBody(snippet: snippet),
        );
      },
    );
  }
}

/// Detail view embedded in the right pane of the wide Library layout.
class InlineSnippetDetail extends ConsumerWidget {
  const InlineSnippetDetail({super.key, required this.snippetId});

  final String snippetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(snippetProvider(snippetId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
      data: (snippet) {
        if (snippet == null) {
          return const _PaneMessage(
            icon: Icons.search_off,
            text: 'This snippet is no longer available.',
          );
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(snippet.title.isEmpty ? 'Untitled' : snippet.title),
            actions: snippetActions(
              context,
              ref,
              snippet,
              onAfterDelete: () =>
                  ref.read(selectedSnippetProvider.notifier).select(null),
            ),
          ),
          body: SnippetDetailBody(snippet: snippet),
        );
      },
    );
  }
}

/// Placeholder shown in the detail pane when nothing is selected.
class DetailPanePlaceholder extends StatelessWidget {
  const DetailPanePlaceholder({super.key});

  @override
  Widget build(BuildContext context) => const _PaneMessage(
        icon: Icons.touch_app_outlined,
        text: 'Select a snippet to view it here.',
      );
}

/// Shared AppBar actions for both the routed and inline detail views.
List<Widget> snippetActions(
  BuildContext context,
  WidgetRef ref,
  Snippet snippet, {
  required VoidCallback onAfterDelete,
}) {
  Future<void> confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete snippet?'),
        content: Text('“${snippet.title}” will be removed.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok ?? false) {
      await ref.read(snippetRepositoryProvider).softDelete(snippet.id);
      if (!context.mounted) return;
      onAfterDelete();
    }
  }

  return [
    IconButton(
      tooltip: snippet.isFavorite ? 'Unfavorite' : 'Favorite',
      icon: Icon(snippet.isFavorite ? Icons.star : Icons.star_border,
          color: snippet.isFavorite ? Colors.amber : null),
      onPressed: () => ref
          .read(snippetRepositoryProvider)
          .setFavorite(snippet.id, value: !snippet.isFavorite),
    ),
    IconButton(
      tooltip: 'History',
      icon: const Icon(Icons.history),
      onPressed: () => showSnippetHistory(context, snippetId: snippet.id),
    ),
    ExportMenuButton(snippet: snippet),
    IconButton(
      tooltip: 'Edit',
      icon: const Icon(Icons.edit_outlined),
      onPressed: () => showSnippetEditor(context, snippetId: snippet.id),
    ),
    IconButton(
      tooltip: 'Delete',
      icon: const Icon(Icons.delete_outline),
      onPressed: confirmDelete,
    ),
  ];
}

/// The scrollable content of the detail view (no Scaffold), reused by both
/// the routed screen and the inline pane.
class SnippetDetailBody extends ConsumerWidget {
  const SnippetDetailBody({super.key, required this.snippet});

  final Snippet snippet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageMap = ref.watch(languageMapProvider);
    final language = languageMap[snippet.languageId];
    final collection = ref.watch(collectionMapProvider)[snippet.collectionId];

    // Render one CodeBlock per file. Fall back to a single block synthesized
    // from the denormalized body when a snippet has no explicit files.
    final files = snippet.files;
    final fileCount = files.isEmpty ? 1 : files.length;

    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 900),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Meta line: short id + "Updated <date>".
            _MetaLine(snippet: snippet),
            const SizedBox(height: 12),
            // Labels + language, with a Snippet-style "LABELS ▾" affordance.
            Wrap(
              spacing: 8,
              runSpacing: 8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                _Meta(icon: iconForType(snippet.type), label: snippet.type.label),
                if (language != null)
                  LanguagePill(
                    languageId: snippet.languageId,
                    name: language.name,
                  ),
                if (snippet.purpose != null)
                  _Meta(icon: Icons.label_outline, label: snippet.purpose!),
                if (collection != null)
                  _Meta(icon: Icons.folder_outlined, label: collection.name),
                for (final label in snippet.labels) LabelChip(label: label),
                const _LabelsAffordance(),
              ],
            ),
            const SizedBox(height: 14),
            // Share row: a faux copyable link + copy icon + a visibility pill.
            _ShareRow(snippet: snippet),
            if (snippet.description != null &&
                snippet.description!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              _DescriptionMarkdown(data: snippet.description!),
            ],
            const SizedBox(height: 20),
            // Files section header + one CodeBlock per file.
            _FilesHeader(count: fileCount, snippetId: snippet.id),
            const SizedBox(height: 10),
            if (files.isEmpty)
              CodeBlock(
                code: snippet.body,
                grammarId: language?.grammarId,
                languageId: snippet.languageId,
                languageName: language?.name,
              )
            else
              for (var i = 0; i < files.length; i++) ...[
                if (i > 0) const SizedBox(height: 14),
                _FileBlock(file: files[i], languageMap: languageMap),
              ],
            if (snippet.type == SnippetType.aiPrompt &&
                snippet.promptMeta != null)
              _PromptMetaView(snippet: snippet),
          ],
        ),
      ),
    );
  }
}

/// Renders a snippet's description as Markdown, themed to the app surface.
class _DescriptionMarkdown extends StatelessWidget {
  const _DescriptionMarkdown({required this.data});

  final String data;

  @override
  Widget build(BuildContext context) {
    return MarkdownBody(
      data: data,
      selectable: true,
      styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
    );
  }
}

/// A single file's code "window": resolves the file's language for the header
/// badge/name and grammar, and shows the filename above the block.
class _FileBlock extends StatelessWidget {
  const _FileBlock({required this.file, required this.languageMap});

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
                  size: 15, color: theme.colorScheme.onSurfaceVariant),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  filename,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelMedium?.copyWith(
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
        ),
      ],
    );
  }
}

/// A compact relative/short date from an epoch-ms timestamp (e.g. "Jun 20" or
/// "Mar 3, 2024").
String _shortDate(int epochMs) {
  final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final now = DateTime.now();
  const months = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];
  final month = months[date.month - 1];
  return date.year == now.year
      ? '$month ${date.day}'
      : '$month ${date.day}, ${date.year}';
}

/// The Snippet-style meta line under the title: a short snippet id + the date
/// the snippet was last updated.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.snippet});

  final Snippet snippet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final shortId =
        snippet.id.length > 8 ? snippet.id.substring(0, 8) : snippet.id;
    return Row(
      children: [
        Text('#$shortId', style: muted),
        const SizedBox(width: 8),
        Text('·', style: muted),
        const SizedBox(width: 8),
        Text('Updated ${_shortDate(snippet.updatedAt)}', style: muted),
      ],
    );
  }
}

/// A non-interactive "LABELS ▾" affordance sitting alongside the label chips,
/// echoing Snippet's label dropdown trigger.
class _LabelsAffordance extends StatelessWidget {
  const _LabelsAffordance();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: 'Manage labels — coming soon',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LABELS',
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
            const SizedBox(width: 2),
            Icon(Icons.arrow_drop_down,
                size: 16, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

/// Snippet-style share row: a faux copyable link (`snippet/<id>`), a copy
/// button that copies the link, and a "Private" pill with a lock glyph.
class _ShareRow extends StatelessWidget {
  const _ShareRow({required this.snippet});

  final Snippet snippet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final link = 'snippet/${snippet.id}';
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Row(
              children: [
                Icon(Icons.link_rounded,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    link,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: AppTheme.monoFamily,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                _LinkCopyButton(text: link),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _VisibilityPill(visibility: snippet.visibility),
      ],
    );
  }
}

/// Small copy-to-clipboard button (used by the share row) that flips to a
/// check mark briefly after copying.
class _LinkCopyButton extends StatefulWidget {
  const _LinkCopyButton({required this.text});

  final String text;

  @override
  State<_LinkCopyButton> createState() => _LinkCopyButtonState();
}

class _LinkCopyButtonState extends State<_LinkCopyButton> {
  bool _copied = false;

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: widget.text));
    if (!mounted) return;
    setState(() => _copied = true);
    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (mounted) setState(() => _copied = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      tooltip: 'Copy link',
      visualDensity: VisualDensity.compact,
      iconSize: 16,
      onPressed: _copy,
      icon: Icon(
        _copied ? Icons.check_rounded : Icons.copy_rounded,
        color: _copied ? AppTheme.accent : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

/// A visibility pill reflecting the snippet's real [SnippetVisibility]: a lock
/// glyph + "Private", or a globe glyph + "Public" tinted with the brand accent.
class _VisibilityPill extends StatelessWidget {
  const _VisibilityPill({required this.visibility});

  final SnippetVisibility visibility;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isPrivate = visibility == SnippetVisibility.private;
    final fg = isPrivate ? theme.colorScheme.onSurfaceVariant : AppTheme.accent;
    final bg = isPrivate
        ? theme.colorScheme.surfaceContainerHighest
        : AppTheme.accent.withValues(alpha: 0.14);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPrivate ? Icons.lock_outline : Icons.public,
              size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            isPrivate ? 'Private' : 'Public',
            style: theme.textTheme.labelMedium?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// The "Files (n)" section header with an "ADD FILE" affordance that opens the
/// snippet editor (where files are added/edited).
class _FilesHeader extends StatelessWidget {
  const _FilesHeader({required this.count, required this.snippetId});

  final int count;
  final String snippetId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Text(
          'Files ($count)',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const Spacer(),
        Tooltip(
          message: 'History',
          child: TextButton.icon(
            onPressed: () => showSnippetHistory(context, snippetId: snippetId),
            icon: const Icon(Icons.history, size: 16),
            label: const Text('HISTORY'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accent,
              textStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
        const SizedBox(width: 4),
        Tooltip(
          message: 'Add file',
          child: TextButton.icon(
            onPressed: () => showSnippetEditor(context, snippetId: snippetId),
            icon: const Icon(Icons.add, size: 16),
            label: const Text('ADD FILE'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accent,
              textStyle: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              visualDensity: VisualDensity.compact,
            ),
          ),
        ),
      ],
    );
  }
}

class _PromptMetaView extends StatelessWidget {
  const _PromptMetaView({required this.snippet});

  final Snippet snippet;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final meta = snippet.promptMeta!;
    final rows = <Widget>[
      if (meta.modelProvider != null) _kv('Provider', meta.modelProvider!),
      if (meta.targetModel != null) _kv('Model', meta.targetModel!),
      if (meta.temperature != null)
        _kv('Temperature', meta.temperature!.toString()),
      if (meta.maxTokens != null) _kv('Max tokens', meta.maxTokens!.toString()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text('Prompt settings', style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...rows,
        if (meta.systemPrompt != null &&
            meta.systemPrompt!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text('System prompt', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(meta.systemPrompt!, style: theme.textTheme.bodyMedium),
        ],
        if (meta.variables.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('Variables', style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final v in meta.variables)
                Chip(
                  avatar: const Icon(Icons.data_object, size: 16),
                  label: Text(v.name),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text('$k: $v'),
      );
}

class _Meta extends StatelessWidget {
  const _Meta({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 6),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _PaneMessage extends StatelessWidget {
  const _PaneMessage({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 48, color: theme.colorScheme.outline),
          const SizedBox(height: 12),
          Text(text,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        ],
      ),
    );
  }
}
