import 'dart:convert';

/// A parsed Jupyter notebook (.ipynb). Pure value object — no IO. Produced by
/// [parseNotebook], which is deliberately tolerant: malformed or non-notebook
/// JSON yields null rather than throwing.
class Notebook {
  const Notebook({this.languageName, this.cells = const []});

  /// The notebook's language (from metadata), e.g. 'python'. May be null.
  final String? languageName;
  final List<NotebookCell> cells;
}

/// A single notebook cell.
class NotebookCell {
  const NotebookCell({
    required this.type,
    required this.source,
    this.outputs = const [],
    this.executionCount,
  });

  /// 'markdown' | 'code' (other raw types are passed through verbatim).
  final String type;

  /// The cell's source, with multi-line list sources joined into one string.
  final String source;

  /// For code cells: the textual outputs (stream text + text/plain results).
  final List<String> outputs;

  /// For code cells: the execution count, or null if never run.
  final int? executionCount;
}

/// Parses [jsonText] as a Jupyter notebook. Returns null if the text is not
/// valid JSON or does not look like a notebook (no `cells` array).
Notebook? parseNotebook(String jsonText) {
  Object? decoded;
  try {
    decoded = jsonDecode(jsonText);
  } catch (_) {
    return null;
  }
  if (decoded is! Map<String, dynamic>) return null;
  final rawCells = decoded['cells'];
  if (rawCells is! List) return null; // not a notebook

  final metadata = decoded['metadata'];
  final language = _languageFromMetadata(metadata);

  final cells = <NotebookCell>[];
  for (final raw in rawCells) {
    if (raw is! Map<String, dynamic>) continue;
    final type = (raw['cell_type'] as String?) ?? 'code';
    final source = _joinSource(raw['source']);
    if (type == 'code') {
      cells.add(
        NotebookCell(
          type: 'code',
          source: source,
          executionCount: _asInt(raw['execution_count']),
          outputs: _parseOutputs(raw['outputs']),
        ),
      );
    } else {
      cells.add(NotebookCell(type: type, source: source));
    }
  }

  return Notebook(languageName: language, cells: cells);
}

String? _languageFromMetadata(Object? metadata) {
  if (metadata is! Map<String, dynamic>) return null;
  final langInfo = metadata['language_info'];
  if (langInfo is Map<String, dynamic>) {
    final name = langInfo['name'];
    if (name is String && name.isNotEmpty) return name;
  }
  final kernelspec = metadata['kernelspec'];
  if (kernelspec is Map<String, dynamic>) {
    final lang = kernelspec['language'];
    if (lang is String && lang.isNotEmpty) return lang;
  }
  return null;
}

/// `source` may be a String or a `List<String>` (the common multipart form).
String _joinSource(Object? source) {
  if (source is String) return source;
  if (source is List) {
    return source.whereType<String>().join();
  }
  return '';
}

List<String> _parseOutputs(Object? outputs) {
  if (outputs is! List) return const [];
  final result = <String>[];
  for (final out in outputs) {
    if (out is! Map<String, dynamic>) continue;
    final type = out['output_type'] as String?;
    switch (type) {
      case 'stream':
        final text = _joinSource(out['text']);
        if (text.isNotEmpty) result.add(text);
      case 'execute_result':
      case 'display_data':
        final data = out['data'];
        if (data is Map<String, dynamic>) {
          final plain = data['text/plain'];
          final text = _joinSource(plain);
          if (text.isNotEmpty) result.add(text);
        }
      case 'error':
        final tb = out['traceback'];
        if (tb is List) {
          final text = tb.whereType<String>().join('\n');
          if (text.isNotEmpty) result.add(text);
        }
      default:
        break;
    }
  }
  return result;
}

int? _asInt(Object? value) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return null;
}
