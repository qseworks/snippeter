import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';

import '../domain/export_service.dart';
import '../domain/snippet_export_data.dart';

/// Default export service: built-in clipboard for text (guaranteed on web),
/// file_saver for files/bytes (a Blob download on web, a real file natively).
class DefaultExportService implements ExportService {
  const DefaultExportService();

  @override
  Future<void> copyText(String text) =>
      Clipboard.setData(ClipboardData(text: text));

  @override
  Future<String> saveSourceFile(SnippetExportData data) => _saveText(
        data.baseName,
        data.fileExtension,
        data.body,
      );

  @override
  Future<String> savePlainText(SnippetExportData data) =>
      _saveText(data.baseName, '.txt', data.body);

  @override
  Future<String> saveBytes(
    Uint8List bytes,
    String baseName,
    String fileExtension,
  ) {
    final isPng = fileExtension.toLowerCase().contains('png');
    return FileSaver.instance.saveFile(
      name: baseName,
      bytes: bytes,
      fileExtension: fileExtension,
      mimeType: isPng ? MimeType.png : MimeType.other,
    );
  }

  @override
  Future<void> shareText(String text, {String? subject, Rect? origin}) async {
    await SharePlus.instance.share(
      ShareParams(text: text, subject: subject, sharePositionOrigin: origin),
    );
  }

  @override
  Future<void> shareBytes(
    Uint8List bytes,
    String fileName,
    String mimeType, {
    String? subject,
    Rect? origin,
  }) async {
    final file = XFile.fromData(bytes, mimeType: mimeType, name: fileName);
    await SharePlus.instance.share(
      ShareParams(
        files: [file],
        subject: subject,
        sharePositionOrigin: origin,
      ),
    );
  }

  @override
  Future<void> shareSourceFile(SnippetExportData data, {Rect? origin}) {
    final bytes = Uint8List.fromList(utf8.encode(data.body));
    return shareBytes(
      bytes,
      data.sourceFileName,
      'text/plain',
      subject: data.title,
      origin: origin,
    );
  }

  Future<String> _saveText(String baseName, String ext, String content) {
    final bytes = Uint8List.fromList(utf8.encode(content));
    return FileSaver.instance.saveFile(
      name: baseName,
      bytes: bytes,
      fileExtension: ext,
      mimeType: MimeType.text,
    );
  }
}
