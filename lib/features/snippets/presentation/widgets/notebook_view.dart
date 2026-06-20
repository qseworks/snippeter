import 'package:flutter/material.dart';
import 'package:flutter_markdown_plus/flutter_markdown_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/notebook/ipynb.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/code_view.dart';
import '../../application/snippet_providers.dart';
import '../../domain/value_objects.dart';

/// Read-only renderer for a parsed Jupyter notebook ([Notebook]).
///
/// Cells are rendered in order: markdown cells via flutter_markdown_plus
/// ([MarkdownBody]); code cells via the shared [CodeBlock] (the grammar is
/// resolved from the notebook's language name through [languageMapProvider],
/// defaulting to 'python'), prefixed with an "In [n]:" label, and each cell's
/// outputs are shown beneath as a subtle monospace block.
class NotebookView extends ConsumerWidget {
  const NotebookView({super.key, required this.notebook});

  final Notebook notebook;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final languageMap = ref.watch(languageMapProvider);
    // The notebook's language name (e.g. 'python') doubles as our language slug
    // for the seeded set; fall back to 'python' when absent/unknown.
    final languageId = notebook.languageName ?? 'python';
    final Language? language =
        languageMap[languageId] ?? languageMap['python'];

    final cells = notebook.cells;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < cells.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _NotebookCellView(
            cell: cells[i],
            languageId: language?.id ?? languageId,
            grammarId: language?.grammarId,
            languageName: language?.name,
          ),
        ],
      ],
    );
  }
}

/// One notebook cell: markdown rendered inline, code rendered as a [CodeBlock]
/// with an "In [n]:" label and an outputs block.
class _NotebookCellView extends StatelessWidget {
  const _NotebookCellView({
    required this.cell,
    required this.languageId,
    required this.grammarId,
    required this.languageName,
  });

  final NotebookCell cell;
  final String languageId;
  final String? grammarId;
  final String? languageName;

  @override
  Widget build(BuildContext context) {
    if (cell.type == 'markdown') {
      return MarkdownBody(
        data: cell.source,
        selectable: true,
        styleSheet: MarkdownStyleSheet.fromTheme(Theme.of(context)),
      );
    }

    if (cell.type == 'code') {
      final theme = Theme.of(context);
      final label = cell.executionCount == null
          ? 'In [ ]:'
          : 'In [${cell.executionCount}]:';
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppTheme.monoFamily,
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          CodeBlock(
            code: cell.source,
            grammarId: grammarId,
            languageId: languageId,
            languageName: languageName,
          ),
          for (final output in cell.outputs) ...[
            const SizedBox(height: 6),
            _OutputBlock(text: output),
          ],
        ],
      );
    }

    // Other (raw) cell types: render the source verbatim in a subtle block.
    if (cell.source.trim().isEmpty) return const SizedBox.shrink();
    return _OutputBlock(text: cell.source);
  }
}

/// A subtle monospace container for a code cell's textual output.
class _OutputBlock extends StatelessWidget {
  const _OutputBlock({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: SelectableText(
        text,
        style: theme.textTheme.bodySmall?.copyWith(
          fontFamily: AppTheme.monoFamily,
          fontFamilyFallback: kMonoFallback.sublist(1),
          color: theme.colorScheme.onSurfaceVariant,
          height: 1.4,
        ),
      ),
    );
  }
}
