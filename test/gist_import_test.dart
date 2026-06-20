import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/features/import/gist_import.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_type.dart';
import 'package:snippet_manager/features/snippets/domain/value_objects.dart';

void main() {
  group('gistsJsonToDrafts', () {
    test('maps a public multi-file gist to a draft', () {
      const sample = '''
      [
        {
          "id": "abc123",
          "description": "Handy helpers",
          "public": true,
          "files": {
            "helper.py": {
              "filename": "helper.py",
              "language": "Python",
              "content": "def add(a, b):\\n    return a + b\\n"
            },
            "notes.md": {
              "filename": "notes.md",
              "language": "Markdown",
              "content": "# Notes"
            }
          }
        }
      ]
      ''';
      final drafts = gistsJsonToDrafts(jsonDecode(sample) as List<dynamic>);

      expect(drafts, hasLength(1));
      final d = drafts.single;
      expect(d.title, 'Handy helpers');
      expect(d.type, SnippetType.code);
      expect(d.visibility, SnippetVisibility.public);
      expect(d.files, hasLength(2));

      final py = d.files.first;
      expect(py.filename, 'helper.py');
      expect(py.languageId, 'python');
      expect(py.content, 'def add(a, b):\n    return a + b\n');
      // Denormalized body/languageId track the first file.
      expect(d.body, py.content);
      expect(d.languageId, 'python');

      final md = d.files[1];
      expect(md.filename, 'notes.md');
      expect(md.languageId, 'markdown');
      expect(md.content, '# Notes');
    });

    test('private gist with no description falls back to first filename', () {
      const sample = '''
      [
        {
          "id": "xyz789",
          "description": "",
          "public": false,
          "files": {
            "main.go": {
              "filename": "main.go",
              "language": "Go",
              "content": "package main"
            }
          }
        }
      ]
      ''';
      final drafts = gistsJsonToDrafts(jsonDecode(sample) as List<dynamic>);

      expect(drafts, hasLength(1));
      final d = drafts.single;
      expect(d.title, 'main.go');
      expect(d.visibility, SnippetVisibility.private);
      expect(d.files.single.languageId, 'go');
    });

    test('unknown language maps to null id', () {
      const sample = '''
      [
        {
          "id": "id0",
          "description": "x",
          "public": true,
          "files": {
            "f.brainfuck": {
              "filename": "f.brainfuck",
              "language": "Brainfuck",
              "content": "+++"
            }
          }
        }
      ]
      ''';
      final drafts = gistsJsonToDrafts(jsonDecode(sample) as List<dynamic>);
      expect(drafts.single.files.single.languageId, isNull);
    });

    test('skips gists with no files', () {
      const sample = '[{"id":"e","description":"empty","public":true,"files":{}}]';
      final drafts = gistsJsonToDrafts(jsonDecode(sample) as List<dynamic>);
      expect(drafts, isEmpty);
    });
  });

  group('extractGistId', () {
    test('returns raw id unchanged', () {
      expect(extractGistId('abc123'), 'abc123');
    });
    test('extracts id from user/<id> URL', () {
      expect(
        extractGistId('https://gist.github.com/octocat/aa5a315d61ae9438b18d'),
        'aa5a315d61ae9438b18d',
      );
    });
    test('extracts id from /<id> URL', () {
      expect(
        extractGistId('https://gist.github.com/aa5a315d61ae9438b18d'),
        'aa5a315d61ae9438b18d',
      );
    });
  });
}
