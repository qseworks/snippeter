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
}
