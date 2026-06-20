import 'package:drift/drift.dart';

import '../../../core/db/app_database.dart';

// ===========================================================================
// PURE local-row <-> remote-map converters. No network, no Drift queries — just
// data shape translation, so they can be unit-tested in isolation.
//
// Column-name conventions:
//   * Local physical table `tags`        <-> remote `labels`        (same cols).
//   * Local physical table `snippet_tags`<-> remote `snippet_labels`
//        (local `tag_id` <-> remote `label_id`).
//   * owner_id is NEVER emitted to the remote: RLS + a server-side default set
//     it to auth.uid(). Sending it from the client would be rejected/ignored.
//   * Timestamps are epoch-ms bigint on both sides (no conversion needed).
// ===========================================================================

/// Reads an int from a remote JSON value that may arrive as int or num.
int? _asInt(Object? v) => v == null ? null : (v as num).toInt();

double? _asDouble(Object? v) => v == null ? null : (v as num).toDouble();

// --- snippets --------------------------------------------------------------

/// Local snippet row -> remote `snippets` map. owner_id intentionally omitted.
Map<String, dynamic> snippetRowToRemote(SnippetRow r) => {
      'id': r.id,
      'title': r.title,
      'body': r.body,
      'type': r.type,
      'language_id': r.languageId,
      'purpose': r.purpose,
      'description': r.description,
      'collection_id': r.collectionId,
      'is_favorite': r.isFavorite,
      'sort_index': r.sortIndex,
      'visibility': r.visibility,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'dirty': false,
    };

/// Remote `snippets` map -> local companion. dirty=false (it matches remote).
SnippetsCompanion remoteToSnippetCompanion(Map<String, dynamic> m) =>
    SnippetsCompanion(
      id: Value(m['id'] as String),
      title: Value(m['title'] as String? ?? ''),
      body: Value(m['body'] as String? ?? ''),
      type: Value(m['type'] as String? ?? 'text'),
      languageId: Value(m['language_id'] as String?),
      purpose: Value(m['purpose'] as String?),
      description: Value(m['description'] as String?),
      collectionId: Value(m['collection_id'] as String?),
      isFavorite: Value(m['is_favorite'] as bool? ?? false),
      sortIndex: Value(_asInt(m['sort_index'])),
      visibility: Value(m['visibility'] as String? ?? 'private'),
      createdAt: Value(_asInt(m['created_at']) ?? 0),
      updatedAt: Value(_asInt(m['updated_at']) ?? 0),
      deletedAt: Value(_asInt(m['deleted_at'])),
      dirty: const Value(false),
    );

// --- snippet_files ---------------------------------------------------------

Map<String, dynamic> snippetFileRowToRemote(SnippetFileRow r) => {
      'id': r.id,
      'snippet_id': r.snippetId,
      'filename': r.filename,
      'language_id': r.languageId,
      'content': r.content,
      'position': r.position,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'dirty': false,
    };

SnippetFilesCompanion remoteToSnippetFileCompanion(Map<String, dynamic> m) =>
    SnippetFilesCompanion(
      id: Value(m['id'] as String),
      snippetId: Value(m['snippet_id'] as String),
      filename: Value(m['filename'] as String? ?? ''),
      languageId: Value(m['language_id'] as String?),
      content: Value(m['content'] as String? ?? ''),
      position: Value(_asInt(m['position']) ?? 0),
      createdAt: Value(_asInt(m['created_at']) ?? 0),
      updatedAt: Value(_asInt(m['updated_at']) ?? 0),
      deletedAt: Value(_asInt(m['deleted_at'])),
      dirty: const Value(false),
    );

// --- collections -----------------------------------------------------------

Map<String, dynamic> collectionRowToRemote(CollectionRow r) => {
      'id': r.id,
      'name': r.name,
      'parent_id': r.parentId,
      'icon': r.icon,
      'color': r.color,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'dirty': false,
    };

CollectionsCompanion remoteToCollectionCompanion(Map<String, dynamic> m) =>
    CollectionsCompanion(
      id: Value(m['id'] as String),
      name: Value(m['name'] as String? ?? ''),
      parentId: Value(m['parent_id'] as String?),
      icon: Value(m['icon'] as String?),
      color: Value(m['color'] as String?),
      createdAt: Value(_asInt(m['created_at']) ?? 0),
      updatedAt: Value(_asInt(m['updated_at']) ?? 0),
      deletedAt: Value(_asInt(m['deleted_at'])),
      dirty: const Value(false),
    );

// --- tags <-> labels -------------------------------------------------------

/// Local `tags` row -> remote `labels` map. Same columns; just renamed table.
Map<String, dynamic> tagRowToLabelRemote(TagRow r) => {
      'id': r.id,
      'name': r.name,
      'normalized_name': r.normalizedName,
      'color': r.color,
      'parent_id': r.parentId,
      'created_at': r.createdAt,
      'updated_at': r.updatedAt,
      'deleted_at': r.deletedAt,
      'dirty': false,
    };

/// Remote `labels` map -> local `tags` companion.
TagsCompanion remoteLabelToTagCompanion(Map<String, dynamic> m) =>
    TagsCompanion(
      id: Value(m['id'] as String),
      name: Value(m['name'] as String? ?? ''),
      normalizedName: Value(m['normalized_name'] as String? ?? ''),
      color: Value(m['color'] as String?),
      parentId: Value(m['parent_id'] as String?),
      createdAt: Value(_asInt(m['created_at']) ?? 0),
      updatedAt: Value(_asInt(m['updated_at']) ?? 0),
      deletedAt: Value(_asInt(m['deleted_at'])),
      dirty: const Value(false),
    );

// --- snippet_tags <-> snippet_labels ---------------------------------------

/// Local join row -> remote `snippet_labels` map (tag_id -> label_id).
Map<String, dynamic> snippetTagRowToLabelRemote(SnippetTagRow r) => {
      'snippet_id': r.snippetId,
      'label_id': r.tagId,
      'created_at': r.createdAt,
    };

/// Remote `snippet_labels` map -> local `snippet_tags` companion
/// (label_id -> tag_id).
SnippetTagsCompanion remoteSnippetLabelToTagCompanion(
        Map<String, dynamic> m) =>
    SnippetTagsCompanion(
      snippetId: Value(m['snippet_id'] as String),
      tagId: Value(m['label_id'] as String),
      createdAt: Value(_asInt(m['created_at']) ?? 0),
    );

// --- ai_prompt_meta --------------------------------------------------------

Map<String, dynamic> aiPromptMetaRowToRemote(AiPromptMetaRow r) => {
      'snippet_id': r.snippetId,
      'target_model': r.targetModel,
      'model_provider': r.modelProvider,
      'system_prompt': r.systemPrompt,
      'temperature': r.temperature,
      'max_tokens': r.maxTokens,
      'variables_json': r.variablesJson,
      'updated_at': r.updatedAt,
    };

AiPromptMetaCompanion remoteToAiPromptMetaCompanion(Map<String, dynamic> m) =>
    AiPromptMetaCompanion(
      snippetId: Value(m['snippet_id'] as String),
      targetModel: Value(m['target_model'] as String?),
      modelProvider: Value(m['model_provider'] as String?),
      systemPrompt: Value(m['system_prompt'] as String?),
      temperature: Value(_asDouble(m['temperature'])),
      maxTokens: Value(_asInt(m['max_tokens'])),
      variablesJson: Value(m['variables_json'] as String? ?? '[]'),
      updatedAt: Value(_asInt(m['updated_at']) ?? 0),
    );
