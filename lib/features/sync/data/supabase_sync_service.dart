// Private fields can't be named initializing formals, so assign in the body.
// ignore_for_file: prefer_initializing_formals
import 'dart:async';
import 'dart:developer' as developer;

import 'package:drift/drift.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/db/app_database.dart';
import 'sync_mappers.dart';

/// Offline-first push/pull sync engine over the local [AppDatabase] and a
/// Supabase client. Local is always the source of truth; this layer mirrors
/// changes both ways with last-write-wins on `updated_at`.
///
/// All network errors are swallowed/logged: being offline must never crash the
/// app. The conversion of rows <-> remote maps lives in `sync_mappers.dart` as
/// pure functions so it stays unit-testable without a network.
class SupabaseSyncService {
  SupabaseSyncService({
    required AppDatabase db,
    required SupabaseClient client,
    required SharedPreferences prefs,
  })  : _db = db,
        _client = client,
        _prefs = prefs;

  final AppDatabase _db;
  final SupabaseClient _client;
  final SharedPreferences _prefs;

  bool _running = false;
  Timer? _debounce;
  final List<RealtimeChannel> _channels = [];

  static const _debounceDelay = Duration(milliseconds: 800);

  String? get _userId => _client.auth.currentSession?.user.id;

  String get _lastSyncedKey => 'sync.lastSyncedAt.${_userId ?? 'anon'}';

  int get _lastSyncedAt => _prefs.getInt(_lastSyncedKey) ?? 0;

  Future<void> _setLastSyncedAt(int v) => _prefs.setInt(_lastSyncedKey, v);

  // --- public entry points ---------------------------------------------------

  /// Debounced trigger: coalesces bursts of mutations into a single [syncOnce].
  /// No-op when signed out.
  void scheduleSync() {
    if (_userId == null) return;
    _debounce?.cancel();
    _debounce = Timer(_debounceDelay, syncOnce);
  }

  /// Runs one push-then-pull cycle. Guarded against concurrency and offline.
  Future<void> syncOnce() async {
    if (_running || _userId == null) return;
    _running = true;
    try {
      await pushDirty();
      final maxTs = await pullSince(_lastSyncedAt);
      final next = [
        _lastSyncedAt,
        maxTs,
        DateTime.now().toUtc().millisecondsSinceEpoch,
      ].reduce((a, b) => a > b ? a : b);
      await _setLastSyncedAt(next);
    } catch (e, st) {
      developer.log('syncOnce failed', name: 'sync', error: e, stackTrace: st);
    } finally {
      _running = false;
    }
  }

  // --- push ------------------------------------------------------------------

  /// Pushes every locally-dirty row (including tombstones) to the matching
  /// remote table, then clears the local `dirty` flag for what was pushed.
  Future<void> pushDirty() async {
    if (_userId == null) return;

    // snippets (+ children per dirty snippet)
    final dirtySnippets =
        await (_db.select(_db.snippets)..where((s) => s.dirty.equals(true)))
            .get();
    if (dirtySnippets.isNotEmpty) {
      await _client.from('snippets').upsert(
            [for (final s in dirtySnippets) snippetRowToRemote(s)],
          );
      for (final s in dirtySnippets) {
        await _pushSnippetChildren(s.id);
      }
      await (_db.update(_db.snippets)
            ..where((s) => s.id.isIn([for (final s in dirtySnippets) s.id])))
          .write(const SnippetsCompanion(dirty: Value(false)));
    }

    // snippet_files
    final dirtyFiles = await (_db.select(_db.snippetFiles)
          ..where((f) => f.dirty.equals(true)))
        .get();
    if (dirtyFiles.isNotEmpty) {
      await _client.from('snippet_files').upsert(
            [for (final f in dirtyFiles) snippetFileRowToRemote(f)],
          );
      await (_db.update(_db.snippetFiles)
            ..where((f) => f.id.isIn([for (final f in dirtyFiles) f.id])))
          .write(const SnippetFilesCompanion(dirty: Value(false)));
    }

    // collections
    final dirtyCollections = await (_db.select(_db.collections)
          ..where((c) => c.dirty.equals(true)))
        .get();
    if (dirtyCollections.isNotEmpty) {
      await _client.from('collections').upsert(
            [for (final c in dirtyCollections) collectionRowToRemote(c)],
          );
      await (_db.update(_db.collections)
            ..where((c) => c.id.isIn([for (final c in dirtyCollections) c.id])))
          .write(const CollectionsCompanion(dirty: Value(false)));
    }

    // tags -> remote labels
    final dirtyTags =
        await (_db.select(_db.tags)..where((t) => t.dirty.equals(true))).get();
    if (dirtyTags.isNotEmpty) {
      await _client.from('labels').upsert(
            [for (final t in dirtyTags) tagRowToLabelRemote(t)],
          );
      await (_db.update(_db.tags)
            ..where((t) => t.id.isIn([for (final t in dirtyTags) t.id])))
          .write(const TagsCompanion(dirty: Value(false)));
    }
  }

  /// For one dirty snippet, replaces its remote `snippet_labels` from local
  /// `snippet_tags` and upserts its `ai_prompt_meta`.
  Future<void> _pushSnippetChildren(String snippetId) async {
    final joins = await (_db.select(_db.snippetTags)
          ..where((j) => j.snippetId.equals(snippetId)))
        .get();
    await _client
        .from('snippet_labels')
        .delete()
        .eq('snippet_id', snippetId);
    if (joins.isNotEmpty) {
      await _client.from('snippet_labels').upsert(
            [for (final j in joins) snippetTagRowToLabelRemote(j)],
          );
    }

    final meta = await (_db.select(_db.aiPromptMeta)
          ..where((m) => m.snippetId.equals(snippetId)))
        .getSingleOrNull();
    if (meta != null) {
      await _client.from('ai_prompt_meta').upsert(aiPromptMetaRowToRemote(meta));
    }
  }

  // --- pull ------------------------------------------------------------------

  /// Pulls remote rows with `updated_at > sinceMs` for each table, applying
  /// last-write-wins into local Drift. Returns the max `updated_at` seen.
  Future<int> pullSince(int sinceMs) async {
    if (_userId == null) return sinceMs;
    var maxTs = sinceMs;

    // collections
    final remoteCollections = await _client
        .from('collections')
        .select()
        .gt('updated_at', sinceMs) as List<dynamic>;
    for (final raw in remoteCollections.cast<Map<String, dynamic>>()) {
      maxTs = await _upsertCollection(raw, maxTs);
    }

    // labels -> local tags
    final remoteLabels = await _client
        .from('labels')
        .select()
        .gt('updated_at', sinceMs) as List<dynamic>;
    for (final raw in remoteLabels.cast<Map<String, dynamic>>()) {
      maxTs = await _upsertLabel(raw, maxTs);
    }

    // snippets (+ children for each changed snippet)
    final remoteSnippets = await _client
        .from('snippets')
        .select()
        .gt('updated_at', sinceMs) as List<dynamic>;
    for (final raw in remoteSnippets.cast<Map<String, dynamic>>()) {
      maxTs = await _upsertSnippet(raw, maxTs);
    }

    // snippet_files
    final remoteFiles = await _client
        .from('snippet_files')
        .select()
        .gt('updated_at', sinceMs) as List<dynamic>;
    for (final raw in remoteFiles.cast<Map<String, dynamic>>()) {
      maxTs = await _upsertFile(raw, maxTs);
    }

    return maxTs;
  }

  Future<int> _upsertCollection(Map<String, dynamic> raw, int maxTs) async {
    final remoteTs = (raw['updated_at'] as num?)?.toInt() ?? 0;
    final id = raw['id'] as String;
    final local = await (_db.select(_db.collections)
          ..where((c) => c.id.equals(id)))
        .getSingleOrNull();
    if (local == null || remoteTs >= local.updatedAt) {
      await _db
          .into(_db.collections)
          .insertOnConflictUpdate(remoteToCollectionCompanion(raw));
    }
    return remoteTs > maxTs ? remoteTs : maxTs;
  }

  Future<int> _upsertLabel(Map<String, dynamic> raw, int maxTs) async {
    final remoteTs = (raw['updated_at'] as num?)?.toInt() ?? 0;
    final id = raw['id'] as String;
    final local =
        await (_db.select(_db.tags)..where((t) => t.id.equals(id)))
            .getSingleOrNull();
    if (local == null || remoteTs >= local.updatedAt) {
      await _db
          .into(_db.tags)
          .insertOnConflictUpdate(remoteLabelToTagCompanion(raw));
    }
    return remoteTs > maxTs ? remoteTs : maxTs;
  }

  Future<int> _upsertSnippet(Map<String, dynamic> raw, int maxTs) async {
    final remoteTs = (raw['updated_at'] as num?)?.toInt() ?? 0;
    final id = raw['id'] as String;
    final local = await (_db.select(_db.snippets)
          ..where((s) => s.id.equals(id)))
        .getSingleOrNull();
    if (local == null || remoteTs >= local.updatedAt) {
      await _db
          .into(_db.snippets)
          .insertOnConflictUpdate(remoteToSnippetCompanion(raw));
      await _pullSnippetChildren(id);
    }
    return remoteTs > maxTs ? remoteTs : maxTs;
  }

  Future<int> _upsertFile(Map<String, dynamic> raw, int maxTs) async {
    final remoteTs = (raw['updated_at'] as num?)?.toInt() ?? 0;
    final id = raw['id'] as String;
    final local = await (_db.select(_db.snippetFiles)
          ..where((f) => f.id.equals(id)))
        .getSingleOrNull();
    if (local == null || remoteTs >= local.updatedAt) {
      await _db
          .into(_db.snippetFiles)
          .insertOnConflictUpdate(remoteToSnippetFileCompanion(raw));
    }
    return remoteTs > maxTs ? remoteTs : maxTs;
  }

  /// Rebuilds local `snippet_tags` and `ai_prompt_meta` for a changed snippet.
  Future<void> _pullSnippetChildren(String snippetId) async {
    final remoteLinks = await _client
        .from('snippet_labels')
        .select()
        .eq('snippet_id', snippetId) as List<dynamic>;
    await (_db.delete(_db.snippetTags)
          ..where((j) => j.snippetId.equals(snippetId)))
        .go();
    for (final raw in remoteLinks.cast<Map<String, dynamic>>()) {
      await _db
          .into(_db.snippetTags)
          .insertOnConflictUpdate(remoteSnippetLabelToTagCompanion(raw));
    }

    final remoteMeta = await _client
        .from('ai_prompt_meta')
        .select()
        .eq('snippet_id', snippetId)
        .maybeSingle();
    if (remoteMeta != null) {
      await _db
          .into(_db.aiPromptMeta)
          .insertOnConflictUpdate(remoteToAiPromptMetaCompanion(remoteMeta));
    }
  }

  // --- realtime --------------------------------------------------------------

  /// Subscribes to realtime changes on the synced tables; any change schedules a
  /// debounced [syncOnce]. RLS already scopes the stream to this user.
  void start() {
    if (_userId == null || _channels.isNotEmpty) return;
    for (final table in const [
      'snippets',
      'snippet_files',
      'labels',
      'collections',
    ]) {
      final channel = _client
          .channel('public:$table')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: table,
            callback: (_) => scheduleSync(),
          )
          .subscribe();
      _channels.add(channel);
    }
    // Initial reconcile on connect.
    scheduleSync();
  }

  /// Removes all realtime channels and cancels any pending debounce.
  void stop() {
    _debounce?.cancel();
    _debounce = null;
    for (final channel in _channels) {
      _client.removeChannel(channel);
    }
    _channels.clear();
  }

  void dispose() => stop();
}
