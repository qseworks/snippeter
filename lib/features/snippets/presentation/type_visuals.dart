import 'package:flutter/material.dart';
import 'package:snippet_manager/l10n/app_localizations.dart';

import '../domain/snippet_type.dart';

/// Icon used to represent a snippet type across the UI. One family (filled)
/// for all three — the glyphs render side by side in the editor's segmented
/// button, the detail meta chip, and the type filter.
IconData iconForType(SnippetType type) => switch (type) {
      SnippetType.code => Icons.code,
      SnippetType.aiPrompt => Icons.smart_toy,
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

/// Localized display name for a seeded snippet purpose, keyed by purpose id.
/// Falls back to [fallback] (e.g. the seeded English label) for unknown ids so
/// future/custom purposes degrade gracefully instead of throwing.
String labelForPurpose(AppLocalizations l10n, String purposeId,
        {String? fallback}) =>
    switch (purposeId) {
      'utility' => l10n.purposeUtility,
      'boilerplate' => l10n.purposeBoilerplate,
      'algorithm' => l10n.purposeAlgorithm,
      'regex' => l10n.purposeRegex,
      'sql-query' => l10n.purposeSqlQuery,
      'config' => l10n.purposeConfig,
      'reference' => l10n.purposeReference,
      'prompt-coding' => l10n.purposePromptCoding,
      'prompt-summarization' => l10n.purposePromptSummarization,
      'prompt-system' => l10n.purposePromptSystem,
      _ => fallback ?? purposeId,
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
