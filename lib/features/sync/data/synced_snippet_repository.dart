// Private fields can't be named initializing formals, so assign in the body.
// ignore_for_file: prefer_initializing_formals
import 'dart:typed_data';

import '../../snippets/domain/snippet.dart';
import '../../snippets/domain/snippet_query.dart';
import '../../snippets/domain/snippet_repository.dart';
import '../../snippets/domain/value_objects.dart';

/// Offline-first decorator over [SnippetRepository]. Every read delegates
/// straight through to the local repository (the source of truth). Every
/// MUTATING call delegates to local and then fires [_onMutation] — a debounced
/// sync trigger. When signed out or Supabase isn't configured, [_onMutation] is
/// a no-op, so local behavior is completely unchanged.
class SyncedSnippetRepository implements SnippetRepository {
  SyncedSnippetRepository({
    required SnippetRepository local,
    required void Function() onMutation,
  })  : _local = local,
        _onMutation = onMutation;

  final SnippetRepository _local;
  final void Function() _onMutation;

  /// Runs a mutating future, then schedules a sync. The trigger is fired AFTER
  /// the local write resolves so the dirty rows exist when sync runs.
  Future<T> _mutate<T>(Future<T> future) async {
    final result = await future;
    _onMutation();
    return result;
  }

  // --- reads (pass-through) --------------------------------------------------

  @override
  Stream<List<Snippet>> watchSnippets(SnippetQuery query) =>
      _local.watchSnippets(query);

  @override
  Stream<Snippet?> watchSnippet(String id) => _local.watchSnippet(id);

  @override
  Future<Snippet?> getSnippet(String id) => _local.getSnippet(id);

  @override
  Stream<List<Label>> watchLabels() => _local.watchLabels();

  @override
  Stream<List<Collection>> watchCollections() => _local.watchCollections();

  @override
  Stream<List<Attachment>> watchAttachments(String snippetId) =>
      _local.watchAttachments(snippetId);

  @override
  Future<List<SnippetVersion>> getVersions(String snippetId) =>
      _local.getVersions(snippetId);

  @override
  Future<List<Language>> getLanguages() => _local.getLanguages();

  @override
  Future<List<Purpose>> getPurposes() => _local.getPurposes();

  // --- mutations (delegate + schedule sync) ----------------------------------

  @override
  Future<String> create(SnippetDraft draft) => _mutate(_local.create(draft));

  @override
  Future<void> update(String id, SnippetDraft draft) =>
      _mutate(_local.update(id, draft));

  @override
  Future<void> setFavorite(String id, {required bool value}) =>
      _mutate(_local.setFavorite(id, value: value));

  @override
  Future<void> softDelete(String id) => _mutate(_local.softDelete(id));

  @override
  Future<void> restoreVersion(String snippetId, int savedAt) =>
      _mutate(_local.restoreVersion(snippetId, savedAt));

  @override
  Future<String> createLabel(String name, {String? color, String? parentId}) =>
      _mutate(_local.createLabel(name, color: color, parentId: parentId));

  @override
  Future<void> setLabelColor(String id, String color) =>
      _mutate(_local.setLabelColor(id, color));

  @override
  Future<void> setLabelParent(String id, String? parentId) =>
      _mutate(_local.setLabelParent(id, parentId));

  @override
  Future<void> renameLabel(String id, String name) =>
      _mutate(_local.renameLabel(id, name));

  @override
  Future<void> deleteLabel(String id) => _mutate(_local.deleteLabel(id));

  @override
  Future<String> createCollection(String name, {String? parentId}) =>
      _mutate(_local.createCollection(name, parentId: parentId));

  @override
  Future<void> renameCollection(String id, String name) =>
      _mutate(_local.renameCollection(id, name));

  @override
  Future<void> deleteCollection(String id) =>
      _mutate(_local.deleteCollection(id));

  @override
  Future<String> addAttachment(
    String snippetId, {
    required String filename,
    required String mimeType,
    required Uint8List bytes,
  }) =>
      _mutate(_local.addAttachment(
        snippetId,
        filename: filename,
        mimeType: mimeType,
        bytes: bytes,
      ));

  @override
  Future<void> deleteAttachment(String id) =>
      _mutate(_local.deleteAttachment(id));
}
