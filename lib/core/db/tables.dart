import 'package:drift/drift.dart';

// ---------------------------------------------------------------------------
// Sync-ready schema.
//
// Conventions applied to every *syncable* table (snippets, collections, tags):
//   - `id`         TEXT  UUIDv7 primary key (client-generated, never autoinc)
//   - `createdAt`  INT   epoch-ms UTC
//   - `updatedAt`  INT   epoch-ms UTC  -> enables last-write-wins merge later
//   - `deletedAt`  INT?  tombstone     -> soft delete only, never hard DELETE
//   - `dirty`      BOOL  reserved      -> outbox/sync dirty flag (unused now)
//   - `ownerId`    TEXT? reserved      -> Supabase auth.users id (unused now)
//
// Relationships are enforced in the repository layer rather than with DB-level
// foreign keys, to keep soft-delete semantics simple and migrations flexible.
// ---------------------------------------------------------------------------

/// Reference table mapping a language -> file extension -> highlighter grammar.
/// Seeded, user-extendable. Not a syncable user-data table.
@DataClassName('LanguageRow')
class Languages extends Table {
  TextColumn get id => text()(); // slug, e.g. 'python'
  TextColumn get name => text()(); // 'Python'
  TextColumn get fileExtension => text()(); // '.py'
  TextColumn get grammarId => text()(); // highlight.js grammar id, e.g. 'python'
  TextColumn get aliasesJson => text().withDefault(const Constant('[]'))();

  @override
  Set<Column> get primaryKey => {id};
}

/// Small seeded lookup for the "purpose" categorization (orthogonal to language
/// and type). User-extendable.
@DataClassName('PurposeRow')
class Purposes extends Table {
  TextColumn get id => text()(); // slug
  TextColumn get label => text()();
  TextColumn get appliesToType => text().nullable()(); // csv of types, or null

  @override
  Set<Column> get primaryKey => {id};
}

/// Folders, self-nestable via [parentId]. A snippet lives in 0..1 collection.
@DataClassName('CollectionRow')
@TableIndex(name: 'collection_parent_idx', columns: {#parentId})
class Collections extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get parentId => text().nullable()(); // self-reference (app-enforced)
  TextColumn get icon => text().nullable()();
  TextColumn get color => text().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  TextColumn get ownerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Free-form tags (cross-cutting, many-to-many with snippets).
@DataClassName('TagRow')
@TableIndex(name: 'tag_normalized_idx', columns: {#normalizedName})
class Tags extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get normalizedName => text()(); // lowercased; uniqueness app-enforced
  TextColumn get color => text().nullable()();
  TextColumn get parentId => text().nullable()(); // self-reference (app-enforced)
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  TextColumn get ownerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// The core polymorphic entity. [type] discriminates code / ai_prompt / text.
@DataClassName('SnippetRow')
@TableIndex(name: 'snippet_type_idx', columns: {#type})
@TableIndex(name: 'snippet_language_idx', columns: {#languageId})
@TableIndex(name: 'snippet_collection_idx', columns: {#collectionId})
@TableIndex(name: 'snippet_favorite_idx', columns: {#isFavorite})
@TableIndex(name: 'snippet_updated_idx', columns: {#updatedAt})
@TableIndex(name: 'snippet_deleted_idx', columns: {#deletedAt})
class Snippets extends Table {
  TextColumn get id => text()();
  TextColumn get title => text()();
  TextColumn get body => text()(); // the code / prompt / text — single source of truth
  TextColumn get type => text()(); // 'code' | 'ai_prompt' | 'text'
  TextColumn get languageId => text().nullable()();
  TextColumn get purpose => text().nullable()(); // -> purposes.id
  TextColumn get description => text().nullable()();
  TextColumn get collectionId => text().nullable()();
  TextColumn get visibility => text().withDefault(const Constant('private'))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get sortIndex => integer().nullable()();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  TextColumn get ownerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Ordered files belonging to a snippet. A snippet always has >= 1 file; the
/// first file mirrors the denormalized `snippets.body`/`languageId` for FTS and
/// legacy single-body back-compat. Soft-deletable + sync-ready like other tables.
@DataClassName('SnippetFileRow')
@TableIndex(name: 'snippet_files_snippet_idx', columns: {#snippetId})
@TableIndex(name: 'snippet_files_deleted_idx', columns: {#deletedAt})
class SnippetFiles extends Table {
  TextColumn get id => text()();
  TextColumn get snippetId => text()();
  TextColumn get filename => text().withDefault(const Constant(''))();
  TextColumn get languageId => text().nullable()();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get createdAt => integer()();
  IntColumn get updatedAt => integer()();
  IntColumn get deletedAt => integer().nullable()();
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  TextColumn get ownerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Immutable history snapshots of a snippet's files. A "version" is the set of
/// rows sharing the same [savedAt]: every time a snippet's files are replaced
/// the previous file set is copied here verbatim, so history can be browsed and
/// restored. Append-only — never updated, only inserted/read.
@DataClassName('SnippetFileVersionRow')
@TableIndex(name: 'snippet_file_versions_snippet_idx', columns: {#snippetId})
@TableIndex(name: 'snippet_file_versions_saved_idx', columns: {#savedAt})
class SnippetFileVersions extends Table {
  TextColumn get id => text()();
  TextColumn get snippetId => text()();
  TextColumn get filename => text().withDefault(const Constant(''))();
  TextColumn get languageId => text().nullable()();
  TextColumn get content => text().withDefault(const Constant(''))();
  IntColumn get position => integer().withDefault(const Constant(0))();
  IntColumn get savedAt => integer()(); // groups rows into one version
  BoolColumn get dirty => boolean().withDefault(const Constant(false))();
  TextColumn get ownerId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Many-to-many join between snippets and tags.
@DataClassName('SnippetTagRow')
@TableIndex(name: 'snippet_tags_tag_idx', columns: {#tagId})
class SnippetTags extends Table {
  TextColumn get snippetId => text()();
  TextColumn get tagId => text()();
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {snippetId, tagId};
}

/// 1:1 extension row that exists only when a snippet's type is 'ai_prompt'.
@DataClassName('AiPromptMetaRow')
class AiPromptMeta extends Table {
  TextColumn get snippetId => text()(); // shared PK with snippets -> enforces 1:1
  TextColumn get targetModel => text().nullable()();
  TextColumn get modelProvider => text().nullable()();
  TextColumn get systemPrompt => text().nullable()();
  RealColumn get temperature => real().nullable()();
  IntColumn get maxTokens => integer().nullable()();
  TextColumn get variablesJson => text().withDefault(const Constant('[]'))();
  IntColumn get updatedAt => integer()();

  @override
  Set<Column> get primaryKey => {snippetId};
}
