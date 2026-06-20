import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/core/notebook/ipynb.dart';

void main() {
  group('parseNotebook', () {
    test('parses a markdown cell and a code cell with output', () {
      const json = '''
      {
        "metadata": {
          "language_info": {"name": "python"},
          "kernelspec": {"language": "python"}
        },
        "nbformat": 4,
        "cells": [
          {
            "cell_type": "markdown",
            "source": ["# Title\\n", "Some text"]
          },
          {
            "cell_type": "code",
            "execution_count": 3,
            "source": "print('hi')",
            "outputs": [
              {"output_type": "stream", "name": "stdout", "text": ["hi\\n"]},
              {
                "output_type": "execute_result",
                "data": {"text/plain": ["42"]}
              }
            ]
          }
        ]
      }
      ''';

      final nb = parseNotebook(json);
      expect(nb, isNotNull);
      expect(nb!.languageName, 'python');
      expect(nb.cells, hasLength(2));

      final md = nb.cells[0];
      expect(md.type, 'markdown');
      expect(md.source, '# Title\nSome text');
      expect(md.outputs, isEmpty);

      final code = nb.cells[1];
      expect(code.type, 'code');
      expect(code.source, "print('hi')");
      expect(code.executionCount, 3);
      expect(code.outputs, ['hi\n', '42']);
    });

    test('reads language from kernelspec when language_info is absent', () {
      const json = '''
      {
        "metadata": {"kernelspec": {"language": "julia"}},
        "cells": []
      }
      ''';
      final nb = parseNotebook(json);
      expect(nb, isNotNull);
      expect(nb!.languageName, 'julia');
      expect(nb.cells, isEmpty);
    });

    test('returns null for non-notebook JSON', () {
      expect(parseNotebook('{"foo": "bar"}'), isNull);
    });

    test('returns null for invalid JSON', () {
      expect(parseNotebook('not json'), isNull);
    });
  });
}
