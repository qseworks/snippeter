import 'snippet.dart';
import 'snippet_query.dart';
import 'value_objects.dart';

/// The storage seam. Everything above this returns domain entities and reactive
/// streams — never Drift rows or Supabase types. Swapping the implementation
/// (local -> synced) is what makes cloud sync additive (see Phase 7).
abstract interface class SnippetRepository {
  // --- snippets ---
  Stream<List<Snippet>> watchSnippets(SnippetQuery query);
  Stream<Snippet?> watchSnippet(String id);
  Future<Snippet?> getSnippet(String id);
  Future<String> create(SnippetDraft draft);
  Future<void> update(String id, SnippetDraft draft);
  Future<void> setFavorite(String id, {required bool value});
  Future<void> softDelete(String id);

  // --- version history ---
  /// All saved versions of a snippet's files, most recent first.
  Future<List<SnippetVersion>> getVersions(String snippetId);

  /// Restores the file set captured at [savedAt] as the snippet's current files.
  /// The current files are first snapshotted, so a restore is itself undoable.
  Future<void> restoreVersion(String snippetId, int savedAt);

  // --- labels ---
  Stream<List<Label>> watchLabels();
  Future<String> createLabel(String name, {String? color, String? parentId});
  Future<void> setLabelColor(String id, String color);
  Future<void> setLabelParent(String id, String? parentId);
  Future<void> renameLabel(String id, String name);
  Future<void> deleteLabel(String id);

  // --- collections ---
  Stream<List<Collection>> watchCollections();
  Future<String> createCollection(String name, {String? parentId});
  Future<void> renameCollection(String id, String name);
  Future<void> deleteCollection(String id);

  // --- reference data ---
  Future<List<Language>> getLanguages();
  Future<List<Purpose>> getPurposes();
}
