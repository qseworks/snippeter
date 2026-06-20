import 'package:flutter/material.dart';

import '../domain/snippet_type.dart';

/// Icon used to represent a snippet type across the UI.
IconData iconForType(SnippetType type) => switch (type) {
      SnippetType.code => Icons.code,
      SnippetType.aiPrompt => Icons.smart_toy_outlined,
      SnippetType.text => Icons.notes,
    };

/// A short, single-line preview built from the first non-empty lines of a body.
String previewOf(String body, {int maxLines = 3}) {
  final lines = body
      .split('\n')
      .map((l) => l.trimRight())
      .where((l) => l.trim().isNotEmpty)
      .take(maxLines)
      .toList();
  return lines.join('\n');
}
