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
  });

  final String title;
  final String body;

  /// Includes the leading dot, e.g. `.py`. Defaults to `.txt` when unknown.
  final String fileExtension;
  final String? grammarId;
  final String languageName;

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
