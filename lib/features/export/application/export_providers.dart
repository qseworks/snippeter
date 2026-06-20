import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../snippets/domain/snippet.dart';
import '../../snippets/domain/value_objects.dart';
import '../data/default_export_service.dart';
import '../domain/export_service.dart';
import '../domain/snippet_export_data.dart';

final exportServiceProvider =
    Provider<ExportService>((ref) => const DefaultExportService());

/// Builds [SnippetExportData] from a snippet and its (optional) language.
SnippetExportData exportDataFor(Snippet snippet, Language? language) {
  return SnippetExportData(
    title: snippet.title,
    body: snippet.body,
    fileExtension: language?.fileExtension ?? '.txt',
    grammarId: language?.grammarId,
    languageName: language?.name ?? 'Text',
  );
}
