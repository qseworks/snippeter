import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../../../core/config/supabase_config.dart';
import '../../../core/highlight/language_visuals.dart';
import '../../../core/notebook/ipynb.dart';
import '../../../core/routing/route_paths.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/async_states.dart';
import '../../../core/widgets/code_view.dart';
import '../../export/presentation/export_menu_button.dart';
import '../application/snippet_providers.dart';
import '../data/prompt_variables.dart';
import '../domain/snippet.dart';
import '../domain/snippet_type.dart';
import '../domain/value_objects.dart';
import 'snippet_editor_modal.dart';
import 'type_visuals.dart';
import 'widgets/label_chip.dart';
import 'widgets/notebook_view.dart';
import 'widgets/prompt_fill_panel.dart';
import 'widgets/snippet_copy.dart';
import 'widgets/snippet_history_sheet.dart';

/// Routed, full-screen detail view (with a back button on narrow layouts).
class SnippetDetailScreen extends ConsumerWidget {
  const SnippetDetailScreen({super.key, required this.snippetId});

  final String snippetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(snippetProvider(snippetId));
    return async.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: AppErrorState(
          message: l10n.settingsGenericError,
          onRetry: () => ref.invalidate(snippetProvider(snippetId)),
        ),
      ),
      data: (snippet) {
        if (snippet == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.detailSnippetNotFound)),
          );
        }
        return Scaffold(
          appBar: AppBar(
            title: Text(snippet.title.isEmpty ? l10n.detailUntitledTitle : snippet.title),
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
    final l10n = AppLocalizations.of(context);
    final async = ref.watch(snippetProvider(snippetId));
    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => AppErrorState(
        message: l10n.settingsGenericError,
        onRetry: () => ref.invalidate(snippetProvider(snippetId)),
      ),
      data: (snippet) {
        if (snippet == null) {
          return _PaneMessage(
            icon: Icons.search_off,
            text: l10n.detailSnippetUnavailable,
          );
        }
        return Scaffold(
          appBar: AppBar(
            automaticallyImplyLeading: false,
            title: Text(snippet.title.isEmpty ? l10n.detailUntitledTitle : snippet.title),
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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return _PaneMessage(
      icon: Icons.touch_app_outlined,
      text: l10n.detailSelectSnippetPlaceholder,
    );
  }
}

/// Shared AppBar actions for both the routed and inline detail views.
List<Widget> snippetActions(
  BuildContext context,
  WidgetRef ref,
  Snippet snippet, {
  required VoidCallback onAfterDelete,
}) {
  final l10n = AppLocalizations.of(context);
  Future<void> confirmDelete() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.detailDeleteSnippetTitle),
        content: Text(l10n.detailDeleteSnippetConfirm(snippet.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(l10n.commonDelete),
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
      tooltip: snippet.isFavorite
          ? l10n.detailUnfavoriteTooltip
          : l10n.detailFavoriteTooltip,
      icon: Icon(snippet.isFavorite ? Icons.star : Icons.star_border,
          color: snippet.isFavorite ? Colors.amber : null),
      onPressed: () => ref
          .read(snippetRepositoryProvider)
          .setFavorite(snippet.id, value: !snippet.isFavorite),
    ),
    IconButton(
      tooltip: l10n.detailHistoryTooltip,
      icon: const Icon(Icons.history),
      onPressed: () => showSnippetHistory(context, snippetId: snippet.id),
    ),
    ExportMenuButton(snippet: snippet),
    IconButton(
      tooltip: l10n.commonEdit,
      icon: const Icon(Icons.edit_outlined),
      onPressed: () => showSnippetEditor(context, snippetId: snippet.id),
    ),
    IconButton(
      tooltip: l10n.detailDeleteTooltip,
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
    final l10n = AppLocalizations.of(context);
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
                _Meta(
                    icon: iconForType(snippet.type),
                    label: labelForType(l10n, snippet.type)),
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
                _LabelsAffordance(snippetId: snippet.id),
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
            _FilesHeader(
              count: fileCount,
              snippet: snippet,
              languageMap: languageMap,
            ),
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
            _AttachmentsSection(snippetId: snippet.id),
          ],
        ),
      ),
    );
  }
}

/// Watches a snippet's attachments and, when there are any, renders an
/// "Attachments" section: each row shows a thumbnail (for images) or a file
/// icon, the filename, a human-readable size, and a delete button. Renders
/// nothing while loading/empty so the section only appears when relevant.
class _AttachmentsSection extends ConsumerWidget {
  const _AttachmentsSection({required this.snippetId});

  final String snippetId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final attachments =
        ref.watch(attachmentsProvider(snippetId)).value ?? const [];
    if (attachments.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(
          l10n.detailAttachmentsHeader(attachments.length),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        for (final a in attachments)
          _AttachmentTile(
            attachment: a,
            onDelete: () =>
                ref.read(snippetRepositoryProvider).deleteAttachment(a.id),
          ),
      ],
    );
  }
}

/// One attachment row: image thumbnail or file-type icon, filename, size, and
/// a delete IconButton.
class _AttachmentTile extends StatelessWidget {
  const _AttachmentTile({required this.attachment, required this.onDelete});

  final Attachment attachment;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final isImage = attachment.mimeType.startsWith('image/');
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: SizedBox(
              width: 40,
              height: 40,
              // Image.memory is fine here — the no-raster rule only applies to
              // the export card. Fall back to a file icon if decoding fails.
              child: isImage
                  ? Image.memory(
                      attachment.bytes,
                      width: 40,
                      height: 40,
                      fit: BoxFit.cover,
                      gaplessPlayback: true,
                      errorBuilder: (context, error, stack) =>
                          _FileIcon(color: theme.colorScheme.onSurfaceVariant),
                    )
                  : _FileIcon(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  attachment.filename,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  _humanSize(attachment.sizeBytes),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            tooltip: l10n.detailDeleteAttachmentTooltip,
            visualDensity: VisualDensity.compact,
            iconSize: 18,
            onPressed: onDelete,
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  const _FileIcon({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(Icons.insert_drive_file_outlined, size: 24, color: color),
    );
  }
}

/// Formats a byte count as a short human-readable string (e.g. "12 B",
/// "3.4 KB", "1.2 MB").
String _humanSize(int bytes) {
  if (bytes < 1024) return '$bytes B';
  const units = ['KB', 'MB', 'GB', 'TB'];
  var size = bytes / 1024;
  var unit = 0;
  while (size >= 1024 && unit < units.length - 1) {
    size /= 1024;
    unit++;
  }
  final value = size >= 100 ? size.toStringAsFixed(0) : size.toStringAsFixed(1);
  return '$value ${units[unit]}';
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

    // Jupyter notebooks (.ipynb) get a rich, cell-by-cell rendering when the
    // content parses as a notebook; otherwise we fall back to a raw CodeBlock.
    final Notebook? notebook = filename.toLowerCase().endsWith('.ipynb')
        ? parseNotebook(file.content)
        : null;

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
        if (notebook != null)
          NotebookView(notebook: notebook)
        else
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

/// A compact, locale-aware short date from an epoch-ms timestamp
/// (e.g. "Jun 20, 2024"), formatted with intl for the active locale.
String _shortDate(BuildContext context, int epochMs) {
  final date = DateTime.fromMillisecondsSinceEpoch(epochMs);
  final locale = Localizations.localeOf(context).toString();
  return DateFormat.yMMMd(locale).format(date);
}

/// The Snippet-style meta line under the title: a short snippet id + the date
/// the snippet was last updated.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.snippet});

  final Snippet snippet;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );
    final shortId =
        snippet.id.length > 8 ? snippet.id.substring(0, 8) : snippet.id;
    return Row(
      children: [
        Directionality(
          textDirection: TextDirection.ltr,
          child: Text('#$shortId', style: muted),
        ),
        const SizedBox(width: 8),
        Text('·', style: muted),
        const SizedBox(width: 8),
        Text(l10n.detailUpdatedLabel(_shortDate(context, snippet.updatedAt)),
            style: muted),
      ],
    );
  }
}

/// A non-interactive "LABELS ▾" affordance sitting alongside the label chips,
/// echoing Snippet's label dropdown trigger.
class _LabelsAffordance extends StatelessWidget {
  const _LabelsAffordance({required this.snippetId});

  final String snippetId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Tooltip(
      message: l10n.detailManageLabelsTooltip,
      child: InkWell(
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        onTap: () => showSnippetEditor(context, snippetId: snippetId),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusPill),
            border: Border.all(color: theme.colorScheme.outlineVariant),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.detailLabelsAffordance,
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    // Public snippets get a real share URL (served by the `share` edge
    // function); private ones show a hint instead.
    final isPublic = snippet.visibility == SnippetVisibility.public;
    final link = isPublic
        ? SupabaseConfig.shareUrl(snippet.id)
        : l10n.detailShareSetPublicHint;
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
                Icon(isPublic ? Icons.link_rounded : Icons.lock_outline,
                    size: 16, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 8),
                Expanded(
                  child: isPublic
                      // The share link is a URL/path that must stay LTR even
                      // when the app is in an RTL locale.
                      ? Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(
                            link,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontFamily: AppTheme.monoFamily,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Text(
                          link,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                ),
                if (isPublic) _LinkCopyButton(text: link),
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return IconButton(
      tooltip: l10n.detailCopyLinkTooltip,
      visualDensity: VisualDensity.compact,
      iconSize: 16,
      onPressed: _copy,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        switchInCurve: Curves.easeOut,
        switchOutCurve: Curves.easeOut,
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: animation,
          child: FadeTransition(opacity: animation, child: child),
        ),
        child: Icon(
          _copied ? Icons.check_rounded : Icons.copy_rounded,
          key: ValueKey<bool>(_copied),
          color: _copied ? AppTheme.accent : theme.colorScheme.onSurfaceVariant,
        ),
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
    final l10n = AppLocalizations.of(context);
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
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isPrivate ? Icons.lock_outline : Icons.public,
              size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            isPrivate ? l10n.detailVisibilityPrivate : l10n.detailVisibilityPublic,
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

/// The "Files (n)" section header with a quick-copy menu (copy all files /
/// copy as Markdown) and an "ADD FILE" affordance that opens the editor.
class _FilesHeader extends StatelessWidget {
  const _FilesHeader({
    required this.count,
    required this.snippet,
    required this.languageMap,
  });

  final int count;
  final Snippet snippet;
  final Map<String, Language> languageMap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Row(
      children: [
        Flexible(
          child: Text(
            l10n.detailFilesHeader(count),
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const Spacer(),
        _CopyMenuButton(snippet: snippet, languageMap: languageMap),
        Tooltip(
          message: l10n.detailAddFileTooltip,
          child: TextButton.icon(
            onPressed: () => showSnippetEditor(context, snippetId: snippet.id),
            icon: const Icon(Icons.add, size: 16),
            label: Text(l10n.detailAddFileButton),
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

enum _CopyKind { allFiles, markdown }

/// A "Copy ▾" menu in the files header offering "Copy all files" (raw content)
/// and "Copy as Markdown" (fenced, with title/description) — the detail-side
/// half of quick-copy.
class _CopyMenuButton extends StatelessWidget {
  const _CopyMenuButton({required this.snippet, required this.languageMap});

  final Snippet snippet;
  final Map<String, Language> languageMap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return PopupMenuButton<_CopyKind>(
      tooltip: l10n.detailCopyMenuTooltip,
      icon: const Icon(Icons.copy_rounded, size: 18),
      onSelected: (kind) {
        final text = switch (kind) {
          _CopyKind.allFiles => snippetAllFilesText(snippet),
          _CopyKind.markdown => snippetMarkdown(snippet, languageMap),
        };
        copyWithFeedback(context, text, l10n.exportMenuCopiedSnack);
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _CopyKind.allFiles,
          child: Row(
            children: [
              const Icon(Icons.content_copy_outlined, size: 18),
              const SizedBox(width: 12),
              Text(l10n.detailCopyAllFiles),
            ],
          ),
        ),
        PopupMenuItem(
          value: _CopyKind.markdown,
          child: Row(
            children: [
              const Icon(Icons.notes_outlined, size: 18),
              const SizedBox(width: 12),
              Text(l10n.detailCopyAsMarkdown),
            ],
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
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final meta = snippet.promptMeta!;
    // The fillable variables come from the placeholders actually present in the
    // prompt body (the editor reconciles meta to match), so the panel only
    // appears when there's something to fill.
    final variableNames = parsePromptVariableNames(snippet.body);
    final rows = <Widget>[
      if (meta.modelProvider != null)
        _kv(l10n.detailPromptProviderLabel, meta.modelProvider!),
      if (meta.targetModel != null)
        _kv(l10n.detailPromptModelLabel, meta.targetModel!),
      if (meta.temperature != null)
        _kv(l10n.detailPromptTemperatureLabel, meta.temperature!.toString()),
      if (meta.maxTokens != null)
        _kv(l10n.detailPromptMaxTokensLabel, meta.maxTokens!.toString()),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        Text(l10n.detailPromptSettingsHeader, style: theme.textTheme.titleMedium),
        const SizedBox(height: 8),
        ...rows,
        if (meta.systemPrompt != null &&
            meta.systemPrompt!.trim().isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(l10n.detailPromptSystemPromptLabel,
              style: theme.textTheme.labelLarge),
          const SizedBox(height: 4),
          Text(meta.systemPrompt!, style: theme.textTheme.bodyMedium),
        ],
        if (variableNames.isNotEmpty)
          // Interactive fill-in form (replaces the old read-only chips): a
          // labeled field per variable, a live-resolved preview, and
          // "Copy filled prompt". Keyed by the variable set so its controllers
          // survive unrelated snippet-stream updates.
          PromptFillPanel(
            key: ValueKey('fill:${variableNames.join(',')}'),
            snippet: snippet,
          ),
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
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusPill),
        border: Border.all(color: theme.colorScheme.outlineVariant),
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
