import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../../sync/application/sync_providers.dart';
import '../../sync/data/synced_snippet_repository.dart';
import '../../workspaces/application/workspace_providers.dart';
import '../data/local_snippet_repository.dart';
import '../domain/library_stats.dart';
import '../domain/snippet.dart';
import '../domain/snippet_query.dart';
import '../domain/snippet_repository.dart';
import '../domain/snippet_type.dart';
import '../domain/value_objects.dart';

export '../domain/library_stats.dart';

/// The single seam. Always backed by [LocalSnippetRepository] (offline-first
/// source of truth), wrapped by [SyncedSnippetRepository] which mirrors mutating
/// writes to Supabase via a debounced sync. When signed out / unconfigured the
/// sync trigger is a no-op, so behavior is identical to local-only.
final snippetRepositoryProvider = Provider<SnippetRepository>((ref) {
  final local = LocalSnippetRepository(ref.watch(appDatabaseProvider));
  return SyncedSnippetRepository(
    local: local,
    onMutation: () => ref.read(syncServiceProvider)?.scheduleSync(),
  );
});

final languagesProvider = FutureProvider<List<Language>>(
  (ref) => ref.watch(snippetRepositoryProvider).getLanguages(),
);

/// languageId -> [Language], for resolving names/extensions/grammars in the UI.
final languageMapProvider = Provider<Map<String, Language>>((ref) {
  final langs = ref.watch(languagesProvider).value ?? const [];
  return {for (final l in langs) l.id: l};
});

final purposesProvider = FutureProvider<List<Purpose>>(
  (ref) => ref.watch(snippetRepositoryProvider).getPurposes(),
);

final collectionsProvider = StreamProvider<List<Collection>>(
  (ref) => ref.watch(snippetRepositoryProvider).watchCollections(),
);

final collectionMapProvider = Provider<Map<String, Collection>>((ref) {
  final cols = ref.watch(collectionsProvider).value ?? const [];
  return {for (final c in cols) c.id: c};
});

final labelsProvider = StreamProvider<List<Label>>(
  (ref) => ref.watch(snippetRepositoryProvider).watchLabels(),
);

/// Aggregate sidebar counts for the ACTIVE library (Personal or team),
/// computed database-side (see [SnippetRepository.watchLibraryStats]) so
/// no snippet content is hydrated just to show numbers. autoDispose so the
/// watched query is released when nothing observes it.
final libraryStatsStreamProvider = StreamProvider.autoDispose<LibraryStats>(
  (ref) {
    final workspaceId = ref.watch(activeWorkspaceProvider);
    return ref
        .watch(snippetRepositoryProvider)
        .watchLibraryStats(workspaceId: workspaceId);
  },
);

/// Latest [LibraryStats] snapshot (zeros until the first emission), for
/// consumers that just want values, not an AsyncValue.
final libraryStatsProvider = Provider.autoDispose<LibraryStats>((ref) {
  return ref.watch(libraryStatsStreamProvider).value ?? const LibraryStats();
});

/// Snippet list keyed by a (value-equal) [SnippetQuery]. autoDispose so that
/// the unbounded space of search/filter queries doesn't leak a live Drift
/// stream subscription per distinct query for the whole session.
final snippetListProvider =
    StreamProvider.autoDispose.family<List<Snippet>, SnippetQuery>((ref, query) {
  return ref.watch(snippetRepositoryProvider).watchSnippets(query);
});

/// A single snippet by id (reactive). autoDispose so per-snippet watch streams
/// are released once no detail view is showing them.
final snippetProvider =
    StreamProvider.autoDispose.family<Snippet?, String>((ref, id) {
  return ref.watch(snippetRepositoryProvider).watchSnippet(id);
});

/// Live attachments for a snippet (not deleted, newest first), keyed by
/// snippet id. autoDispose so a snippet's attachment stream is released once no
/// detail view is observing it.
final attachmentsProvider =
    StreamProvider.autoDispose.family<List<Attachment>, String>((ref, id) {
  return ref.watch(snippetRepositoryProvider).watchAttachments(id);
});

/// Mutable query state for the Library tab. Always scoped to the active library
/// (Personal or a team workspace): switching the active workspace re-scopes the
/// query while preserving the current search text and sort.
class LibraryQueryController extends Notifier<SnippetQuery> {
  @override
  SnippetQuery build() {
    // Re-scope whenever the active library changes, keeping text + sort.
    ref.listen(activeWorkspaceProvider, (_, next) {
      state = state.copyWith(workspaceId: next);
    });
    final workspaceId = ref.read(activeWorkspaceProvider);
    return SnippetQuery(workspaceId: workspaceId);
  }

  String? get _ws => state.workspaceId;

  void setText(String? text) => state = state.copyWith(text: text);
  void setType(SnippetType? type) => state = state.copyWith(type: type);
  void setLanguage(String? id) => state = state.copyWith(languageId: id);
  void setCollection(String? id) => state = state.copyWith(collectionId: id);
  void setLabels(List<String> labelIds) =>
      state = state.copyWith(labelIds: labelIds);
  void setLabelsMatchAll({required bool all}) =>
      state = state.copyWith(labelsMatchAll: all);
  void setSort(SnippetSort sort) => state = state.copyWith(sort: sort);
  void clearFilters() =>
      state = SnippetQuery(text: state.text, sort: state.sort, workspaceId: _ws);

  /// Reset all filters but keep the current search text and sort.
  void showAll() =>
      state = SnippetQuery(text: state.text, sort: state.sort, workspaceId: _ws);

  /// Show only starred snippets; reset every other filter.
  void showStarred() => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        favoritesOnly: true,
        workspaceId: _ws,
      );

  /// Show only snippets with no labels; reset every other filter.
  void showUnlabeled() => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        unlabeled: true,
        workspaceId: _ws,
      );

  /// Filter to a single label; reset every other filter.
  void selectLabel(String id) => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        labelIds: [id],
        workspaceId: _ws,
      );

  /// Filter to a single language; reset every other filter.
  void selectLanguage(String id) => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        languageId: id,
        workspaceId: _ws,
      );
}

final libraryQueryProvider =
    NotifierProvider<LibraryQueryController, SnippetQuery>(
  LibraryQueryController.new,
);

/// The snippet selected in the wide (two-pane) Library layout.
class SelectedSnippetController extends Notifier<String?> {
  @override
  String? build() => null;
  void select(String? id) => state = id;
}

final selectedSnippetProvider =
    NotifierProvider<SelectedSnippetController, String?>(
  SelectedSnippetController.new,
);

/// Shared [FocusNode] for the Library search field, so a global Cmd/Ctrl+F
/// shortcut can focus it from anywhere in the app.
final searchFocusProvider = Provider<FocusNode>((ref) {
  final node = FocusNode(debugLabel: 'librarySearch');
  ref.onDispose(node.dispose);
  return node;
});
