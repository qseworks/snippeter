import 'snippet_type.dart';

enum SnippetSort { recent, created, titleAsc, relevance }

/// Filter + sort criteria for the snippet list. Implements value equality so it
/// can key a Riverpod `family` provider.
class SnippetQuery {
  const SnippetQuery({
    this.text,
    this.type,
    this.languageId,
    this.collectionId,
    this.labelIds = const [],
    this.labelsMatchAll = false,
    this.unlabeled = false,
    this.favoritesOnly = false,
    this.sort = SnippetSort.recent,
    this.workspaceId,
  });

  final String? text;
  final SnippetType? type;
  final String? languageId;
  final String? collectionId;
  final List<String> labelIds;
  final bool labelsMatchAll;
  final bool unlabeled;
  final bool favoritesOnly;
  final SnippetSort sort;

  /// Active team library to scope to. null = personal (workspace_id IS NULL).
  final String? workspaceId;

  bool get hasText => text != null && text!.trim().isNotEmpty;

  bool get hasFilters =>
      type != null ||
      languageId != null ||
      collectionId != null ||
      labelIds.isNotEmpty ||
      unlabeled ||
      favoritesOnly;

  SnippetQuery copyWith({
    Object? text = _sentinel,
    Object? type = _sentinel,
    Object? languageId = _sentinel,
    Object? collectionId = _sentinel,
    List<String>? labelIds,
    bool? labelsMatchAll,
    bool? unlabeled,
    bool? favoritesOnly,
    SnippetSort? sort,
    Object? workspaceId = _sentinel,
  }) {
    return SnippetQuery(
      text: text == _sentinel ? this.text : text as String?,
      type: type == _sentinel ? this.type : type as SnippetType?,
      languageId:
          languageId == _sentinel ? this.languageId : languageId as String?,
      collectionId: collectionId == _sentinel
          ? this.collectionId
          : collectionId as String?,
      labelIds: labelIds ?? this.labelIds,
      labelsMatchAll: labelsMatchAll ?? this.labelsMatchAll,
      unlabeled: unlabeled ?? this.unlabeled,
      favoritesOnly: favoritesOnly ?? this.favoritesOnly,
      sort: sort ?? this.sort,
      workspaceId: workspaceId == _sentinel
          ? this.workspaceId
          : workspaceId as String?,
    );
  }

  static const Object _sentinel = Object();

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SnippetQuery &&
        other.text == text &&
        other.type == type &&
        other.languageId == languageId &&
        other.collectionId == collectionId &&
        _listEquals(other.labelIds, labelIds) &&
        other.labelsMatchAll == labelsMatchAll &&
        other.unlabeled == unlabeled &&
        other.favoritesOnly == favoritesOnly &&
        other.sort == sort &&
        other.workspaceId == workspaceId;
  }

  @override
  int get hashCode => Object.hash(
        text,
        type,
        languageId,
        collectionId,
        Object.hashAll(labelIds),
        labelsMatchAll,
        unlabeled,
        favoritesOnly,
        sort,
        workspaceId,
      );

  static bool _listEquals(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
