import 'dart:typed_data';
import 'dart:ui' show Rect;

import 'snippet_export_data.dart';

/// Platform-agnostic export/share operations. Implementations build bytes once
/// and hand the same bytes to save / copy / share, so behavior is uniform
/// across desktop, mobile and web (where saving triggers a browser download).
abstract interface class ExportService {
  /// Copy plain text to the clipboard (the one guaranteed-everywhere path).
  Future<void> copyText(String text);

  /// Save the body as a source file with the snippet's language extension.
  /// Returns the saved file name/path. On web this triggers a download.
  Future<String> saveSourceFile(SnippetExportData data);

  /// Save the body as a `.txt` file. Returns the saved file name/path.
  Future<String> savePlainText(SnippetExportData data);

  /// Save raw bytes (e.g. a rendered PNG) with the given base name + extension.
  Future<String> saveBytes(
    Uint8List bytes,
    String baseName,
    String fileExtension,
  );

  /// Share plain text via the OS share sheet (Web Share API on web, with a
  /// download fallback). [origin] positions the popover on iPad.
  Future<void> shareText(String text, {String? subject, Rect? origin});

  /// Share raw bytes (e.g. a PNG) as a file via the OS share sheet.
  Future<void> shareBytes(
    Uint8List bytes,
    String fileName,
    String mimeType, {
    String? subject,
    Rect? origin,
  });

  /// Share the snippet body as a source file with the correct extension.
  Future<void> shareSourceFile(SnippetExportData data, {Rect? origin});
}
