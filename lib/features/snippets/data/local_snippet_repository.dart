import 'dart:convert';

import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';
import '../../../core/utils/clock.dart';
import '../../../core/utils/ids.dart';
import '../domain/snippet.dart';
import '../domain/snippet_query.dart';
import '../domain/snippet_repository.dart';
import '../domain/snippet_type.dart';
import '../domain/value_objects.dart';
import 'prompt_variables.dart';

/// Drift-backed [SnippetRepository]. Maps rows <-> domain entities and exposes
/// reactive streams via Drift's `watch`. The rest of the app never sees Drift.
class LocalSnippetRepository implements SnippetRepository {
  LocalSnippetRepository(this._db);

  final AppDatabase _db;

  // --- snippets ------------------------------------------------------------

  @override
  Stream<List<Snippet>> watchSnippets(SnippetQuery query) {
    final match = query.hasText ? _toFtsMatch(query.text!) : '';
    final useFts = match.isNotEmpty;

    final where = <String>['s.deleted_at IS NULL'];
    final vars = <Variable<Object>>[];
    var from = 'FROM snippets s';

    if (useFts) {
      from += ' JOIN snippets_fts ON snippets_fts.rowid = s.rowid';
      where.add('snippets_fts MATCH ?');
      vars.add(Variable<String>(match));
    }
    if (query.favoritesOnly) where.add('s.is_favorite = 1');
    if (query.type != null) {
      where.add('s.type = ?');
      vars.add(Variable<String>(query.type!.wire));
    }
    if (query.languageId != null) {
      where.add('s.language_id = ?');
      vars.add(Variable<String>(query.languageId!));
    }
    if (query.collectionId != null) {
      where.add('s.collection_id = ?');
      vars.add(Variable<String>(query.collectionId!));
    }
    if (query.unlabeled) {
      where.add('s.id NOT IN (SELECT snippet_id FROM snippet_tags)');
    }
    if (query.labelIds.isNotEmpty) {
      final placeholders = List.filled(query.labelIds.length, '?').join(', ');
      if (query.labelsMatchAll) {
        where.add('s.id IN (SELECT snippet_id FROM snippet_tags '
            'WHERE tag_id IN ($placeholders) GROUP BY snippet_id '
            'HAVING COUNT(DISTINCT tag_id) = ?)');
        vars.addAll(query.labelIds.map((t) => Variable<String>(t)));
        vars.add(Variable<int>(query.labelIds.length));
      } else {
        where.add('s.id IN (SELECT snippet_id FROM snippet_tags '
            'WHERE tag_id IN ($placeholders))');
        vars.addAll(query.labelIds.map((t) => Variable<String>(t)));
      }
    }

    final String orderBy;
    switch (query.sort) {
      case SnippetSort.relevance:
        // bm25 returns more-negative for better matches -> ascending = best
        // first. Title and tag_text are boosted over body/description.
        orderBy = useFts
            ? 'bm25(snippets_fts, 10.0, 1.0, 2.0, 5.0)'
            : 's.updated_at DESC';
      case SnippetSort.recent:
        orderBy = 's.updated_at DESC';
      case SnippetSort.created:
        orderBy = 's.created_at DESC';
      case SnippetSort.titleAsc:
        orderBy = 's.title COLLATE NOCASE ASC';
    }

    final sql =
        'SELECT s.* $from WHERE ${where.join(' AND ')} ORDER BY $orderBy';

    return _db
        .customSelect(
          sql,
          variables: vars,
          readsFrom: {
            _db.snippets,
            _db.snippetFiles,
            _db.snippetTags,
            _db.tags,
          },
        )
        .watch()
        .asyncMap(
          (rows) =>
              _attachRelations([for (final r in rows) _db.snippets.map(r.data)]),
        );
  }

  /// Builds a safe FTS5 prefix query from free user text: each alphanumeric
  /// token becomes a quoted prefix term (`"foo"*`), AND-combined. Returns ''
  /// when there is nothing usable (the caller then skips FTS and browses).
  String _toFtsMatch(String text) {
    final tokens = text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9_\s]'), ' ')
        .split(RegExp(r'\s+'))
        .where((t) => t.isNotEmpty)
        .toList();
    if (tokens.isEmpty) return '';
    return tokens.map((t) => '"$t"*').join(' ');
  }

  @override
  Stream<Snippet?> watchSnippet(String id) {
    final select = _db.select(_db.snippets)
      ..where((t) => t.id.equals(id) & t.deletedAt.isNull());
    return select.watch().asyncMap((rows) async {
      if (rows.isEmpty) return null;
      return (await _attachRelations(rows)).first;
    });
  }

  @override
  Future<Snippet?> getSnippet(String id) async {
    final rows = await (_db.select(_db.snippets)
          ..where((t) => t.id.equals(id) & t.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) return null;
    return (await _attachRelations(rows)).first;
  }

  /// Resolves the effective list of files for a draft: explicit [files] when
  /// provided, otherwise a single file synthesized from the legacy
  /// body/languageId so the single-body API keeps working unchanged.
  List<SnippetFileDraft> _effectiveFiles(SnippetDraft d) => d.files.isNotEmpty
      ? d.files
      : [SnippetFileDraft(filename: '', languageId: d.languageId, content: d.body)];

  /// Denormalized body for FTS: all file contents joined.
  String _denormBody(List<SnippetFileDraft> files) =>
      files.map((f) => f.content).join('\n\n');

  @override
  Future<String> create(SnippetDraft draft) async {
    final id = newId();
    final ts = nowMs();
    final files = _effectiveFiles(draft);
    await _db.transaction(() async {
      await _db.into(_db.snippets).insert(
            SnippetsCompanion.insert(
              id: id,
              title: draft.title,
              body: _denormBody(files),
              type: draft.type.wire,
              languageId: Value(files.first.languageId),
              purpose: Value(draft.purpose),
              description: Value(draft.description),
              collectionId: Value(draft.collectionId),
              visibility: Value(draft.visibility.wire),
              isFavorite: Value(draft.isFavorite),
              createdAt: ts,
              updatedAt: ts,
              dirty: const Value(true),
            ),
          );
      await _writeFiles(id, files, ts);
      await _writeLabels(id, draft.labelNames, ts);
      await _writePromptMeta(id, draft, ts);
    });
    return id;
  }

  @override
  Future<void> update(String id, SnippetDraft draft) async {
    final ts = nowMs();
    final files = _effectiveFiles(draft);
    await _db.transaction(() async {
      await (_db.update(_db.snippets)..where((t) => t.id.equals(id))).write(
        SnippetsCompanion(
          title: Value(draft.title),
          body: Value(_denormBody(files)),
          type: Value(draft.type.wire),
          languageId: Value(files.first.languageId),
          purpose: Value(draft.purpose),
          description: Value(draft.description),
          collectionId: Value(draft.collectionId),
          visibility: Value(draft.visibility.wire),
          isFavorite: Value(draft.isFavorite),
          updatedAt: Value(ts),
          dirty: const Value(true),
        ),
      );
      await _writeFiles(id, files, ts);
      await _writeLabels(id, draft.labelNames, ts);
      await _writePromptMeta(id, draft, ts);
    });
  }

  /// Replaces the file set for [snippetId]: hard-deletes existing rows, then
  /// inserts one row per draft file with `position` = index.
  Future<void> _writeFiles(
    String snippetId,
    List<SnippetFileDraft> files,
    int ts,
  ) async {
    await (_db.delete(_db.snippetFiles)
          ..where((f) => f.snippetId.equals(snippetId)))
        .go();
    for (var i = 0; i < files.length; i++) {
      final f = files[i];
      await _db.into(_db.snippetFiles).insert(
            SnippetFilesCompanion.insert(
              id: newId(),
              snippetId: snippetId,
              filename: Value(f.filename),
              languageId: Value(f.languageId),
              content: Value(f.content),
              position: Value(i),
              createdAt: ts,
              updatedAt: ts,
              dirty: const Value(true),
            ),
          );
    }
  }

  @override
  Future<void> setFavorite(String id, {required bool value}) async {
    await (_db.update(_db.snippets)..where((t) => t.id.equals(id))).write(
      SnippetsCompanion(
        isFavorite: Value(value),
        updatedAt: Value(nowMs()),
        dirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> softDelete(String id) async {
    final ts = nowMs();
    await (_db.update(_db.snippets)..where((t) => t.id.equals(id))).write(
      SnippetsCompanion(
        deletedAt: Value(ts),
        updatedAt: Value(ts),
        dirty: const Value(true),
      ),
    );
  }

  // --- labels --------------------------------------------------------------

  @override
  Stream<List<Label>> watchLabels() {
    final select = _db.select(_db.tags)
      ..where((t) => t.deletedAt.isNull())
      ..orderBy([(t) => OrderingTerm.asc(t.normalizedName)]);
    return select.watch().map((rows) => [for (final r in rows) _toLabel(r)]);
  }

  @override
  Future<String> createLabel(String name, {String? color}) async {
    final id = newId();
    final ts = nowMs();
    await _db.into(_db.tags).insert(
          TagsCompanion.insert(
            id: id,
            name: name,
            normalizedName: Label.normalize(name),
            color: Value(color),
            createdAt: ts,
            updatedAt: ts,
            dirty: const Value(true),
          ),
        );
    return id;
  }

  @override
  Future<void> setLabelColor(String id, String color) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
      TagsCompanion(
        color: Value(color),
        updatedAt: Value(nowMs()),
        dirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> renameLabel(String id, String name) async {
    await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
      TagsCompanion(
        name: Value(name),
        normalizedName: Value(Label.normalize(name)),
        updatedAt: Value(nowMs()),
        dirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> deleteLabel(String id) async {
    final ts = nowMs();
    await _db.transaction(() async {
      await (_db.update(_db.tags)..where((t) => t.id.equals(id))).write(
        TagsCompanion(
          deletedAt: Value(ts),
          updatedAt: Value(ts),
          dirty: const Value(true),
        ),
      );
      await (_db.delete(_db.snippetTags)..where((j) => j.tagId.equals(id))).go();
    });
  }

  Future<void> _writeLabels(
      String snippetId, List<String> names, int ts) async {
    await (_db.delete(_db.snippetTags)
          ..where((j) => j.snippetId.equals(snippetId)))
        .go();
    final seen = <String>{};
    for (final raw in names) {
      final name = raw.trim();
      if (name.isEmpty) continue;
      if (!seen.add(Label.normalize(name))) continue;
      final label = await _findOrCreateLabel(name, ts);
      await _db.into(_db.snippetTags).insert(
            SnippetTagsCompanion.insert(
              snippetId: snippetId,
              tagId: label.id,
              createdAt: ts,
            ),
          );
    }
  }

  Future<TagRow> _findOrCreateLabel(String name, int ts) async {
    final norm = Label.normalize(name);
    final existing = await (_db.select(_db.tags)
          ..where((t) => t.normalizedName.equals(norm) & t.deletedAt.isNull())
          ..limit(1))
        .getSingleOrNull();
    if (existing != null) return existing;
    final id = newId();
    await _db.into(_db.tags).insert(
          TagsCompanion.insert(
            id: id,
            name: name,
            normalizedName: norm,
            createdAt: ts,
            updatedAt: ts,
            dirty: const Value(true),
          ),
        );
    return (_db.select(_db.tags)..where((t) => t.id.equals(id))).getSingle();
  }

  // --- prompt meta ---------------------------------------------------------

  Future<void> _writePromptMeta(
    String snippetId,
    SnippetDraft draft,
    int ts,
  ) async {
    if (draft.type != SnippetType.aiPrompt) {
      await (_db.delete(_db.aiPromptMeta)
            ..where((m) => m.snippetId.equals(snippetId)))
          .go();
      return;
    }
    final meta = draft.promptMeta ?? const AiPromptMeta();
    final variables = reconcilePromptVariables(draft.body, meta.variables);
    await _db.into(_db.aiPromptMeta).insertOnConflictUpdate(
          AiPromptMetaCompanion.insert(
            snippetId: snippetId,
            targetModel: Value(meta.targetModel),
            modelProvider: Value(meta.modelProvider),
            systemPrompt: Value(meta.systemPrompt),
            temperature: Value(meta.temperature),
            maxTokens: Value(meta.maxTokens),
            variablesJson: Value(AiPromptMeta.encodeVariables(variables)),
            updatedAt: ts,
          ),
        );
  }

  // --- collections ---------------------------------------------------------

  @override
  Stream<List<Collection>> watchCollections() {
    final select = _db.select(_db.collections)
      ..where((c) => c.deletedAt.isNull())
      ..orderBy([(c) => OrderingTerm.asc(c.name)]);
    return select
        .watch()
        .map((rows) => [for (final r in rows) _toCollection(r)]);
  }

  @override
  Future<String> createCollection(String name, {String? parentId}) async {
    final id = newId();
    final ts = nowMs();
    await _db.into(_db.collections).insert(
          CollectionsCompanion.insert(
            id: id,
            name: name,
            parentId: Value(parentId),
            createdAt: ts,
            updatedAt: ts,
            dirty: const Value(true),
          ),
        );
    return id;
  }

  @override
  Future<void> renameCollection(String id, String name) async {
    await (_db.update(_db.collections)..where((c) => c.id.equals(id))).write(
      CollectionsCompanion(
        name: Value(name),
        updatedAt: Value(nowMs()),
        dirty: const Value(true),
      ),
    );
  }

  @override
  Future<void> deleteCollection(String id) async {
    final ts = nowMs();
    await _db.transaction(() async {
      await (_db.update(_db.collections)..where((c) => c.id.equals(id))).write(
        CollectionsCompanion(
          deletedAt: Value(ts),
          updatedAt: Value(ts),
          dirty: const Value(true),
        ),
      );
      // Detach snippets from the removed collection (don't delete them).
      await (_db.update(_db.snippets)
            ..where((s) => s.collectionId.equals(id)))
          .write(
        SnippetsCompanion(
          collectionId: const Value(null),
          updatedAt: Value(ts),
          dirty: const Value(true),
        ),
      );
    });
  }

  // --- reference data ------------------------------------------------------

  @override
  Future<List<Language>> getLanguages() async {
    final rows = await (_db.select(_db.languages)
          ..orderBy([(l) => OrderingTerm.asc(l.name)]))
        .get();
    return [for (final r in rows) _toLanguage(r)];
  }

  @override
  Future<List<Purpose>> getPurposes() async {
    final rows = await _db.select(_db.purposes).get();
    return [
      for (final r in rows)
        Purpose(id: r.id, label: r.label, appliesToType: r.appliesToType),
    ];
  }

  // --- mappers -------------------------------------------------------------

  Snippet _toSnippet(
    SnippetRow r,
    List<Label> labels,
    AiPromptMeta? meta,
    List<SnippetFile> files,
  ) {
    // Back-compat: domain body/languageId track the first file when present,
    // falling back to the denormalized snippet row for legacy/empty data.
    final first = files.isNotEmpty ? files.first : null;
    return Snippet(
      id: r.id,
      title: r.title,
      body: first?.content ?? r.body,
      type: SnippetType.fromWire(r.type),
      languageId: first?.languageId ?? r.languageId,
      purpose: r.purpose,
      description: r.description,
      collectionId: r.collectionId,
      isFavorite: r.isFavorite,
      sortIndex: r.sortIndex,
      createdAt: r.createdAt,
      updatedAt: r.updatedAt,
      labels: labels,
      promptMeta: meta,
      files: files,
      visibility: SnippetVisibility.fromWire(r.visibility),
    );
  }

  SnippetFile _toFile(SnippetFileRow r) => SnippetFile(
        id: r.id,
        filename: r.filename,
        languageId: r.languageId,
        content: r.content,
        position: r.position,
      );

  Label _toLabel(TagRow r) => Label(
        id: r.id,
        name: r.name,
        normalizedName: r.normalizedName,
        color: r.color,
      );

  Collection _toCollection(CollectionRow r) => Collection(
        id: r.id,
        name: r.name,
        parentId: r.parentId,
        icon: r.icon,
        color: r.color,
      );

  Language _toLanguage(LanguageRow r) => Language(
        id: r.id,
        name: r.name,
        fileExtension: r.fileExtension,
        grammarId: r.grammarId,
        aliases: (jsonDecode(r.aliasesJson) as List).cast<String>(),
      );

  AiPromptMeta _toMeta(AiPromptMetaRow r) => AiPromptMeta(
        targetModel: r.targetModel,
        modelProvider: r.modelProvider,
        systemPrompt: r.systemPrompt,
        temperature: r.temperature,
        maxTokens: r.maxTokens,
        variables: AiPromptMeta.decodeVariables(r.variablesJson),
      );

  // --- internal ------------------------------------------------------------

  Future<List<Snippet>> _attachRelations(List<SnippetRow> rows) async {
    if (rows.isEmpty) return const [];
    final ids = [for (final r in rows) r.id];

    final joins = await (_db.select(_db.snippetTags)
          ..where((j) => j.snippetId.isIn(ids)))
        .get();
    final labelIds = {for (final j in joins) j.tagId}.toList();
    final labelRows = labelIds.isEmpty
        ? <TagRow>[]
        : await (_db.select(_db.tags)..where((t) => t.id.isIn(labelIds))).get();
    final labelById = {for (final t in labelRows) t.id: _toLabel(t)};
    final labelsBySnippet = <String, List<Label>>{};
    for (final j in joins) {
      final label = labelById[j.tagId];
      if (label != null) (labelsBySnippet[j.snippetId] ??= []).add(label);
    }

    final promptIds = [
      for (final r in rows)
        if (r.type == SnippetType.aiPrompt.wire) r.id,
    ];
    final metaRows = promptIds.isEmpty
        ? <AiPromptMetaRow>[]
        : await (_db.select(_db.aiPromptMeta)
              ..where((m) => m.snippetId.isIn(promptIds)))
            .get();
    final metaBySnippet = {for (final m in metaRows) m.snippetId: _toMeta(m)};

    final fileRows = await (_db.select(_db.snippetFiles)
          ..where((f) => f.snippetId.isIn(ids) & f.deletedAt.isNull())
          ..orderBy([(f) => OrderingTerm.asc(f.position)]))
        .get();
    final filesBySnippet = <String, List<SnippetFile>>{};
    for (final f in fileRows) {
      (filesBySnippet[f.snippetId] ??= []).add(_toFile(f));
    }

    return [
      for (final r in rows)
        _toSnippet(
          r,
          labelsBySnippet[r.id] ?? const [],
          metaBySnippet[r.id],
          filesBySnippet[r.id] ?? const [],
        ),
    ];
  }
}
