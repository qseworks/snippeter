import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:snippet_manager/core/db/app_database.dart';
import 'package:snippet_manager/features/sync/data/sync_mappers.dart';

void main() {
  group('snippet mapping', () {
    test('snippetRowToRemote maps columns and NEVER emits owner_id', () {
      final row = SnippetRow(
        id: 's1',
        title: 'Hello',
        body: 'print(1)',
        type: 'code',
        languageId: 'python',
        purpose: null,
        description: 'desc',
        collectionId: 'c1',
        visibility: 'private',
        isFavorite: true,
        sortIndex: 3,
        createdAt: 100,
        updatedAt: 200,
        deletedAt: null,
        dirty: true,
        ownerId: 'should-not-leak',
      );

      final remote = snippetRowToRemote(row);

      expect(remote.containsKey('owner_id'), isFalse);
      expect(remote['id'], 's1');
      expect(remote['language_id'], 'python');
      expect(remote['collection_id'], 'c1');
      expect(remote['is_favorite'], true);
      expect(remote['sort_index'], 3);
      expect(remote['updated_at'], 200);
      // dirty is reset to false on the wire.
      expect(remote['dirty'], false);
    });

    test('remoteToSnippetCompanion round-trips a tombstone (deleted_at)', () {
      final remote = {
        'id': 's2',
        'title': 'Gone',
        'body': '',
        'type': 'text',
        'language_id': null,
        'purpose': null,
        'description': null,
        'collection_id': null,
        'is_favorite': false,
        'sort_index': null,
        'visibility': 'private',
        'created_at': 10,
        'updated_at': 50,
        'deleted_at': 50,
        'dirty': false,
      };

      final companion = remoteToSnippetCompanion(remote);
      expect(companion.id, const Value('s2'));
      expect(companion.deletedAt, const Value(50));
      expect(companion.dirty, const Value(false));
    });

    test('remote numeric timestamps tolerate num (double) values', () {
      final companion = remoteToSnippetCompanion({
        'id': 's3',
        'title': 't',
        'body': 'b',
        'type': 'code',
        'updated_at': 1234.0,
        'created_at': 1000.0,
      });
      expect(companion.updatedAt, const Value(1234));
      expect(companion.createdAt, const Value(1000));
    });
  });

  group('tags <-> labels', () {
    test('tag row maps to remote labels with same columns, no owner_id', () {
      final row = TagRow(
        id: 't1',
        name: 'Flutter',
        normalizedName: 'flutter',
        color: '#fff',
        parentId: 'p1',
        createdAt: 1,
        updatedAt: 2,
        deletedAt: null,
        dirty: true,
        ownerId: 'leak?',
      );

      final remote = tagRowToLabelRemote(row);
      expect(remote.containsKey('owner_id'), isFalse);
      expect(remote['id'], 't1');
      expect(remote['name'], 'Flutter');
      expect(remote['normalized_name'], 'flutter');
      expect(remote['parent_id'], 'p1');
    });

    test('remote label tombstone maps back into a tags companion', () {
      final companion = remoteLabelToTagCompanion({
        'id': 't2',
        'name': 'Old',
        'normalized_name': 'old',
        'color': null,
        'parent_id': null,
        'created_at': 5,
        'updated_at': 9,
        'deleted_at': 9,
      });
      expect(companion.id, const Value('t2'));
      expect(companion.normalizedName, const Value('old'));
      expect(companion.deletedAt, const Value(9));
      expect(companion.dirty, const Value(false));
    });
  });

  group('snippet_tags <-> snippet_labels', () {
    test('local tag_id maps to remote label_id', () {
      final row = SnippetTagRow(snippetId: 's1', tagId: 't1', createdAt: 7);
      final remote = snippetTagRowToLabelRemote(row);
      expect(remote['snippet_id'], 's1');
      expect(remote['label_id'], 't1');
      expect(remote.containsKey('tag_id'), isFalse);
      expect(remote['created_at'], 7);
    });

    test('remote label_id maps back to local tag_id', () {
      final companion = remoteSnippetLabelToTagCompanion({
        'snippet_id': 's1',
        'label_id': 't1',
        'created_at': 7,
      });
      expect(companion.snippetId, const Value('s1'));
      expect(companion.tagId, const Value('t1'));
      expect(companion.createdAt, const Value(7));
    });
  });

  group('ai_prompt_meta', () {
    test('round-trips fields including double temperature', () {
      final row = AiPromptMetaRow(
        snippetId: 's1',
        targetModel: 'gpt',
        modelProvider: 'openai',
        systemPrompt: 'sys',
        temperature: 0.7,
        maxTokens: 100,
        variablesJson: '["x"]',
        updatedAt: 42,
      );
      final remote = aiPromptMetaRowToRemote(row);
      expect(remote['snippet_id'], 's1');
      expect(remote['temperature'], 0.7);
      expect(remote.containsKey('owner_id'), isFalse);

      final companion = remoteToAiPromptMetaCompanion(remote);
      expect(companion.temperature, const Value(0.7));
      expect(companion.maxTokens, const Value(100));
      expect(companion.variablesJson, const Value('["x"]'));
    });
  });
}
