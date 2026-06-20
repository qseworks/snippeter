// Private fields can't be named initializing formals, so assign in the body.
// ignore_for_file: prefer_initializing_formals
import 'dart:typed_data';

import '../../snippets/domain/snippet.dart';
import '../../snippets/domain/snippet_query.dart';
import '../../snippets/domain/snippet_repository.dart';
import '../../snippets/domain/value_objects.dart';
import '../domain/sync_contracts.dart';

/// FUTURE (Phase 7 — designed, DEFERRED). Proves the seam: this wraps the local
/// repository and (later) a [RemoteSnippetDataSource] + [SyncEngine]. Today it
/// simply delegates to local. The ONLY change needed to introduce cloud sync is
/// pointing `snippetRepositoryProvider` at this class instead of
/// `LocalSnippetRepository` — the UI and state layers never change because they
/// depend on the [SnippetRepository] interface, not the implementation.
///
/// When sync ships, writes here will additionally enqueue an outbox [SyncOp]
/// and reads may merge remote changes; the local repository remains the
/// offline-first source of truth.
class SyncedSnippetRepository implements SnippetRepository {
  SyncedSnippetRepository({
    required SnippetRepository local,
    RemoteSnippetDataSource? remote,
    SyncEngine? syncEngine,
  })  : _local = local,
        _remote = remote,
        _syncEngine = syncEngine;

  final SnippetRepository _local;
  // ignore: unused_field — wired when sync ships.
  final RemoteSnippetDataSource? _remote;
  // ignore: unused_field — wired when sync ships.
  final SyncEngine? _syncEngine;

  @override
  Stream<List<Snippet>> watchSnippets(SnippetQuery query) =>
      _local.watchSnippets(query);

  @override
  Stream<Snippet?> watchSnippet(String id) => _local.watchSnippet(id);

  @override
  Future<Snippet?> getSnippet(String id) => _local.getSnippet(id);

  @override
  Future<String> create(SnippetDraft draft) => _local.create(draft);

  @override
  Future<void> update(String id, SnippetDraft draft) =>
      _local.update(id, draft);

  @override
  Future<void> setFavorite(String id, {required bool value}) =>
      _local.setFavorite(id, value: value);

  @override
  Future<void> softDelete(String id) => _local.softDelete(id);

  @override
  Future<List<SnippetVersion>> getVersions(String snippetId) =>
      _local.getVersions(snippetId);

  @override
  Future<void> restoreVersion(String snippetId, int savedAt) =>
      _local.restoreVersion(snippetId, savedAt);

  @override
  Stream<List<Label>> watchLabels() => _local.watchLabels();

  @override
  Future<String> createLabel(String name, {String? color, String? parentId}) =>
      _local.createLabel(name, color: color, parentId: parentId);

  @override
  Future<void> setLabelColor(String id, String color) =>
      _local.setLabelColor(id, color);

  @override
  Future<void> setLabelParent(String id, String? parentId) =>
      _local.setLabelParent(id, parentId);

  @override
  Future<void> renameLabel(String id, String name) =>
      _local.renameLabel(id, name);

  @override
  Future<void> deleteLabel(String id) => _local.deleteLabel(id);

  @override
  Stream<List<Collection>> watchCollections() => _local.watchCollections();

  @override
  Future<String> createCollection(String name, {String? parentId}) =>
      _local.createCollection(name, parentId: parentId);

  @override
  Future<void> renameCollection(String id, String name) =>
      _local.renameCollection(id, name);

  @override
  Future<void> deleteCollection(String id) => _local.deleteCollection(id);

  @override
  Future<String> addAttachment(
    String snippetId, {
    required String filename,
    required String mimeType,
    required Uint8List bytes,
  }) =>
      _local.addAttachment(
        snippetId,
        filename: filename,
        mimeType: mimeType,
        bytes: bytes,
      );

  @override
  Future<void> deleteAttachment(String id) => _local.deleteAttachment(id);

  @override
  Stream<List<Attachment>> watchAttachments(String snippetId) =>
      _local.watchAttachments(snippetId);

  @override
  Future<List<Language>> getLanguages() => _local.getLanguages();

  @override
  Future<List<Purpose>> getPurposes() => _local.getPurposes();
}
