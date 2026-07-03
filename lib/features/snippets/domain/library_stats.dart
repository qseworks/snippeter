/// Aggregate library counts for the sidebar (All/Starred/Unlabeled, LABELS
/// and LANGUAGES buckets). Produced by the repository as a watched SQL
/// aggregate — the sidebar must never need every snippet's content hydrated
/// just to show numbers.
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
