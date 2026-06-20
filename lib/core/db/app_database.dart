import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../utils/ids.dart';
import 'seed_data.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Snippets,
    SnippetFiles,
    SnippetFileVersions,
    Languages,
    Collections,
    Tags,
    SnippetTags,
    AiPromptMeta,
    Purposes,
    Attachments,
  ],
)
class AppDatabase extends _$AppDatabase {
  /// Pass an [executor] in tests (e.g. an in-memory database). In the app the
  /// default opens the platform-appropriate connection.
  AppDatabase([QueryExecutor? executor]) : super(executor ?? _open());

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await _createSearchIndex();
          await _seed();
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(snippetFiles);
            await m.addColumn(snippets, snippets.visibility);
            await _backfillSnippetFiles();
          }
          if (from < 3) {
            await m.createTable(snippetFileVersions);
            await m.addColumn(tags, tags.parentId);
          }
          if (from < 4) {
            await m.createTable(attachments);
          }
        },
        beforeOpen: (details) async {
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  /// v1 -> v2 backfill: give every existing (non-deleted) snippet a single
  /// file row mirroring its denormalized body/languageId, so the multi-file
  /// reader has a row to read for legacy data.
  Future<void> _backfillSnippetFiles() async {
    final rows = await (select(snippets)
          ..where((s) => s.deletedAt.isNull()))
        .get();
    if (rows.isEmpty) return;
    await batch((b) {
      for (final row in rows) {
        b.insert(
          snippetFiles,
          SnippetFilesCompanion.insert(
            id: newId(),
            snippetId: row.id,
            filename: const Value(''),
            languageId: Value(row.languageId),
            content: Value(row.body),
            position: const Value(0),
            createdAt: row.updatedAt,
            updatedAt: row.updatedAt,
            dirty: const Value(true),
          ),
        );
      }
    });
  }

  /// Full-text search (Phase 3). A standalone FTS5 table mirroring the
  /// searchable snippet columns plus a denormalized `tag_text`, kept in sync by
  /// triggers on `snippets` and `snippet_tags`. Created via raw statements (not
  /// a .drift file) to avoid cross-referencing Dart tables from SQL.
  ///
  /// FTS5 is available at runtime on every platform: the bundled native lib and
  /// the web `sqlite3.wasm` both ship with FTS5 + json1 enabled.
  Future<void> _createSearchIndex() async {
    await customStatement(
      "CREATE VIRTUAL TABLE snippets_fts USING fts5("
      "title, body, description, tag_text, "
      "tokenize = 'unicode61 remove_diacritics 2')",
    );
    await customStatement(
      'CREATE TRIGGER snippets_fts_ai AFTER INSERT ON snippets BEGIN '
      'INSERT INTO snippets_fts(rowid, title, body, description, tag_text) '
      "VALUES (new.rowid, new.title, new.body, ifnull(new.description, ''), ''); "
      'END',
    );
    await customStatement(
      'CREATE TRIGGER snippets_fts_ad AFTER DELETE ON snippets BEGIN '
      'DELETE FROM snippets_fts WHERE rowid = old.rowid; END',
    );
    await customStatement(
      'CREATE TRIGGER snippets_fts_au AFTER UPDATE ON snippets BEGIN '
      'UPDATE snippets_fts SET title = new.title, body = new.body, '
      "description = ifnull(new.description, '') WHERE rowid = new.rowid; END",
    );
    // Re-denormalize tag_text whenever a snippet's tags change.
    const recompute = "ifnull((SELECT group_concat(t.name, ' ') "
        'FROM snippet_tags st JOIN tags t ON t.id = st.tag_id '
        "WHERE st.snippet_id = ?), '')";
    await customStatement(
      'CREATE TRIGGER snippet_tags_ai AFTER INSERT ON snippet_tags BEGIN '
      'UPDATE snippets_fts SET tag_text = '
      "${recompute.replaceFirst('?', 'new.snippet_id')} "
      'WHERE rowid = (SELECT rowid FROM snippets WHERE id = new.snippet_id); END',
    );
    await customStatement(
      'CREATE TRIGGER snippet_tags_ad AFTER DELETE ON snippet_tags BEGIN '
      'UPDATE snippets_fts SET tag_text = '
      "${recompute.replaceFirst('?', 'old.snippet_id')} "
      'WHERE rowid = (SELECT rowid FROM snippets WHERE id = old.snippet_id); END',
    );
  }

  /// Inserts reference data (languages, purposes) on first creation.
  Future<void> _seed() async {
    await batch((b) {
      b.insertAll(
        languages,
        [
          for (final l in seedLanguages)
            LanguagesCompanion.insert(
              id: l.id,
              name: l.name,
              fileExtension: l.extension,
              grammarId: l.grammarId,
              aliasesJson: Value(jsonEncode(l.aliases)),
            ),
        ],
      );
      b.insertAll(
        purposes,
        [
          for (final p in seedPurposes)
            PurposesCompanion.insert(
              id: p.id,
              label: p.label,
              appliesToType: Value(p.appliesToType),
            ),
        ],
      );
    });
  }

  /// Opens the database for the current platform. drift_flutter selects a
  /// native file (via path_provider) on desktop/mobile and a WASM-backed
  /// database on web, falling back OPFS -> IndexedDB -> in-memory.
  static QueryExecutor _open() {
    return driftDatabase(
      name: 'snippet_manager',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.dart.js'),
      ),
    );
  }
}
