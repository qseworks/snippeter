import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../snippets/application/snippet_providers.dart';
import '../../snippets/domain/snippet.dart';
import '../application/export_providers.dart';
import '../domain/snippet_export_data.dart';
import 'export_image_sheet.dart';

enum _ExportAction {
  copy,
  saveSource,
  saveTxt,
  saveHtml,
  savePdf,
  image,
  shareText,
  shareFile,
}

/// AppBar action exposing copy / save / image / share actions for a snippet.
class ExportMenuButton extends ConsumerWidget {
  const ExportMenuButton({super.key, required this.snippet});

  final Snippet snippet;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageMapProvider)[snippet.languageId];
    final data = exportDataFor(snippet, language);

    return PopupMenuButton<_ExportAction>(
      tooltip: 'Export & share',
      icon: const Icon(Icons.ios_share),
      onSelected: (action) => _run(context, ref, action),
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: _ExportAction.copy,
          child: _MenuRow(icon: Icons.copy_all_outlined, label: 'Copy text'),
        ),
        const PopupMenuItem(
          value: _ExportAction.image,
          child: _MenuRow(icon: Icons.image_outlined, label: 'Export as image…'),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: _ExportAction.saveSource,
          child: _MenuRow(
            icon: Icons.description_outlined,
            label: 'Save as ${data.fileExtension} file',
          ),
        ),
        const PopupMenuItem(
          value: _ExportAction.saveTxt,
          child: _MenuRow(icon: Icons.text_snippet_outlined, label: 'Save as .txt'),
        ),
        const PopupMenuItem(
          value: _ExportAction.saveHtml,
          child: _MenuRow(icon: Icons.html_outlined, label: 'Save as HTML'),
        ),
        const PopupMenuItem(
          value: _ExportAction.savePdf,
          child: _MenuRow(
              icon: Icons.picture_as_pdf_outlined, label: 'Save as PDF'),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem(
          value: _ExportAction.shareText,
          child: _MenuRow(icon: Icons.share_outlined, label: 'Share text'),
        ),
        const PopupMenuItem(
          value: _ExportAction.shareFile,
          child: _MenuRow(icon: Icons.attach_file, label: 'Share as file'),
        ),
      ],
    );
  }

  Future<void> _run(
    BuildContext context,
    WidgetRef ref,
    _ExportAction action,
  ) async {
    final language = ref.read(languageMapProvider)[snippet.languageId];
    final data = exportDataFor(snippet, language);
    final export = ref.read(exportServiceProvider);
    final messenger = ScaffoldMessenger.of(context);

    // Capture the share origin (iPad popover anchor) before any await.
    final box = context.findRenderObject() as RenderBox?;
    final origin = box == null
        ? null
        : box.localToGlobal(Offset.zero) & box.size;

    try {
      switch (action) {
        case _ExportAction.copy:
          await export.copyText(data.body);
          messenger.showSnackBar(
            const SnackBar(content: Text('Copied to clipboard')),
          );
        case _ExportAction.image:
          if (context.mounted) await showExportImageSheet(context, data);
        case _ExportAction.saveSource:
          await export.saveSourceFile(data);
          messenger.showSnackBar(
            SnackBar(content: Text('Saved ${data.sourceFileName}')),
          );
        case _ExportAction.saveTxt:
          await export.savePlainText(data);
          messenger.showSnackBar(
            SnackBar(content: Text('Saved ${data.baseName}.txt')),
          );
        case _ExportAction.saveHtml:
          final rich = _richExportData(data);
          await export.exportHtml(rich, description: snippet.description);
          messenger.showSnackBar(
            SnackBar(content: Text('Saved ${rich.baseName}.html')),
          );
        case _ExportAction.savePdf:
          final rich = _richExportData(data);
          await export.exportPdf(rich, description: snippet.description);
          messenger.showSnackBar(
            SnackBar(content: Text('Saved ${rich.baseName}.pdf')),
          );
        case _ExportAction.shareText:
          await export.shareText(data.body,
              subject: data.title, origin: origin);
        case _ExportAction.shareFile:
          await export.shareSourceFile(data, origin: origin);
      }
    } catch (error) {
      messenger.showSnackBar(SnackBar(content: Text('Export failed: $error')));
    }
  }

  /// Augments the single-body [data] with all of the snippet's files so the
  /// HTML/PDF documents include every file (not just the denormalized body).
  /// When the snippet has no explicit file rows, [SnippetExportData] falls back
  /// to a synthetic single file built from the body.
  SnippetExportData _richExportData(SnippetExportData data) {
    if (snippet.files.isEmpty) return data;
    return SnippetExportData(
      title: data.title,
      body: data.body,
      fileExtension: data.fileExtension,
      grammarId: data.grammarId,
      languageName: data.languageName,
      files: [
        for (final f in snippet.files)
          ExportFile(filename: f.filename, content: f.content),
      ],
    );
  }
}

class _MenuRow extends StatelessWidget {
  const _MenuRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20),
        const SizedBox(width: 12),
        Text(label),
      ],
    );
  }
}
