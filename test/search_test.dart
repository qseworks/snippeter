import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/core/db/app_database.dart';
import 'package:snippet_manager/features/snippets/data/local_snippet_repository.dart';
import 'package:snippet_manager/features/snippets/domain/snippet.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_query.dart';
import 'package:snippet_manager/features/snippets/domain/snippet_type.dart';

void main() {
  late AppDatabase db;
  late LocalSnippetRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = LocalSnippetRepository(db);
  });
  tearDown(() => db.close());

  Future<void> seed() async {
    await repo.create(const SnippetDraft(
      title: 'Binary search',
      body: 'def bisect(arr, x): pass',
      type: SnippetType.code,
      languageId: 'python',
      labelNames: ['algorithm', 'search'],
    ));
    await repo.create(const SnippetDraft(
      title: 'Quick sort',
      body: 'def quicksort(a): pass',
      type: SnippetType.code,
      languageId: 'python',
      labelNames: ['algorithm'],
    ));
    await repo.create(const SnippetDraft(
      title: 'Greeting prompt',
      body: 'Write a greeting for {{name}}',
      type: SnippetType.aiPrompt,
      labelNames: ['prompt'],
    ));
  }

  Future<List<Snippet>> search(SnippetQuery q) => repo.watchSnippets(q).first;

  test('full-text search matches the body', () async {
    await seed();
    final r = await search(const SnippetQuery(text: 'quicksort'));
    expect(r.map((s) => s.title), ['Quick sort']);
  });

  test('prefix search matches partial terms', () async {
    await seed();
    final r = await search(const SnippetQuery(text: 'bis'));
    expect(r.any((s) => s.title == 'Binary search'), isTrue);
  });

  test('search matches denormalized tag_text (via triggers)', () async {
    await seed();
    final r = await search(const SnippetQuery(text: 'algorithm'));
    expect(r.map((s) => s.title).toSet(), {'Binary search', 'Quick sort'});
  });

  test('text + type filter combine', () async {
    await seed();
    final r = await search(
        const SnippetQuery(text: 'greeting', type: SnippetType.aiPrompt));
    expect(r.map((s) => s.title), ['Greeting prompt']);
  });

  test('tag filter without text', () async {
    await seed();
    final tags = await repo.watchLabels().first;
    final algoId =
        tags.firstWhere((t) => t.normalizedName == 'algorithm').id;
    final r = await search(SnippetQuery(labelIds: [algoId]));
    expect(r.length, 2);
  });

  test('editing tags updates the search index', () async {
    final id = await repo.create(const SnippetDraft(
      title: 'Note',
      body: 'plain content',
      type: SnippetType.text,
      labelNames: ['oldtag'],
    ));
    expect(
      (await search(const SnippetQuery(text: 'oldtag'))).any((s) => s.id == id),
      isTrue,
    );
    await repo.update(
      id,
      const SnippetDraft(
        title: 'Note',
        body: 'plain content',
        type: SnippetType.text,
        labelNames: ['freshtag'],
      ),
    );
    expect(
      (await search(const SnippetQuery(text: 'oldtag'))).any((s) => s.id == id),
      isFalse,
    );
    expect(
      (await search(const SnippetQuery(text: 'freshtag')))
          .any((s) => s.id == id),
      isTrue,
    );
  });

  test('soft-deleted snippets are excluded from search', () async {
    final id = await repo.create(const SnippetDraft(
        title: 'Temporary', body: 'deleteme soon', type: SnippetType.text));
    await repo.softDelete(id);
    final r = await search(const SnippetQuery(text: 'deleteme'));
    expect(r.any((s) => s.id == id), isFalse);
  });
}
