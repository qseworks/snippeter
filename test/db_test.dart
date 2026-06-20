import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/core/db/app_database.dart';
import 'package:snippet_manager/core/utils/clock.dart';
import 'package:snippet_manager/core/utils/ids.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('seeds languages and purposes on first creation', () async {
    final langs = await db.select(db.languages).get();
    expect(langs.length, greaterThan(15));
    expect(langs.firstWhere((l) => l.id == 'python').fileExtension, '.py');

    final purposes = await db.select(db.purposes).get();
    expect(purposes, isNotEmpty);
  });

  test('insert a snippet and read it back with defaults applied', () async {
    final id = newId();
    final ts = nowMs();
    await db.into(db.snippets).insert(
          SnippetsCompanion.insert(
            id: id,
            title: 'Hello',
            body: 'print("hi")',
            type: 'code',
            languageId: const Value('python'),
            createdAt: ts,
            updatedAt: ts,
          ),
        );

    final row = await (db.select(db.snippets)
          ..where((t) => t.id.equals(id)))
        .getSingle();
    expect(row.title, 'Hello');
    expect(row.isFavorite, isFalse); // column default
    expect(row.dirty, isFalse); // sync flag default
    expect(row.deletedAt, isNull); // not soft-deleted
  });

  test('uuid v7 ids are time-ordered', () async {
    final a = newId();
    await Future<void>.delayed(const Duration(milliseconds: 2));
    final b = newId();
    expect(a.compareTo(b) < 0, isTrue);
  });
}
