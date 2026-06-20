/// Everything the export pipeline needs about a snippet, decoupled from storage
/// and sync. The PNG/file/clipboard code depends only on this value object, so
/// the identical code runs on every platform including web.
class SnippetExportData {
  const SnippetExportData({
    required this.title,
    required this.body,
    required this.fileExtension,
    this.grammarId,
    this.languageName = 'Text',
    this.files = const [],
  });

  final String title;
  final String body;

  /// Includes the leading dot, e.g. `.py`. Defaults to `.txt` when unknown.
  final String fileExtension;
  final String? grammarId;
  final String languageName;

  /// All files of the snippet, in order, for multi-file exports (HTML/PDF).
  /// Empty for legacy single-body callers; [exportHtml]/[exportPdf] then fall
  /// back to a single synthetic file built from [body]/[fileExtension].
  final List<ExportFile> files;

  /// The effective files to render: explicit [files] when present, otherwise a
  /// single file synthesized from [body] so single-body callers keep working.
  List<ExportFile> get effectiveFiles => files.isNotEmpty
      ? files
      : [ExportFile(filename: sourceFileName, content: body)];

  /// A filesystem-safe base name (no extension) derived from the title.
  String get baseName {
    final slug = title
        .trim()
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]+'), '-')
        .replaceAll(RegExp(r'(^-+)|(-+$)'), '');
    return slug.isEmpty ? 'snippet' : slug;
  }

  String get sourceFileName => '$baseName$fileExtension';
}

/// One file inside a multi-file export. Storage- and platform-agnostic.
class ExportFile {
  const ExportFile({required this.filename, required this.content});

  final String filename;
  final String content;
}
