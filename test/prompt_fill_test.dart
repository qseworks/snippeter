import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/features/snippets/data/prompt_variables.dart';
import 'package:snippet_manager/features/snippets/domain/snippet.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_type.dart';
import 'package:snippet_manager/features/snippets/domain/value_objects.dart';
import 'package:snippet_manager/features/snippets/presentation/widgets/snippet_copy.dart';

void main() {
  group('resolvePromptVariables', () {
    test('substitutes filled values and keeps unfilled placeholders', () {
      const body = 'Hi {{name}}, write about {{topic}} in {{tone}}.';
      final out = resolvePromptVariables(body, {
        'name': 'Sam',
        'topic': 'sync engines',
        // tone left unfilled
      });
      expect(out, 'Hi Sam, write about sync engines in {{tone}}.');
    });

    test('treats empty string as unfilled (placeholder stays)', () {
      final out = resolvePromptVariables('A {{x}} B', {'x': ''});
      expect(out, 'A {{x}} B');
    });

    test('replaces every occurrence of a repeated variable', () {
      final out =
          resolvePromptVariables('{{x}} and {{x}} again', {'x': 'Z'});
      expect(out, 'Z and Z again');
    });

    test('tolerates whitespace inside the braces', () {
      final out = resolvePromptVariables('Hello {{  name  }}', {'name': 'Ada'});
      expect(out, 'Hello Ada');
    });
  });

  group('snippet copy builders', () {
    Snippet promptSnippet() => const Snippet(
          id: 's1',
          title: 'Greeting',
          body: 'Hello {{name}}',
          type: SnippetType.aiPrompt,
          createdAt: 0,
          updatedAt: 0,
        );

    test('snippetPrimaryText prefers the first file, falls back to body', () {
      final withFile = Snippet(
        id: 's',
        title: 't',
        body: 'denorm',
        type: SnippetType.code,
        createdAt: 0,
        updatedAt: 0,
        files: const [SnippetFile(id: 'f', content: 'from-file')],
      );
      expect(snippetPrimaryText(withFile), 'from-file');
      expect(snippetPrimaryText(promptSnippet()), 'Hello {{name}}');
    });

    test('snippetAllFilesText concatenates multi-file with name headers', () {
      final snippet = Snippet(
        id: 's',
        title: 't',
        body: 'a',
        type: SnippetType.code,
        createdAt: 0,
        updatedAt: 0,
        files: const [
          SnippetFile(id: 'f1', filename: 'a.dart', content: 'A'),
          SnippetFile(id: 'f2', filename: 'b.dart', content: 'B'),
        ],
      );
      expect(snippetAllFilesText(snippet), '// a.dart\nA\n\n// b.dart\nB');
    });

    test('snippetMarkdown fences each file with its highlight grammar', () {
      const languages = {
        'python': Language(
          id: 'python',
          name: 'Python',
          fileExtension: '.py',
          grammarId: 'python',
        ),
      };
      final snippet = Snippet(
        id: 's',
        title: 'Bisect',
        body: 'def f(): ...',
        type: SnippetType.code,
        createdAt: 0,
        updatedAt: 0,
        files: const [
          SnippetFile(
            id: 'f1',
            filename: 'bisect.py',
            languageId: 'python',
            content: 'def f(): ...',
          ),
        ],
      );
      final md = snippetMarkdown(snippet, languages);
      expect(md, contains('# Bisect'));
      expect(md, contains('**bisect.py**'));
      expect(md, contains('```python'));
      expect(md, contains('def f(): ...'));
    });
  });
}
