import 'snippet_type.dart';
import 'value_objects.dart';

/// A snippet as the rest of the app sees it — assembled from the snippet row
/// plus its labels and (for prompts) its metadata. Pure value object; carries
/// no Drift or Supabase types.
class Snippet {
  const Snippet({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
    this.languageId,
    this.purpose,
    this.description,
    this.collectionId,
    this.isFavorite = false,
    this.sortIndex,
    this.labels = const [],
    this.promptMeta,
    this.files = const [],
    this.visibility = SnippetVisibility.private,
  });

  final String id;
  final String title;

  /// Denormalized mirror of the first file's content (FTS + back-compat).
  final String body;
  final SnippetType type;

  /// Denormalized mirror of the first file's languageId (back-compat).
  final String? languageId;
  final String? purpose;
  final String? description;
  final String? collectionId;
  final bool isFavorite;
  final int? sortIndex;
  final int createdAt;
  final int updatedAt;
  final List<Label> labels;
  final AiPromptMeta? promptMeta;
  final List<SnippetFile> files;
  final SnippetVisibility visibility;
}

/// A point-in-time snapshot of a snippet's files, for the history/restore UI.
/// All files in a version share the same [savedAt] timestamp and are ordered by
/// their original position.
class SnippetVersion {
  final int savedAt;
  final List<SnippetFile> files;
  const SnippetVersion({required this.savedAt, required this.files});
}

/// The editable shape used to create or update a snippet. Labels are given by
/// name; the repository resolves them to [Label] rows (find-or-create).
class SnippetDraft {
  const SnippetDraft({
    required this.title,
    required this.body,
    required this.type,
    this.languageId,
    this.purpose,
    this.description,
    this.collectionId,
    this.isFavorite = false,
    this.labelNames = const [],
    this.promptMeta,
    this.files = const [],
    this.visibility = SnippetVisibility.private,
  });

  final String title;

  /// Legacy single-body field. When [files] is empty the repository synthesizes
  /// one file from this body + [languageId]; otherwise [files] wins.
  final String body;
  final SnippetType type;
  final String? languageId;
  final String? purpose;
  final String? description;
  final String? collectionId;
  final bool isFavorite;
  final List<String> labelNames;
  final AiPromptMeta? promptMeta;
  final List<SnippetFileDraft> files;
  final SnippetVisibility visibility;

  factory SnippetDraft.fromSnippet(Snippet s) => SnippetDraft(
        title: s.title,
        body: s.body,
        type: s.type,
        languageId: s.languageId,
        purpose: s.purpose,
        description: s.description,
        collectionId: s.collectionId,
        isFavorite: s.isFavorite,
        labelNames: [for (final l in s.labels) l.name],
        promptMeta: s.promptMeta,
        files: [for (final f in s.files) SnippetFileDraft.fromFile(f)],
        visibility: s.visibility,
      );
}
