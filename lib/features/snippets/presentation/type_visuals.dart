import 'package:flutter/material.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../domain/snippet_type.dart';

/// Icon used to represent a snippet type across the UI.
IconData iconForType(SnippetType type) => switch (type) {
      SnippetType.code => Icons.code,
      SnippetType.aiPrompt => Icons.smart_toy_outlined,
      SnippetType.text => Icons.notes,
    };

/// Localized display name for a snippet type, matching the editor's segmented
/// button. Use this anywhere a type name is shown to the user instead of
/// `SnippetType.label` (which is English-only and leaks into every locale).
String labelForType(AppLocalizations l10n, SnippetType type) => switch (type) {
      SnippetType.code => l10n.editorTypeCode,
      SnippetType.aiPrompt => l10n.editorTypeAiPrompt,
      SnippetType.text => l10n.editorTypeText,
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
