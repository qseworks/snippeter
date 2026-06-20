import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/db/database_provider.dart';
import '../data/local_snippet_repository.dart';
import '../domain/snippet.dart';
import '../domain/snippet_query.dart';
import '../domain/snippet_repository.dart';
import '../domain/snippet_type.dart';
import '../domain/value_objects.dart';

/// The single seam: swap this for a SyncedSnippetRepository in Phase 7 and the
/// rest of the app is untouched.
final snippetRepositoryProvider = Provider<SnippetRepository>((ref) {
  return LocalSnippetRepository(ref.watch(appDatabaseProvider));
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

/// All non-deleted snippets (unfiltered). Backs derived library stats and the
/// sidebar counts. autoDispose so it's released when nothing observes it.
final allSnippetsProvider = StreamProvider.autoDispose<List<Snippet>>(
  (ref) => ref.watch(snippetRepositoryProvider).watchSnippets(
        const SnippetQuery(),
      ),
);

/// Aggregate counts derived from [allSnippetsProvider] for the sidebar/stats.
class LibraryStats {
  const LibraryStats({
    this.total = 0,
    this.starred = 0,
    this.unlabeled = 0,
    this.byLanguageId = const {},
    this.byLabelId = const {},
  });

  final int total;
  final int starred;
  final int unlabeled;
  final Map<String, int> byLanguageId;
  final Map<String, int> byLabelId;
}

/// Derives [LibraryStats] from the current snapshot of all snippets.
final libraryStatsProvider = Provider<LibraryStats>((ref) {
  final snippets = ref.watch(allSnippetsProvider).value;
  if (snippets == null) return const LibraryStats();

  var starred = 0;
  var unlabeled = 0;
  final byLanguageId = <String, int>{};
  final byLabelId = <String, int>{};

  for (final s in snippets) {
    if (s.isFavorite) starred++;
    if (s.labels.isEmpty) unlabeled++;
    final lang = s.languageId;
    if (lang != null) byLanguageId[lang] = (byLanguageId[lang] ?? 0) + 1;
    for (final label in s.labels) {
      byLabelId[label.id] = (byLabelId[label.id] ?? 0) + 1;
    }
  }

  return LibraryStats(
    total: snippets.length,
    starred: starred,
    unlabeled: unlabeled,
    byLanguageId: byLanguageId,
    byLabelId: byLabelId,
  );
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

/// Mutable query state for the Library tab.
class LibraryQueryController extends Notifier<SnippetQuery> {
  @override
  SnippetQuery build() => const SnippetQuery();

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
      state = SnippetQuery(text: state.text, sort: state.sort);

  /// Reset all filters but keep the current search text and sort.
  void showAll() => state = SnippetQuery(text: state.text, sort: state.sort);

  /// Show only starred snippets; reset every other filter.
  void showStarred() => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        favoritesOnly: true,
      );

  /// Show only snippets with no labels; reset every other filter.
  void showUnlabeled() => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        unlabeled: true,
      );

  /// Filter to a single label; reset every other filter.
  void selectLabel(String id) => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        labelIds: [id],
      );

  /// Filter to a single language; reset every other filter.
  void selectLanguage(String id) => state = SnippetQuery(
        text: state.text,
        sort: state.sort,
        languageId: id,
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
