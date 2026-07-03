import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/core/db/app_database.dart';
import 'package:snippet_manager/features/snippets/data/local_snippet_repository.dart';
import 'package:snippet_manager/features/snippets/domain/snippet.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_query.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_type.dart';
import 'package:snippet_manager/features/snippets/domain/value_objects.dart';

void main() {
  late AppDatabase db;
  late LocalSnippetRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LocalSnippetRepository(db);
  });
  tearDown(() => db.close());

  test('create with tags + language, then read back', () async {
    final id = await repo.create(const SnippetDraft(
      title: 'Hello',
      body: 'print(1)',
      type: SnippetType.code,
      languageId: 'python',
      labelNames: ['Util', 'demo'],
    ));
    final s = await repo.getSnippet(id);
    expect(s, isNotNull);
    expect(s!.title, 'Hello');
    expect(s.languageId, 'python');
    expect(s.labels.map((t) => t.name).toSet(), {'Util', 'demo'});
  });

  test('tags de-duplicate case-insensitively and are reused', () async {
    await repo.create(const SnippetDraft(
        title: 'a', body: '', type: SnippetType.text, labelNames: ['Flutter']));
    await repo.create(const SnippetDraft(
        title: 'b', body: '', type: SnippetType.text, labelNames: ['flutter']));
    final tags = await repo.watchLabels().first;
    expect(tags.where((t) => t.normalizedName == 'flutter').length, 1);
  });

  test('soft delete removes a snippet from the list', () async {
    final id = await repo.create(
        const SnippetDraft(title: 'x', body: '', type: SnippetType.text));
    await repo.softDelete(id);
    final list = await repo.watchSnippets(const SnippetQuery()).first;
    expect(list.any((s) => s.id == id), isFalse);
  });

  test('personal query (workspaceId null) excludes team snippets', () async {
    final personalId = await repo.create(
        const SnippetDraft(title: 'p', body: '', type: SnippetType.text));
    final teamId = await repo.create(const SnippetDraft(
        title: 't', body: '', type: SnippetType.text, workspaceId: 'ws1'));

    final personal = await repo.watchSnippets(const SnippetQuery()).first;
    expect(personal.map((s) => s.id), contains(personalId));
    expect(personal.map((s) => s.id), isNot(contains(teamId)));
  });

  test('team query returns only that workspace, with workspaceId persisted',
      () async {
    final teamId = await repo.create(const SnippetDraft(
      title: 't',
      body: 'x',
      type: SnippetType.code,
      labelNames: ['shared'],
      workspaceId: 'ws1',
    ));
    await repo.create(const SnippetDraft(
        title: 'other', body: '', type: SnippetType.text, workspaceId: 'ws2'));
    await repo.create(
        const SnippetDraft(title: 'p', body: '', type: SnippetType.text));

    final team =
        await repo.watchSnippets(const SnippetQuery(workspaceId: 'ws1')).first;
    expect(team.map((s) => s.id), [teamId]);
    expect(team.single.workspaceId, 'ws1');
  });

  test('favorite toggle surfaces in the favorites query', () async {
    final id = await repo.create(
        const SnippetDraft(title: 'f', body: '', type: SnippetType.text));
    await repo.setFavorite(id, value: true);
    final favs = await repo
        .watchSnippets(const SnippetQuery(favoritesOnly: true))
        .first;
    expect(favs.any((s) => s.id == id), isTrue);
  });

  test('ai_prompt variables are parsed from the body', () async {
    final id = await repo.create(const SnippetDraft(
      title: 'p',
      body: 'Hello {{name}}, you are a {{role}}.',
      type: SnippetType.aiPrompt,
      promptMeta: AiPromptMeta(modelProvider: 'Anthropic'),
    ));
    final s = await repo.getSnippet(id);
    expect(s!.promptMeta, isNotNull);
    expect(s.promptMeta!.variables.map((v) => v.name).toList(),
        ['name', 'role']);
    expect(s.promptMeta!.modelProvider, 'Anthropic');
  });

  test('switching away from ai_prompt drops prompt meta', () async {
    final id = await repo.create(const SnippetDraft(
      title: 'p',
      body: '{{x}}',
      type: SnippetType.aiPrompt,
    ));
    await repo.update(
        id, const SnippetDraft(title: 'p', body: 'x', type: SnippetType.code));
    final s = await repo.getSnippet(id);
    expect(s!.type, SnippetType.code);
    expect(s.promptMeta, isNull);
  });

  test('update changes fields and replaces tags', () async {
    final id = await repo.create(const SnippetDraft(
        title: 't', body: 'a', type: SnippetType.code, labelNames: ['one']));
    await repo.update(
        id,
        const SnippetDraft(
            title: 't2',
            body: 'b',
            type: SnippetType.code,
            labelNames: ['two', 'three']));
    final s = await repo.getSnippet(id);
    expect(s!.title, 't2');
    expect(s.body, 'b');
    expect(s.labels.map((t) => t.name).toSet(), {'two', 'three'});
  });

  test('deleting a collection detaches its snippets', () async {
    final colId = await repo.createCollection('My Folder');
    final id = await repo.create(SnippetDraft(
        title: 'c', body: '', type: SnippetType.text, collectionId: colId));
    await repo.deleteCollection(colId);
    final s = await repo.getSnippet(id);
    expect(s!.collectionId, isNull);
    final cols = await repo.watchCollections().first;
    expect(cols.any((c) => c.id == colId), isFalse);
  });

  test('update snapshots the previous files into version history', () async {
    final id = await repo.create(const SnippetDraft(
        title: 't', body: 'v1', type: SnippetType.code, languageId: 'python'));
    // create() takes no snapshot.
    expect(await repo.getVersions(id), isEmpty);

    await repo.update(
        id, const SnippetDraft(title: 't', body: 'v2', type: SnippetType.code));
    final versions = await repo.getVersions(id);
    expect(versions.length, 1);
    expect(versions.single.files.single.content, 'v1');
  });

  test('restoreVersion reverts current files and is itself undoable', () async {
    final id = await repo.create(const SnippetDraft(
        title: 't', body: 'v1', type: SnippetType.code, languageId: 'python'));
    await repo.update(
        id, const SnippetDraft(title: 't', body: 'v2', type: SnippetType.code));

    final v1 = (await repo.getVersions(id)).single; // the 'v1' snapshot
    await repo.restoreVersion(id, v1.savedAt);

    final s = await repo.getSnippet(id);
    expect(s!.body, 'v1');
    expect(s.languageId, 'python');
    // The current 'v2' was snapshotted before restoring -> 2 versions now.
    final versions = await repo.getVersions(id);
    expect(versions.length, 2);
    expect(versions.map((v) => v.files.single.content), containsAll(['v1', 'v2']));
  });

  test('setLabelParent persists a nested label parent', () async {
    final parent = await repo.createLabel('Backend');
    final child = await repo.createLabel('API', parentId: parent);
    var labels = await repo.watchLabels().first;
    expect(labels.firstWhere((l) => l.id == child).parentId, parent);

    await repo.setLabelParent(child, null);
    labels = await repo.watchLabels().first;
    expect(labels.firstWhere((l) => l.id == child).parentId, isNull);
  });

  test('undoDelete restores a soft-deleted snippet', () async {
    final id = await repo.create(
        const SnippetDraft(title: 'x', body: '', type: SnippetType.text));
    await repo.softDelete(id);
    expect(await repo.watchSnippets(const SnippetQuery()).first, isEmpty);

    await repo.undoDelete(id);
    final list = await repo.watchSnippets(const SnippetQuery()).first;
    expect(list.map((s) => s.id), [id]);
  });

  test('watchLibraryStats aggregates counts database-side', () async {
    final a = await repo.create(const SnippetDraft(
        title: 'a',
        body: '',
        type: SnippetType.code,
        languageId: 'python',
        labelNames: ['util']));
    await repo.create(const SnippetDraft(
        title: 'b', body: '', type: SnippetType.code, languageId: 'python'));
    final c = await repo.create(
        const SnippetDraft(title: 'c', body: '', type: SnippetType.text));
    await repo.setFavorite(a, value: true);
    // A team snippet must not count toward the personal library.
    await repo.create(const SnippetDraft(
        title: 'team', body: '', type: SnippetType.text, workspaceId: 'ws1'));

    final stats = await repo.watchLibraryStats().first;
    expect(stats.total, 3);
    expect(stats.starred, 1);
    expect(stats.unlabeled, 2);
    expect(stats.byLanguageId, {'python': 2});
    expect(stats.byLabelId.values.toList(), [1]);

    // Deleted snippets drop out of every bucket.
    await repo.softDelete(c);
    final after = await repo.watchLibraryStats().first;
    expect(after.total, 2);
    expect(after.unlabeled, 1);

    // The team library counts only its own rows.
    final team = await repo.watchLibraryStats(workspaceId: 'ws1').first;
    expect(team.total, 1);
    expect(team.unlabeled, 1);
  });
}
