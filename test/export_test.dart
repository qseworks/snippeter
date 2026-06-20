import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/features/export/application/export_providers.dart';
import 'package:snippet_manager/features/export/domain/snippet_export_data.dart';
import 'package:snippet_manager/features/snippets/domain/snippet.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_type.dart';
import 'package:snippet_manager/features/snippets/domain/value_objects.dart';

void main() {
  test('baseName slugifies the title; falls back to "snippet"', () {
    expect(
      const SnippetExportData(title: 'Binary Search!', body: '', fileExtension: '.py')
          .baseName,
      'binary-search',
    );
    expect(
      const SnippetExportData(title: '   ', body: '', fileExtension: '.txt')
          .baseName,
      'snippet',
    );
    expect(
      const SnippetExportData(
              title: 'My  Cool__Thing', body: '', fileExtension: '.js')
          .sourceFileName,
      'my-cool-thing.js',
    );
  });

  test('exportDataFor resolves the language extension and grammar', () {
    const snippet = Snippet(
      id: '1',
      title: 'T',
      body: 'b',
      type: SnippetType.code,
      languageId: 'python',
      createdAt: 0,
      updatedAt: 0,
    );
    const lang = Language(
        id: 'python', name: 'Python', fileExtension: '.py', grammarId: 'python');

    final data = exportDataFor(snippet, lang);
    expect(data.fileExtension, '.py');
    expect(data.grammarId, 'python');
    expect(data.languageName, 'Python');

    // No language -> plain text.
    expect(exportDataFor(snippet, null).fileExtension, '.txt');
  });
}
