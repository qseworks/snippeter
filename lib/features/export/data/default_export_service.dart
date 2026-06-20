import 'dart:convert';

import 'package:file_saver/file_saver.dart';
import 'package:flutter/services.dart';
import 'package:markdown/markdown.dart' as md;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
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

  // --- HTML / PDF ----------------------------------------------------------

  @override
  Future<void> exportHtml(SnippetExportData data, {String? description}) async {
    final html = _buildHtml(data, description);
    final bytes = Uint8List.fromList(utf8.encode(html));
    await FileSaver.instance.saveFile(
      name: data.baseName,
      bytes: bytes,
      fileExtension: 'html',
      mimeType: MimeType.custom,
      customMimeType: 'text/html',
    );
  }

  String _buildHtml(SnippetExportData data, String? description) {
    final buffer = StringBuffer();
    buffer.writeln('<!DOCTYPE html>');
    buffer.writeln('<html lang="en"><head>');
    buffer.writeln('<meta charset="utf-8">');
    buffer.writeln(
        '<meta name="viewport" content="width=device-width, initial-scale=1">');
    buffer.writeln('<title>${_escapeHtml(data.title)}</title>');
    buffer.writeln('<style>$_htmlStyle</style>');
    buffer.writeln('</head><body><main>');
    buffer.writeln('<h1>${_escapeHtml(data.title)}</h1>');
    if (description != null && description.trim().isNotEmpty) {
      buffer.writeln(
        '<div class="description">${md.markdownToHtml(description)}</div>',
      );
    }
    for (final f in data.effectiveFiles) {
      final name = f.filename.trim().isEmpty ? 'untitled' : f.filename;
      buffer.writeln('<h3>${_escapeHtml(name)}</h3>');
      buffer.writeln('<pre><code>${_escapeHtml(f.content)}</code></pre>');
    }
    buffer.writeln('</main></body></html>');
    return buffer.toString();
  }

  static const String _htmlStyle = '''
:root { color-scheme: dark; }
body {
  margin: 0;
  background: #0d1117;
  color: #e6edf3;
  font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
  line-height: 1.6;
}
main { max-width: 880px; margin: 0 auto; padding: 40px 24px; }
h1 { font-size: 2rem; margin: 0 0 0.5em; }
h3 { margin: 1.5em 0 0.4em; color: #7ee787; font-family: monospace; }
.description { color: #c9d1d9; margin-bottom: 1.5em; }
.description a { color: #58a6ff; }
pre {
  background: #161b22;
  border: 1px solid #30363d;
  border-radius: 8px;
  padding: 16px;
  overflow-x: auto;
}
code {
  font-family: 'JetBrains Mono', ui-monospace, SFMono-Regular, Menlo, monospace;
  font-size: 0.9rem;
}
''';

  String _escapeHtml(String s) => s
      .replaceAll('&', '&amp;')
      .replaceAll('<', '&lt;')
      .replaceAll('>', '&gt;')
      .replaceAll('"', '&quot;')
      .replaceAll("'", '&#39;');

  @override
  Future<void> exportPdf(SnippetExportData data, {String? description}) async {
    final mono = pw.Font.ttf(
      await rootBundle.load('assets/fonts/JetBrainsMono-Regular.ttf'),
    );
    final doc = pw.Document();
    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          final widgets = <pw.Widget>[
            pw.Text(
              data.title,
              style: pw.TextStyle(
                fontSize: 22,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
            pw.SizedBox(height: 12),
          ];
          if (description != null && description.trim().isNotEmpty) {
            widgets.add(pw.Text(description));
            widgets.add(pw.SizedBox(height: 12));
          }
          for (final f in data.effectiveFiles) {
            final name = f.filename.trim().isEmpty ? 'untitled' : f.filename;
            widgets.add(
              pw.Text(
                name,
                style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 4));
            widgets.add(
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(8),
                decoration: pw.BoxDecoration(
                  color: PdfColors.grey200,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  f.content,
                  style: pw.TextStyle(font: mono, fontSize: 9),
                ),
              ),
            );
            widgets.add(pw.SizedBox(height: 12));
          }
          return widgets;
        },
      ),
    );
    final bytes = await doc.save();
    await saveBytes(bytes, data.baseName, '.pdf');
  }
}
